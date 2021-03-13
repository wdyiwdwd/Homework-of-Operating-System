
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 b0 00 00 00       	call   f01000ee <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:


// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 00 64 10 f0       	push   $0xf0106400
f0100050:	e8 7d 3a 00 00       	call   f0103ad2 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 32 09 00 00       	call   f01009ad <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 1c 64 10 f0       	push   $0xf010641c
f0100087:	e8 46 3a 00 00       	call   f0103ad2 <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009c:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f01000a3:	75 3a                	jne    f01000df <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f01000a5:	89 35 80 be 22 f0    	mov    %esi,0xf022be80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000ab:	fa                   	cli    
f01000ac:	fc                   	cld    

	va_start(ap, fmt);
f01000ad:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000b0:	e8 a7 5c 00 00       	call   f0105d5c <cpunum>
f01000b5:	ff 75 0c             	pushl  0xc(%ebp)
f01000b8:	ff 75 08             	pushl  0x8(%ebp)
f01000bb:	50                   	push   %eax
f01000bc:	68 18 65 10 f0       	push   $0xf0106518
f01000c1:	e8 0c 3a 00 00       	call   f0103ad2 <cprintf>
	vcprintf(fmt, ap);
f01000c6:	83 c4 08             	add    $0x8,%esp
f01000c9:	53                   	push   %ebx
f01000ca:	56                   	push   %esi
f01000cb:	e8 dc 39 00 00       	call   f0103aac <vcprintf>
	cprintf("\n");
f01000d0:	c7 04 24 a2 64 10 f0 	movl   $0xf01064a2,(%esp)
f01000d7:	e8 f6 39 00 00       	call   f0103ad2 <cprintf>
	va_end(ap);
f01000dc:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	83 ec 0c             	sub    $0xc,%esp
f01000e2:	6a 00                	push   $0x0
f01000e4:	e8 d7 09 00 00       	call   f0100ac0 <monitor>
f01000e9:	83 c4 10             	add    $0x10,%esp
f01000ec:	eb f1                	jmp    f01000df <_panic+0x4b>

f01000ee <i386_init>:
	cprintf("leaving test_backtrace %d\n", x);
}

void
i386_init(void)
{
f01000ee:	55                   	push   %ebp
f01000ef:	89 e5                	mov    %esp,%ebp
f01000f1:	56                   	push   %esi
f01000f2:	53                   	push   %ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000f3:	83 ec 04             	sub    $0x4,%esp
f01000f6:	b8 08 d0 26 f0       	mov    $0xf026d008,%eax
f01000fb:	2d 3c a7 22 f0       	sub    $0xf022a73c,%eax
f0100100:	50                   	push   %eax
f0100101:	6a 00                	push   $0x0
f0100103:	68 3c a7 22 f0       	push   $0xf022a73c
f0100108:	e8 30 56 00 00       	call   f010573d <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010d:	e8 64 06 00 00       	call   f0100776 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100112:	83 c4 08             	add    $0x8,%esp
f0100115:	68 ac 1a 00 00       	push   $0x1aac
f010011a:	68 37 64 10 f0       	push   $0xf0106437
f010011f:	e8 ae 39 00 00       	call   f0103ad2 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100124:	e8 b0 15 00 00       	call   f01016d9 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100129:	e8 33 32 00 00       	call   f0103361 <env_init>
	trap_init();
f010012e:	e8 72 3a 00 00       	call   f0103ba5 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100133:	e8 1c 59 00 00       	call   f0105a54 <mp_init>
	lapic_init();
f0100138:	e8 3a 5c 00 00       	call   f0105d77 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010013d:	e8 b7 38 00 00       	call   f01039f9 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100142:	c7 04 24 80 14 12 f0 	movl   $0xf0121480,(%esp)
f0100149:	e8 7c 5e 00 00       	call   f0105fca <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010014e:	83 c4 10             	add    $0x10,%esp
f0100151:	83 3d 90 be 22 f0 07 	cmpl   $0x7,0xf022be90
f0100158:	77 16                	ja     f0100170 <i386_init+0x82>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010015a:	68 00 70 00 00       	push   $0x7000
f010015f:	68 3c 65 10 f0       	push   $0xf010653c
f0100164:	6a 62                	push   $0x62
f0100166:	68 52 64 10 f0       	push   $0xf0106452
f010016b:	e8 24 ff ff ff       	call   f0100094 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100170:	bb ba 59 10 f0       	mov    $0xf01059ba,%ebx
f0100175:	81 eb 40 59 10 f0    	sub    $0xf0105940,%ebx
f010017b:	83 ec 04             	sub    $0x4,%esp
f010017e:	53                   	push   %ebx
f010017f:	68 40 59 10 f0       	push   $0xf0105940
f0100184:	68 00 70 00 f0       	push   $0xf0007000
f0100189:	e8 fc 55 00 00       	call   f010578a <memmove>
	cprintf("code size: %x\n", mpentry_end - mpentry_start);
f010018e:	83 c4 08             	add    $0x8,%esp
f0100191:	53                   	push   %ebx
f0100192:	68 5e 64 10 f0       	push   $0xf010645e
f0100197:	e8 36 39 00 00       	call   f0103ad2 <cprintf>
	cprintf("code addr: %x, mpentry_start addr: %x\n",
f010019c:	83 c4 0c             	add    $0xc,%esp
f010019f:	68 40 59 10 f0       	push   $0xf0105940
f01001a4:	68 00 70 00 f0       	push   $0xf0007000
f01001a9:	68 60 65 10 f0       	push   $0xf0106560
f01001ae:	e8 1f 39 00 00       	call   f0103ad2 <cprintf>
		code, mpentry_start);
	// Boot each AP one at a time
	cprintf("boot_aps:cpus: %x\n", cpus);
f01001b3:	83 c4 08             	add    $0x8,%esp
f01001b6:	68 20 c0 22 f0       	push   $0xf022c020
f01001bb:	68 6d 64 10 f0       	push   $0xf010646d
f01001c0:	e8 0d 39 00 00       	call   f0103ad2 <cprintf>
	cprintf("ncpu: %x, CpuInfo size: %x\n", ncpu, sizeof(struct CpuInfo));
f01001c5:	83 c4 0c             	add    $0xc,%esp
f01001c8:	6a 74                	push   $0x74
f01001ca:	ff 35 c4 c3 22 f0    	pushl  0xf022c3c4
f01001d0:	68 80 64 10 f0       	push   $0xf0106480
f01001d5:	e8 f8 38 00 00       	call   f0103ad2 <cprintf>
f01001da:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01001dd:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
f01001e2:	e9 a3 00 00 00       	jmp    f010028a <i386_init+0x19c>
		cprintf("c: %x\n\n", c-cpus);
f01001e7:	89 de                	mov    %ebx,%esi
f01001e9:	81 ee 20 c0 22 f0    	sub    $0xf022c020,%esi
f01001ef:	c1 fe 02             	sar    $0x2,%esi
f01001f2:	69 f6 35 c2 72 4f    	imul   $0x4f72c235,%esi,%esi
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	56                   	push   %esi
f01001fc:	68 9c 64 10 f0       	push   $0xf010649c
f0100201:	e8 cc 38 00 00       	call   f0103ad2 <cprintf>
		if (c == cpus + cpunum())  // We've started already.
f0100206:	e8 51 5b 00 00       	call   f0105d5c <cpunum>
f010020b:	6b c0 74             	imul   $0x74,%eax,%eax
f010020e:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0100213:	83 c4 10             	add    $0x10,%esp
f0100216:	39 c3                	cmp    %eax,%ebx
f0100218:	74 6d                	je     f0100287 <i386_init+0x199>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021a:	89 f0                	mov    %esi,%eax
f010021c:	c1 e0 0f             	shl    $0xf,%eax
f010021f:	05 00 50 23 f0       	add    $0xf0235000,%eax
f0100224:	a3 84 be 22 f0       	mov    %eax,0xf022be84
		cprintf("mpentry_kstack: %x\n", mpentry_kstack);
f0100229:	83 ec 08             	sub    $0x8,%esp
f010022c:	50                   	push   %eax
f010022d:	68 a4 64 10 f0       	push   $0xf01064a4
f0100232:	e8 9b 38 00 00       	call   f0103ad2 <cprintf>
		// Start the CPU at mpentry_start
		cprintf("code: %x\n", code);
f0100237:	83 c4 08             	add    $0x8,%esp
f010023a:	68 00 70 00 f0       	push   $0xf0007000
f010023f:	68 b8 64 10 f0       	push   $0xf01064b8
f0100244:	e8 89 38 00 00       	call   f0103ad2 <cprintf>
		lapic_startap(c->cpu_id, PADDR(code));
f0100249:	83 c4 08             	add    $0x8,%esp
f010024c:	68 00 70 00 00       	push   $0x7000
f0100251:	0f b6 03             	movzbl (%ebx),%eax
f0100254:	50                   	push   %eax
f0100255:	e8 6b 5c 00 00       	call   f0105ec5 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		cprintf("c->cpu_status: %x\n", c->cpu_status);
f010025a:	8b 43 04             	mov    0x4(%ebx),%eax
f010025d:	83 c4 08             	add    $0x8,%esp
f0100260:	50                   	push   %eax
f0100261:	68 c2 64 10 f0       	push   $0xf01064c2
f0100266:	e8 67 38 00 00       	call   f0103ad2 <cprintf>
f010026b:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f010026e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100271:	83 f8 01             	cmp    $0x1,%eax
f0100274:	75 f8                	jne    f010026e <i386_init+0x180>
			;
		cprintf("cpu %x started\n", c-cpus);
f0100276:	83 ec 08             	sub    $0x8,%esp
f0100279:	56                   	push   %esi
f010027a:	68 d5 64 10 f0       	push   $0xf01064d5
f010027f:	e8 4e 38 00 00       	call   f0103ad2 <cprintf>
f0100284:	83 c4 10             	add    $0x10,%esp
	cprintf("code addr: %x, mpentry_start addr: %x\n",
		code, mpentry_start);
	// Boot each AP one at a time
	cprintf("boot_aps:cpus: %x\n", cpus);
	cprintf("ncpu: %x, CpuInfo size: %x\n", ncpu, sizeof(struct CpuInfo));
	for (c = cpus; c < cpus + ncpu; c++) {
f0100287:	83 c3 74             	add    $0x74,%ebx
f010028a:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0100291:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0100296:	39 c3                	cmp    %eax,%ebx
f0100298:	0f 82 49 ff ff ff    	jb     f01001e7 <i386_init+0xf9>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f010029e:	83 ec 04             	sub    $0x4,%esp
f01002a1:	6a 00                	push   $0x0
f01002a3:	68 4c 89 00 00       	push   $0x894c
f01002a8:	68 44 a8 19 f0       	push   $0xf019a844
f01002ad:	e8 76 32 00 00       	call   f0103528 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01002b2:	83 c4 0c             	add    $0xc,%esp
f01002b5:	6a 00                	push   $0x0
f01002b7:	68 4c 89 00 00       	push   $0x894c
f01002bc:	68 44 a8 19 f0       	push   $0xf019a844
f01002c1:	e8 62 32 00 00       	call   f0103528 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01002c6:	83 c4 0c             	add    $0xc,%esp
f01002c9:	6a 00                	push   $0x0
f01002cb:	68 4c 89 00 00       	push   $0x894c
f01002d0:	68 44 a8 19 f0       	push   $0xf019a844
f01002d5:	e8 4e 32 00 00       	call   f0103528 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002da:	e8 86 42 00 00       	call   f0104565 <sched_yield>

f01002df <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01002df:	55                   	push   %ebp
f01002e0:	89 e5                	mov    %esp,%ebp
f01002e2:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01002e5:	a1 94 be 22 f0       	mov    0xf022be94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01002ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01002ef:	77 15                	ja     f0100306 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01002f1:	50                   	push   %eax
f01002f2:	68 88 65 10 f0       	push   $0xf0106588
f01002f7:	68 82 00 00 00       	push   $0x82
f01002fc:	68 52 64 10 f0       	push   $0xf0106452
f0100301:	e8 8e fd ff ff       	call   f0100094 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100306:	05 00 00 00 10       	add    $0x10000000,%eax
f010030b:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010030e:	e8 49 5a 00 00       	call   f0105d5c <cpunum>
f0100313:	83 ec 08             	sub    $0x8,%esp
f0100316:	50                   	push   %eax
f0100317:	68 e5 64 10 f0       	push   $0xf01064e5
f010031c:	e8 b1 37 00 00       	call   f0103ad2 <cprintf>

	lapic_init();
f0100321:	e8 51 5a 00 00       	call   f0105d77 <lapic_init>
	// cprintf("lapic_init done\n");
	env_init_percpu();
f0100326:	e8 06 30 00 00       	call   f0103331 <env_init_percpu>
	// cprintf("env_init_percpu done\n");
	trap_init_percpu();
f010032b:	e8 b6 37 00 00       	call   f0103ae6 <trap_init_percpu>
	// cprintf("trap_init_percpu done\n");
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100330:	e8 27 5a 00 00       	call   f0105d5c <cpunum>
f0100335:	6b d0 74             	imul   $0x74,%eax,%edx
f0100338:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010033e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100343:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100347:	c7 04 24 80 14 12 f0 	movl   $0xf0121480,(%esp)
f010034e:	e8 77 5c 00 00       	call   f0105fca <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100353:	e8 0d 42 00 00       	call   f0104565 <sched_yield>

f0100358 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100358:	55                   	push   %ebp
f0100359:	89 e5                	mov    %esp,%ebp
f010035b:	53                   	push   %ebx
f010035c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010035f:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100362:	ff 75 0c             	pushl  0xc(%ebp)
f0100365:	ff 75 08             	pushl  0x8(%ebp)
f0100368:	68 fb 64 10 f0       	push   $0xf01064fb
f010036d:	e8 60 37 00 00       	call   f0103ad2 <cprintf>
	vcprintf(fmt, ap);
f0100372:	83 c4 08             	add    $0x8,%esp
f0100375:	53                   	push   %ebx
f0100376:	ff 75 10             	pushl  0x10(%ebp)
f0100379:	e8 2e 37 00 00       	call   f0103aac <vcprintf>
	cprintf("\n");
f010037e:	c7 04 24 a2 64 10 f0 	movl   $0xf01064a2,(%esp)
f0100385:	e8 48 37 00 00       	call   f0103ad2 <cprintf>
	va_end(ap);
}
f010038a:	83 c4 10             	add    $0x10,%esp
f010038d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100390:	c9                   	leave  
f0100391:	c3                   	ret    

f0100392 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100392:	55                   	push   %ebp
f0100393:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100395:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010039a:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010039b:	a8 01                	test   $0x1,%al
f010039d:	74 0b                	je     f01003aa <serial_proc_data+0x18>
f010039f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a4:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01003a5:	0f b6 c0             	movzbl %al,%eax
f01003a8:	eb 05                	jmp    f01003af <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01003aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01003af:	5d                   	pop    %ebp
f01003b0:	c3                   	ret    

f01003b1 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01003b1:	55                   	push   %ebp
f01003b2:	89 e5                	mov    %esp,%ebp
f01003b4:	53                   	push   %ebx
f01003b5:	83 ec 04             	sub    $0x4,%esp
f01003b8:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01003ba:	eb 2b                	jmp    f01003e7 <cons_intr+0x36>
		if (c == 0)
f01003bc:	85 c0                	test   %eax,%eax
f01003be:	74 27                	je     f01003e7 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01003c0:	8b 0d 24 b2 22 f0    	mov    0xf022b224,%ecx
f01003c6:	8d 51 01             	lea    0x1(%ecx),%edx
f01003c9:	89 15 24 b2 22 f0    	mov    %edx,0xf022b224
f01003cf:	88 81 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01003d5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01003db:	75 0a                	jne    f01003e7 <cons_intr+0x36>
			cons.wpos = 0;
f01003dd:	c7 05 24 b2 22 f0 00 	movl   $0x0,0xf022b224
f01003e4:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01003e7:	ff d3                	call   *%ebx
f01003e9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01003ec:	75 ce                	jne    f01003bc <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01003ee:	83 c4 04             	add    $0x4,%esp
f01003f1:	5b                   	pop    %ebx
f01003f2:	5d                   	pop    %ebp
f01003f3:	c3                   	ret    

f01003f4 <kbd_proc_data>:
f01003f4:	ba 64 00 00 00       	mov    $0x64,%edx
f01003f9:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003fa:	a8 01                	test   $0x1,%al
f01003fc:	0f 84 f0 00 00 00    	je     f01004f2 <kbd_proc_data+0xfe>
f0100402:	ba 60 00 00 00       	mov    $0x60,%edx
f0100407:	ec                   	in     (%dx),%al
f0100408:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010040a:	3c e0                	cmp    $0xe0,%al
f010040c:	75 0d                	jne    f010041b <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f010040e:	83 0d 00 b0 22 f0 40 	orl    $0x40,0xf022b000
		return 0;
f0100415:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010041a:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010041b:	55                   	push   %ebp
f010041c:	89 e5                	mov    %esp,%ebp
f010041e:	53                   	push   %ebx
f010041f:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100422:	84 c0                	test   %al,%al
f0100424:	79 36                	jns    f010045c <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100426:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f010042c:	89 cb                	mov    %ecx,%ebx
f010042e:	83 e3 40             	and    $0x40,%ebx
f0100431:	83 e0 7f             	and    $0x7f,%eax
f0100434:	85 db                	test   %ebx,%ebx
f0100436:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100439:	0f b6 d2             	movzbl %dl,%edx
f010043c:	0f b6 82 00 67 10 f0 	movzbl -0xfef9900(%edx),%eax
f0100443:	83 c8 40             	or     $0x40,%eax
f0100446:	0f b6 c0             	movzbl %al,%eax
f0100449:	f7 d0                	not    %eax
f010044b:	21 c8                	and    %ecx,%eax
f010044d:	a3 00 b0 22 f0       	mov    %eax,0xf022b000
		return 0;
f0100452:	b8 00 00 00 00       	mov    $0x0,%eax
f0100457:	e9 9e 00 00 00       	jmp    f01004fa <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010045c:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f0100462:	f6 c1 40             	test   $0x40,%cl
f0100465:	74 0e                	je     f0100475 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100467:	83 c8 80             	or     $0xffffff80,%eax
f010046a:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010046c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010046f:	89 0d 00 b0 22 f0    	mov    %ecx,0xf022b000
	}

	shift |= shiftcode[data];
f0100475:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100478:	0f b6 82 00 67 10 f0 	movzbl -0xfef9900(%edx),%eax
f010047f:	0b 05 00 b0 22 f0    	or     0xf022b000,%eax
f0100485:	0f b6 8a 00 66 10 f0 	movzbl -0xfef9a00(%edx),%ecx
f010048c:	31 c8                	xor    %ecx,%eax
f010048e:	a3 00 b0 22 f0       	mov    %eax,0xf022b000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100493:	89 c1                	mov    %eax,%ecx
f0100495:	83 e1 03             	and    $0x3,%ecx
f0100498:	8b 0c 8d e0 65 10 f0 	mov    -0xfef9a20(,%ecx,4),%ecx
f010049f:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01004a3:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01004a6:	a8 08                	test   $0x8,%al
f01004a8:	74 1b                	je     f01004c5 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01004aa:	89 da                	mov    %ebx,%edx
f01004ac:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01004af:	83 f9 19             	cmp    $0x19,%ecx
f01004b2:	77 05                	ja     f01004b9 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01004b4:	83 eb 20             	sub    $0x20,%ebx
f01004b7:	eb 0c                	jmp    f01004c5 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01004b9:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01004bc:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01004bf:	83 fa 19             	cmp    $0x19,%edx
f01004c2:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004c5:	f7 d0                	not    %eax
f01004c7:	a8 06                	test   $0x6,%al
f01004c9:	75 2d                	jne    f01004f8 <kbd_proc_data+0x104>
f01004cb:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004d1:	75 25                	jne    f01004f8 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01004d3:	83 ec 0c             	sub    $0xc,%esp
f01004d6:	68 ac 65 10 f0       	push   $0xf01065ac
f01004db:	e8 f2 35 00 00       	call   f0103ad2 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004e0:	ba 92 00 00 00       	mov    $0x92,%edx
f01004e5:	b8 03 00 00 00       	mov    $0x3,%eax
f01004ea:	ee                   	out    %al,(%dx)
f01004eb:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01004ee:	89 d8                	mov    %ebx,%eax
f01004f0:	eb 08                	jmp    f01004fa <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01004f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01004f7:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01004f8:	89 d8                	mov    %ebx,%eax
}
f01004fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01004fd:	c9                   	leave  
f01004fe:	c3                   	ret    

f01004ff <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01004ff:	55                   	push   %ebp
f0100500:	89 e5                	mov    %esp,%ebp
f0100502:	57                   	push   %edi
f0100503:	56                   	push   %esi
f0100504:	53                   	push   %ebx
f0100505:	83 ec 1c             	sub    $0x1c,%esp
f0100508:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010050a:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010050f:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100514:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100519:	eb 09                	jmp    f0100524 <cons_putc+0x25>
f010051b:	89 ca                	mov    %ecx,%edx
f010051d:	ec                   	in     (%dx),%al
f010051e:	ec                   	in     (%dx),%al
f010051f:	ec                   	in     (%dx),%al
f0100520:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100521:	83 c3 01             	add    $0x1,%ebx
f0100524:	89 f2                	mov    %esi,%edx
f0100526:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100527:	a8 20                	test   $0x20,%al
f0100529:	75 08                	jne    f0100533 <cons_putc+0x34>
f010052b:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100531:	7e e8                	jle    f010051b <cons_putc+0x1c>
f0100533:	89 f8                	mov    %edi,%eax
f0100535:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100538:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010053d:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010053e:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100543:	be 79 03 00 00       	mov    $0x379,%esi
f0100548:	b9 84 00 00 00       	mov    $0x84,%ecx
f010054d:	eb 09                	jmp    f0100558 <cons_putc+0x59>
f010054f:	89 ca                	mov    %ecx,%edx
f0100551:	ec                   	in     (%dx),%al
f0100552:	ec                   	in     (%dx),%al
f0100553:	ec                   	in     (%dx),%al
f0100554:	ec                   	in     (%dx),%al
f0100555:	83 c3 01             	add    $0x1,%ebx
f0100558:	89 f2                	mov    %esi,%edx
f010055a:	ec                   	in     (%dx),%al
f010055b:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100561:	7f 04                	jg     f0100567 <cons_putc+0x68>
f0100563:	84 c0                	test   %al,%al
f0100565:	79 e8                	jns    f010054f <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100567:	ba 78 03 00 00       	mov    $0x378,%edx
f010056c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100570:	ee                   	out    %al,(%dx)
f0100571:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100576:	b8 0d 00 00 00       	mov    $0xd,%eax
f010057b:	ee                   	out    %al,(%dx)
f010057c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100581:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!csa) csa = 0x0700;
f0100582:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0100589:	75 0a                	jne    f0100595 <cons_putc+0x96>
f010058b:	c7 05 88 be 22 f0 00 	movl   $0x700,0xf022be88
f0100592:	07 00 00 
	if (!(c & ~0xFF))
f0100595:	89 fa                	mov    %edi,%edx
f0100597:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= csa;
f010059d:	89 f8                	mov    %edi,%eax
f010059f:	0b 05 88 be 22 f0    	or     0xf022be88,%eax
f01005a5:	85 d2                	test   %edx,%edx
f01005a7:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01005aa:	89 f8                	mov    %edi,%eax
f01005ac:	0f b6 c0             	movzbl %al,%eax
f01005af:	83 f8 09             	cmp    $0x9,%eax
f01005b2:	74 74                	je     f0100628 <cons_putc+0x129>
f01005b4:	83 f8 09             	cmp    $0x9,%eax
f01005b7:	7f 0a                	jg     f01005c3 <cons_putc+0xc4>
f01005b9:	83 f8 08             	cmp    $0x8,%eax
f01005bc:	74 14                	je     f01005d2 <cons_putc+0xd3>
f01005be:	e9 99 00 00 00       	jmp    f010065c <cons_putc+0x15d>
f01005c3:	83 f8 0a             	cmp    $0xa,%eax
f01005c6:	74 3a                	je     f0100602 <cons_putc+0x103>
f01005c8:	83 f8 0d             	cmp    $0xd,%eax
f01005cb:	74 3d                	je     f010060a <cons_putc+0x10b>
f01005cd:	e9 8a 00 00 00       	jmp    f010065c <cons_putc+0x15d>
	case '\b':
		if (crt_pos > 0) {
f01005d2:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f01005d9:	66 85 c0             	test   %ax,%ax
f01005dc:	0f 84 e6 00 00 00    	je     f01006c8 <cons_putc+0x1c9>
			crt_pos--;
f01005e2:	83 e8 01             	sub    $0x1,%eax
f01005e5:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005eb:	0f b7 c0             	movzwl %ax,%eax
f01005ee:	66 81 e7 00 ff       	and    $0xff00,%di
f01005f3:	83 cf 20             	or     $0x20,%edi
f01005f6:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f01005fc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100600:	eb 78                	jmp    f010067a <cons_putc+0x17b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100602:	66 83 05 28 b2 22 f0 	addw   $0x50,0xf022b228
f0100609:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010060a:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f0100611:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100617:	c1 e8 16             	shr    $0x16,%eax
f010061a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010061d:	c1 e0 04             	shl    $0x4,%eax
f0100620:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
f0100626:	eb 52                	jmp    f010067a <cons_putc+0x17b>
		break;
	case '\t':
		cons_putc(' ');
f0100628:	b8 20 00 00 00       	mov    $0x20,%eax
f010062d:	e8 cd fe ff ff       	call   f01004ff <cons_putc>
		cons_putc(' ');
f0100632:	b8 20 00 00 00       	mov    $0x20,%eax
f0100637:	e8 c3 fe ff ff       	call   f01004ff <cons_putc>
		cons_putc(' ');
f010063c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100641:	e8 b9 fe ff ff       	call   f01004ff <cons_putc>
		cons_putc(' ');
f0100646:	b8 20 00 00 00       	mov    $0x20,%eax
f010064b:	e8 af fe ff ff       	call   f01004ff <cons_putc>
		cons_putc(' ');
f0100650:	b8 20 00 00 00       	mov    $0x20,%eax
f0100655:	e8 a5 fe ff ff       	call   f01004ff <cons_putc>
f010065a:	eb 1e                	jmp    f010067a <cons_putc+0x17b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010065c:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f0100663:	8d 50 01             	lea    0x1(%eax),%edx
f0100666:	66 89 15 28 b2 22 f0 	mov    %dx,0xf022b228
f010066d:	0f b7 c0             	movzwl %ax,%eax
f0100670:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f0100676:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010067a:	66 81 3d 28 b2 22 f0 	cmpw   $0x7cf,0xf022b228
f0100681:	cf 07 
f0100683:	76 43                	jbe    f01006c8 <cons_putc+0x1c9>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100685:	a1 2c b2 22 f0       	mov    0xf022b22c,%eax
f010068a:	83 ec 04             	sub    $0x4,%esp
f010068d:	68 00 0f 00 00       	push   $0xf00
f0100692:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100698:	52                   	push   %edx
f0100699:	50                   	push   %eax
f010069a:	e8 eb 50 00 00       	call   f010578a <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010069f:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f01006a5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01006ab:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01006b1:	83 c4 10             	add    $0x10,%esp
f01006b4:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01006b9:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006bc:	39 d0                	cmp    %edx,%eax
f01006be:	75 f4                	jne    f01006b4 <cons_putc+0x1b5>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01006c0:	66 83 2d 28 b2 22 f0 	subw   $0x50,0xf022b228
f01006c7:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006c8:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f01006ce:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006d3:	89 ca                	mov    %ecx,%edx
f01006d5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01006d6:	0f b7 1d 28 b2 22 f0 	movzwl 0xf022b228,%ebx
f01006dd:	8d 71 01             	lea    0x1(%ecx),%esi
f01006e0:	89 d8                	mov    %ebx,%eax
f01006e2:	66 c1 e8 08          	shr    $0x8,%ax
f01006e6:	89 f2                	mov    %esi,%edx
f01006e8:	ee                   	out    %al,(%dx)
f01006e9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ee:	89 ca                	mov    %ecx,%edx
f01006f0:	ee                   	out    %al,(%dx)
f01006f1:	89 d8                	mov    %ebx,%eax
f01006f3:	89 f2                	mov    %esi,%edx
f01006f5:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01006f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006f9:	5b                   	pop    %ebx
f01006fa:	5e                   	pop    %esi
f01006fb:	5f                   	pop    %edi
f01006fc:	5d                   	pop    %ebp
f01006fd:	c3                   	ret    

f01006fe <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01006fe:	80 3d 34 b2 22 f0 00 	cmpb   $0x0,0xf022b234
f0100705:	74 11                	je     f0100718 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100707:	55                   	push   %ebp
f0100708:	89 e5                	mov    %esp,%ebp
f010070a:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010070d:	b8 92 03 10 f0       	mov    $0xf0100392,%eax
f0100712:	e8 9a fc ff ff       	call   f01003b1 <cons_intr>
}
f0100717:	c9                   	leave  
f0100718:	f3 c3                	repz ret 

f010071a <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010071a:	55                   	push   %ebp
f010071b:	89 e5                	mov    %esp,%ebp
f010071d:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100720:	b8 f4 03 10 f0       	mov    $0xf01003f4,%eax
f0100725:	e8 87 fc ff ff       	call   f01003b1 <cons_intr>
}
f010072a:	c9                   	leave  
f010072b:	c3                   	ret    

f010072c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010072c:	55                   	push   %ebp
f010072d:	89 e5                	mov    %esp,%ebp
f010072f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100732:	e8 c7 ff ff ff       	call   f01006fe <serial_intr>
	kbd_intr();
f0100737:	e8 de ff ff ff       	call   f010071a <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010073c:	a1 20 b2 22 f0       	mov    0xf022b220,%eax
f0100741:	3b 05 24 b2 22 f0    	cmp    0xf022b224,%eax
f0100747:	74 26                	je     f010076f <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100749:	8d 50 01             	lea    0x1(%eax),%edx
f010074c:	89 15 20 b2 22 f0    	mov    %edx,0xf022b220
f0100752:	0f b6 88 20 b0 22 f0 	movzbl -0xfdd4fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100759:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010075b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100761:	75 11                	jne    f0100774 <cons_getc+0x48>
			cons.rpos = 0;
f0100763:	c7 05 20 b2 22 f0 00 	movl   $0x0,0xf022b220
f010076a:	00 00 00 
f010076d:	eb 05                	jmp    f0100774 <cons_getc+0x48>
		return c;
	}
	return 0;
f010076f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100774:	c9                   	leave  
f0100775:	c3                   	ret    

f0100776 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100776:	55                   	push   %ebp
f0100777:	89 e5                	mov    %esp,%ebp
f0100779:	57                   	push   %edi
f010077a:	56                   	push   %esi
f010077b:	53                   	push   %ebx
f010077c:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010077f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100786:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010078d:	5a a5 
	if (*cp != 0xA55A) {
f010078f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100796:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010079a:	74 11                	je     f01007ad <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010079c:	c7 05 30 b2 22 f0 b4 	movl   $0x3b4,0xf022b230
f01007a3:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01007a6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01007ab:	eb 16                	jmp    f01007c3 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01007ad:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007b4:	c7 05 30 b2 22 f0 d4 	movl   $0x3d4,0xf022b230
f01007bb:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01007be:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01007c3:	8b 3d 30 b2 22 f0    	mov    0xf022b230,%edi
f01007c9:	b8 0e 00 00 00       	mov    $0xe,%eax
f01007ce:	89 fa                	mov    %edi,%edx
f01007d0:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01007d1:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007d4:	89 da                	mov    %ebx,%edx
f01007d6:	ec                   	in     (%dx),%al
f01007d7:	0f b6 c8             	movzbl %al,%ecx
f01007da:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007dd:	b8 0f 00 00 00       	mov    $0xf,%eax
f01007e2:	89 fa                	mov    %edi,%edx
f01007e4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007e5:	89 da                	mov    %ebx,%edx
f01007e7:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01007e8:	89 35 2c b2 22 f0    	mov    %esi,0xf022b22c
	crt_pos = pos;
f01007ee:	0f b6 c0             	movzbl %al,%eax
f01007f1:	09 c8                	or     %ecx,%eax
f01007f3:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01007f9:	e8 1c ff ff ff       	call   f010071a <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01007fe:	83 ec 0c             	sub    $0xc,%esp
f0100801:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0100808:	25 fd ff 00 00       	and    $0xfffd,%eax
f010080d:	50                   	push   %eax
f010080e:	e8 6e 31 00 00       	call   f0103981 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100813:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100818:	b8 00 00 00 00       	mov    $0x0,%eax
f010081d:	89 f2                	mov    %esi,%edx
f010081f:	ee                   	out    %al,(%dx)
f0100820:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100825:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010082a:	ee                   	out    %al,(%dx)
f010082b:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100830:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100835:	89 da                	mov    %ebx,%edx
f0100837:	ee                   	out    %al,(%dx)
f0100838:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010083d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100842:	ee                   	out    %al,(%dx)
f0100843:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100848:	b8 03 00 00 00       	mov    $0x3,%eax
f010084d:	ee                   	out    %al,(%dx)
f010084e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100853:	b8 00 00 00 00       	mov    $0x0,%eax
f0100858:	ee                   	out    %al,(%dx)
f0100859:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010085e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100863:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100864:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100869:	ec                   	in     (%dx),%al
f010086a:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010086c:	83 c4 10             	add    $0x10,%esp
f010086f:	3c ff                	cmp    $0xff,%al
f0100871:	0f 95 05 34 b2 22 f0 	setne  0xf022b234
f0100878:	89 f2                	mov    %esi,%edx
f010087a:	ec                   	in     (%dx),%al
f010087b:	89 da                	mov    %ebx,%edx
f010087d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010087e:	80 f9 ff             	cmp    $0xff,%cl
f0100881:	75 10                	jne    f0100893 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f0100883:	83 ec 0c             	sub    $0xc,%esp
f0100886:	68 b8 65 10 f0       	push   $0xf01065b8
f010088b:	e8 42 32 00 00       	call   f0103ad2 <cprintf>
f0100890:	83 c4 10             	add    $0x10,%esp
}
f0100893:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100896:	5b                   	pop    %ebx
f0100897:	5e                   	pop    %esi
f0100898:	5f                   	pop    %edi
f0100899:	5d                   	pop    %ebp
f010089a:	c3                   	ret    

f010089b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010089b:	55                   	push   %ebp
f010089c:	89 e5                	mov    %esp,%ebp
f010089e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01008a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01008a4:	e8 56 fc ff ff       	call   f01004ff <cons_putc>
}
f01008a9:	c9                   	leave  
f01008aa:	c3                   	ret    

f01008ab <getchar>:

int
getchar(void)
{
f01008ab:	55                   	push   %ebp
f01008ac:	89 e5                	mov    %esp,%ebp
f01008ae:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01008b1:	e8 76 fe ff ff       	call   f010072c <cons_getc>
f01008b6:	85 c0                	test   %eax,%eax
f01008b8:	74 f7                	je     f01008b1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01008ba:	c9                   	leave  
f01008bb:	c3                   	ret    

f01008bc <iscons>:

int
iscons(int fdnum)
{
f01008bc:	55                   	push   %ebp
f01008bd:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01008bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01008c4:	5d                   	pop    %ebp
f01008c5:	c3                   	ret    

f01008c6 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008c6:	55                   	push   %ebp
f01008c7:	89 e5                	mov    %esp,%ebp
f01008c9:	56                   	push   %esi
f01008ca:	53                   	push   %ebx
f01008cb:	bb c4 6b 10 f0       	mov    $0xf0106bc4,%ebx
f01008d0:	be 30 6c 10 f0       	mov    $0xf0106c30,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008d5:	83 ec 04             	sub    $0x4,%esp
f01008d8:	ff 33                	pushl  (%ebx)
f01008da:	ff 73 fc             	pushl  -0x4(%ebx)
f01008dd:	68 00 68 10 f0       	push   $0xf0106800
f01008e2:	e8 eb 31 00 00       	call   f0103ad2 <cprintf>
f01008e7:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008ea:	83 c4 10             	add    $0x10,%esp
f01008ed:	39 f3                	cmp    %esi,%ebx
f01008ef:	75 e4                	jne    f01008d5 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008f9:	5b                   	pop    %ebx
f01008fa:	5e                   	pop    %esi
f01008fb:	5d                   	pop    %ebp
f01008fc:	c3                   	ret    

f01008fd <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008fd:	55                   	push   %ebp
f01008fe:	89 e5                	mov    %esp,%ebp
f0100900:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100903:	68 09 68 10 f0       	push   $0xf0106809
f0100908:	e8 c5 31 00 00       	call   f0103ad2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010090d:	83 c4 08             	add    $0x8,%esp
f0100910:	68 0c 00 10 00       	push   $0x10000c
f0100915:	68 b4 69 10 f0       	push   $0xf01069b4
f010091a:	e8 b3 31 00 00       	call   f0103ad2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010091f:	83 c4 0c             	add    $0xc,%esp
f0100922:	68 0c 00 10 00       	push   $0x10000c
f0100927:	68 0c 00 10 f0       	push   $0xf010000c
f010092c:	68 dc 69 10 f0       	push   $0xf01069dc
f0100931:	e8 9c 31 00 00       	call   f0103ad2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100936:	83 c4 0c             	add    $0xc,%esp
f0100939:	68 e1 63 10 00       	push   $0x1063e1
f010093e:	68 e1 63 10 f0       	push   $0xf01063e1
f0100943:	68 00 6a 10 f0       	push   $0xf0106a00
f0100948:	e8 85 31 00 00       	call   f0103ad2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010094d:	83 c4 0c             	add    $0xc,%esp
f0100950:	68 3c a7 22 00       	push   $0x22a73c
f0100955:	68 3c a7 22 f0       	push   $0xf022a73c
f010095a:	68 24 6a 10 f0       	push   $0xf0106a24
f010095f:	e8 6e 31 00 00       	call   f0103ad2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100964:	83 c4 0c             	add    $0xc,%esp
f0100967:	68 08 d0 26 00       	push   $0x26d008
f010096c:	68 08 d0 26 f0       	push   $0xf026d008
f0100971:	68 48 6a 10 f0       	push   $0xf0106a48
f0100976:	e8 57 31 00 00       	call   f0103ad2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010097b:	b8 07 d4 26 f0       	mov    $0xf026d407,%eax
f0100980:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100985:	83 c4 08             	add    $0x8,%esp
f0100988:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010098d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100993:	85 c0                	test   %eax,%eax
f0100995:	0f 48 c2             	cmovs  %edx,%eax
f0100998:	c1 f8 0a             	sar    $0xa,%eax
f010099b:	50                   	push   %eax
f010099c:	68 6c 6a 10 f0       	push   $0xf0106a6c
f01009a1:	e8 2c 31 00 00       	call   f0103ad2 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01009a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ab:	c9                   	leave  
f01009ac:	c3                   	ret    

f01009ad <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01009ad:	55                   	push   %ebp
f01009ae:	89 e5                	mov    %esp,%ebp
f01009b0:	57                   	push   %edi
f01009b1:	56                   	push   %esi
f01009b2:	53                   	push   %ebx
f01009b3:	83 ec 18             	sub    $0x18,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01009b6:	89 ee                	mov    %ebp,%esi
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
f01009b8:	68 22 68 10 f0       	push   $0xf0106822
f01009bd:	e8 10 31 00 00       	call   f0103ad2 <cprintf>
	while (ebp) {
f01009c2:	83 c4 10             	add    $0x10,%esp
f01009c5:	eb 45                	jmp    f0100a0c <mon_backtrace+0x5f>
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
f01009c7:	83 ec 04             	sub    $0x4,%esp
f01009ca:	ff 76 04             	pushl  0x4(%esi)
f01009cd:	56                   	push   %esi
f01009ce:	68 34 68 10 f0       	push   $0xf0106834
f01009d3:	e8 fa 30 00 00       	call   f0103ad2 <cprintf>
f01009d8:	8d 5e 08             	lea    0x8(%esi),%ebx
f01009db:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01009de:	83 c4 10             	add    $0x10,%esp
		int i;
		for (i = 2; i <= 6; ++i)
			cprintf(" %08.x", ebp[i]);
f01009e1:	83 ec 08             	sub    $0x8,%esp
f01009e4:	ff 33                	pushl  (%ebx)
f01009e6:	68 49 68 10 f0       	push   $0xf0106849
f01009eb:	e8 e2 30 00 00       	call   f0103ad2 <cprintf>
f01009f0:	83 c3 04             	add    $0x4,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
		int i;
		for (i = 2; i <= 6; ++i)
f01009f3:	83 c4 10             	add    $0x10,%esp
f01009f6:	39 fb                	cmp    %edi,%ebx
f01009f8:	75 e7                	jne    f01009e1 <mon_backtrace+0x34>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f01009fa:	83 ec 0c             	sub    $0xc,%esp
f01009fd:	68 a2 64 10 f0       	push   $0xf01064a2
f0100a02:	e8 cb 30 00 00       	call   f0103ad2 <cprintf>
		ebp = (uint32_t*) *ebp;
f0100a07:	8b 36                	mov    (%esi),%esi
f0100a09:	83 c4 10             	add    $0x10,%esp
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f0100a0c:	85 f6                	test   %esi,%esi
f0100a0e:	75 b7                	jne    f01009c7 <mon_backtrace+0x1a>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f0100a10:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a15:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a18:	5b                   	pop    %ebx
f0100a19:	5e                   	pop    %esi
f0100a1a:	5f                   	pop    %edi
f0100a1b:	5d                   	pop    %ebp
f0100a1c:	c3                   	ret    

f0100a1d <csa_backtrace>:

int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a1d:	55                   	push   %ebp
f0100a1e:	89 e5                	mov    %esp,%ebp
f0100a20:	57                   	push   %edi
f0100a21:	56                   	push   %esi
f0100a22:	53                   	push   %ebx
f0100a23:	83 ec 48             	sub    $0x48,%esp
f0100a26:	89 ee                	mov    %ebp,%esi
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
f0100a28:	68 22 68 10 f0       	push   $0xf0106822
f0100a2d:	e8 a0 30 00 00       	call   f0103ad2 <cprintf>
	while (ebp) {
f0100a32:	83 c4 10             	add    $0x10,%esp
f0100a35:	eb 78                	jmp    f0100aaf <csa_backtrace+0x92>
		uint32_t eip = ebp[1];
f0100a37:	8b 46 04             	mov    0x4(%esi),%eax
f0100a3a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		cprintf("ebp %x  eip %x  args", ebp, eip);
f0100a3d:	83 ec 04             	sub    $0x4,%esp
f0100a40:	50                   	push   %eax
f0100a41:	56                   	push   %esi
f0100a42:	68 34 68 10 f0       	push   $0xf0106834
f0100a47:	e8 86 30 00 00       	call   f0103ad2 <cprintf>
f0100a4c:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100a4f:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100a52:	83 c4 10             	add    $0x10,%esp
		int i;
		for (i = 2; i <= 6; ++i)
			cprintf(" %08.x", ebp[i]);
f0100a55:	83 ec 08             	sub    $0x8,%esp
f0100a58:	ff 33                	pushl  (%ebx)
f0100a5a:	68 49 68 10 f0       	push   $0xf0106849
f0100a5f:	e8 6e 30 00 00       	call   f0103ad2 <cprintf>
f0100a64:	83 c3 04             	add    $0x4,%ebx
	cprintf("Stack backtrace:\n");
	while (ebp) {
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
		int i;
		for (i = 2; i <= 6; ++i)
f0100a67:	83 c4 10             	add    $0x10,%esp
f0100a6a:	39 fb                	cmp    %edi,%ebx
f0100a6c:	75 e7                	jne    f0100a55 <csa_backtrace+0x38>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f0100a6e:	83 ec 0c             	sub    $0xc,%esp
f0100a71:	68 a2 64 10 f0       	push   $0xf01064a2
f0100a76:	e8 57 30 00 00       	call   f0103ad2 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f0100a7b:	83 c4 08             	add    $0x8,%esp
f0100a7e:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100a81:	50                   	push   %eax
f0100a82:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100a85:	57                   	push   %edi
f0100a86:	e8 17 42 00 00       	call   f0104ca2 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", 
f0100a8b:	83 c4 08             	add    $0x8,%esp
f0100a8e:	89 f8                	mov    %edi,%eax
f0100a90:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100a93:	50                   	push   %eax
f0100a94:	ff 75 d8             	pushl  -0x28(%ebp)
f0100a97:	ff 75 dc             	pushl  -0x24(%ebp)
f0100a9a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100a9d:	ff 75 d0             	pushl  -0x30(%ebp)
f0100aa0:	68 50 68 10 f0       	push   $0xf0106850
f0100aa5:	e8 28 30 00 00       	call   f0103ad2 <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
f0100aaa:	8b 36                	mov    (%esi),%esi
f0100aac:	83 c4 20             	add    $0x20,%esp
int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f0100aaf:	85 f6                	test   %esi,%esi
f0100ab1:	75 84                	jne    f0100a37 <csa_backtrace+0x1a>
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f0100ab3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ab8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100abb:	5b                   	pop    %ebx
f0100abc:	5e                   	pop    %esi
f0100abd:	5f                   	pop    %edi
f0100abe:	5d                   	pop    %ebp
f0100abf:	c3                   	ret    

f0100ac0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ac0:	55                   	push   %ebp
f0100ac1:	89 e5                	mov    %esp,%ebp
f0100ac3:	57                   	push   %edi
f0100ac4:	56                   	push   %esi
f0100ac5:	53                   	push   %ebx
f0100ac6:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ac9:	68 98 6a 10 f0       	push   $0xf0106a98
f0100ace:	e8 ff 2f 00 00       	call   f0103ad2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ad3:	c7 04 24 bc 6a 10 f0 	movl   $0xf0106abc,(%esp)
f0100ada:	e8 f3 2f 00 00       	call   f0103ad2 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f0100adf:	83 c4 0c             	add    $0xc,%esp
f0100ae2:	68 61 68 10 f0       	push   $0xf0106861
f0100ae7:	68 00 04 00 00       	push   $0x400
f0100aec:	68 65 68 10 f0       	push   $0xf0106865
f0100af1:	68 00 02 00 00       	push   $0x200
f0100af6:	68 6b 68 10 f0       	push   $0xf010686b
f0100afb:	68 00 01 00 00       	push   $0x100
f0100b00:	68 70 68 10 f0       	push   $0xf0106870
f0100b05:	e8 c8 2f 00 00       	call   f0103ad2 <cprintf>
		0x0100, "blue", 0x0200, "green", 0x0400, "red");
	// cprintf("UTrapframe: %x\n", sizeof(struct UTrapframe));
	if (tf != NULL)
f0100b0a:	83 c4 20             	add    $0x20,%esp
f0100b0d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100b11:	74 0e                	je     f0100b21 <monitor+0x61>
		print_trapframe(tf);
f0100b13:	83 ec 0c             	sub    $0xc,%esp
f0100b16:	ff 75 08             	pushl  0x8(%ebp)
f0100b19:	e8 7d 33 00 00       	call   f0103e9b <print_trapframe>
f0100b1e:	83 c4 10             	add    $0x10,%esp
	// asm volatile("or $0x0100, %%eax\n":::);
	// asm volatile("\tpushl %%eax\n":::);
	// asm volatile("\tpopf\n":::);
	// asm volatile("\tjmp *%0\n":: "g" (&tf->tf_eip): "memory");
	while (1) {
		buf = readline("K> ");
f0100b21:	83 ec 0c             	sub    $0xc,%esp
f0100b24:	68 80 68 10 f0       	push   $0xf0106880
f0100b29:	e8 b8 49 00 00       	call   f01054e6 <readline>
f0100b2e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b30:	83 c4 10             	add    $0x10,%esp
f0100b33:	85 c0                	test   %eax,%eax
f0100b35:	74 ea                	je     f0100b21 <monitor+0x61>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b37:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100b3e:	be 00 00 00 00       	mov    $0x0,%esi
f0100b43:	eb 0a                	jmp    f0100b4f <monitor+0x8f>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b45:	c6 03 00             	movb   $0x0,(%ebx)
f0100b48:	89 f7                	mov    %esi,%edi
f0100b4a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100b4d:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b4f:	0f b6 03             	movzbl (%ebx),%eax
f0100b52:	84 c0                	test   %al,%al
f0100b54:	74 63                	je     f0100bb9 <monitor+0xf9>
f0100b56:	83 ec 08             	sub    $0x8,%esp
f0100b59:	0f be c0             	movsbl %al,%eax
f0100b5c:	50                   	push   %eax
f0100b5d:	68 84 68 10 f0       	push   $0xf0106884
f0100b62:	e8 99 4b 00 00       	call   f0105700 <strchr>
f0100b67:	83 c4 10             	add    $0x10,%esp
f0100b6a:	85 c0                	test   %eax,%eax
f0100b6c:	75 d7                	jne    f0100b45 <monitor+0x85>
			*buf++ = 0;
		if (*buf == 0)
f0100b6e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b71:	74 46                	je     f0100bb9 <monitor+0xf9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b73:	83 fe 0f             	cmp    $0xf,%esi
f0100b76:	75 14                	jne    f0100b8c <monitor+0xcc>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b78:	83 ec 08             	sub    $0x8,%esp
f0100b7b:	6a 10                	push   $0x10
f0100b7d:	68 89 68 10 f0       	push   $0xf0106889
f0100b82:	e8 4b 2f 00 00       	call   f0103ad2 <cprintf>
f0100b87:	83 c4 10             	add    $0x10,%esp
f0100b8a:	eb 95                	jmp    f0100b21 <monitor+0x61>
			return 0;
		}
		argv[argc++] = buf;
f0100b8c:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b8f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100b93:	eb 03                	jmp    f0100b98 <monitor+0xd8>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100b95:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b98:	0f b6 03             	movzbl (%ebx),%eax
f0100b9b:	84 c0                	test   %al,%al
f0100b9d:	74 ae                	je     f0100b4d <monitor+0x8d>
f0100b9f:	83 ec 08             	sub    $0x8,%esp
f0100ba2:	0f be c0             	movsbl %al,%eax
f0100ba5:	50                   	push   %eax
f0100ba6:	68 84 68 10 f0       	push   $0xf0106884
f0100bab:	e8 50 4b 00 00       	call   f0105700 <strchr>
f0100bb0:	83 c4 10             	add    $0x10,%esp
f0100bb3:	85 c0                	test   %eax,%eax
f0100bb5:	74 de                	je     f0100b95 <monitor+0xd5>
f0100bb7:	eb 94                	jmp    f0100b4d <monitor+0x8d>
			buf++;
	}
	argv[argc] = 0;
f0100bb9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100bc0:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100bc1:	85 f6                	test   %esi,%esi
f0100bc3:	0f 84 58 ff ff ff    	je     f0100b21 <monitor+0x61>
f0100bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100bce:	83 ec 08             	sub    $0x8,%esp
f0100bd1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bd4:	ff 34 85 c0 6b 10 f0 	pushl  -0xfef9440(,%eax,4)
f0100bdb:	ff 75 a8             	pushl  -0x58(%ebp)
f0100bde:	e8 bf 4a 00 00       	call   f01056a2 <strcmp>
f0100be3:	83 c4 10             	add    $0x10,%esp
f0100be6:	85 c0                	test   %eax,%eax
f0100be8:	75 21                	jne    f0100c0b <monitor+0x14b>
			return commands[i].func(argc, argv, tf);
f0100bea:	83 ec 04             	sub    $0x4,%esp
f0100bed:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bf0:	ff 75 08             	pushl  0x8(%ebp)
f0100bf3:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100bf6:	52                   	push   %edx
f0100bf7:	56                   	push   %esi
f0100bf8:	ff 14 85 c8 6b 10 f0 	call   *-0xfef9438(,%eax,4)
	// asm volatile("\tpopf\n":::);
	// asm volatile("\tjmp *%0\n":: "g" (&tf->tf_eip): "memory");
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100bff:	83 c4 10             	add    $0x10,%esp
f0100c02:	85 c0                	test   %eax,%eax
f0100c04:	78 25                	js     f0100c2b <monitor+0x16b>
f0100c06:	e9 16 ff ff ff       	jmp    f0100b21 <monitor+0x61>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100c0b:	83 c3 01             	add    $0x1,%ebx
f0100c0e:	83 fb 09             	cmp    $0x9,%ebx
f0100c11:	75 bb                	jne    f0100bce <monitor+0x10e>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100c13:	83 ec 08             	sub    $0x8,%esp
f0100c16:	ff 75 a8             	pushl  -0x58(%ebp)
f0100c19:	68 a6 68 10 f0       	push   $0xf01068a6
f0100c1e:	e8 af 2e 00 00       	call   f0103ad2 <cprintf>
f0100c23:	83 c4 10             	add    $0x10,%esp
f0100c26:	e9 f6 fe ff ff       	jmp    f0100b21 <monitor+0x61>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c2e:	5b                   	pop    %ebx
f0100c2f:	5e                   	pop    %esi
f0100c30:	5f                   	pop    %edi
f0100c31:	5d                   	pop    %ebp
f0100c32:	c3                   	ret    

f0100c33 <xtoi>:

uint32_t xtoi(char* buf) {
f0100c33:	55                   	push   %ebp
f0100c34:	89 e5                	mov    %esp,%ebp
	uint32_t res = 0;
	buf += 2; //0x...
f0100c36:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c39:	8d 50 02             	lea    0x2(%eax),%edx
				break;
	}
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
f0100c3c:	b8 00 00 00 00       	mov    $0x0,%eax
	buf += 2; //0x...
	while (*buf) { 
f0100c41:	eb 17                	jmp    f0100c5a <xtoi+0x27>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
f0100c43:	80 f9 60             	cmp    $0x60,%cl
f0100c46:	7e 05                	jle    f0100c4d <xtoi+0x1a>
f0100c48:	83 e9 27             	sub    $0x27,%ecx
f0100c4b:	88 0a                	mov    %cl,(%edx)
f0100c4d:	c1 e0 04             	shl    $0x4,%eax
		res = res*16 + *buf - '0';
f0100c50:	0f be 0a             	movsbl (%edx),%ecx
f0100c53:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		++buf;
f0100c57:	83 c2 01             	add    $0x1,%edx
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
	buf += 2; //0x...
	while (*buf) { 
f0100c5a:	0f b6 0a             	movzbl (%edx),%ecx
f0100c5d:	84 c9                	test   %cl,%cl
f0100c5f:	75 e2                	jne    f0100c43 <xtoi+0x10>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
f0100c61:	5d                   	pop    %ebp
f0100c62:	c3                   	ret    

f0100c63 <showvm>:
	cprintf("%x after  setm: ", addr);
	pprint(pte);
	return 0;
}

int showvm(int argc, char **argv, struct Trapframe *tf) {
f0100c63:	55                   	push   %ebp
f0100c64:	89 e5                	mov    %esp,%ebp
f0100c66:	57                   	push   %edi
f0100c67:	56                   	push   %esi
f0100c68:	53                   	push   %ebx
f0100c69:	83 ec 0c             	sub    $0xc,%esp
f0100c6c:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100c6f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100c73:	75 12                	jne    f0100c87 <showvm+0x24>
		cprintf("Usage: showvm 0xaddr 0xn\n");
f0100c75:	83 ec 0c             	sub    $0xc,%esp
f0100c78:	68 bc 68 10 f0       	push   $0xf01068bc
f0100c7d:	e8 50 2e 00 00       	call   f0103ad2 <cprintf>
		return 0;
f0100c82:	83 c4 10             	add    $0x10,%esp
f0100c85:	eb 41                	jmp    f0100cc8 <showvm+0x65>
	}
	void** addr = (void**) xtoi(argv[1]);
f0100c87:	83 ec 0c             	sub    $0xc,%esp
f0100c8a:	ff 76 04             	pushl  0x4(%esi)
f0100c8d:	e8 a1 ff ff ff       	call   f0100c33 <xtoi>
f0100c92:	89 c3                	mov    %eax,%ebx
	uint32_t n = xtoi(argv[2]);
f0100c94:	83 c4 04             	add    $0x4,%esp
f0100c97:	ff 76 08             	pushl  0x8(%esi)
f0100c9a:	e8 94 ff ff ff       	call   f0100c33 <xtoi>
f0100c9f:	89 c6                	mov    %eax,%esi
	int i;
	for (i = 0; i < n; ++i)
f0100ca1:	83 c4 10             	add    $0x10,%esp
f0100ca4:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ca9:	eb 19                	jmp    f0100cc4 <showvm+0x61>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
f0100cab:	83 ec 04             	sub    $0x4,%esp
f0100cae:	ff 33                	pushl  (%ebx)
f0100cb0:	53                   	push   %ebx
f0100cb1:	68 d6 68 10 f0       	push   $0xf01068d6
f0100cb6:	e8 17 2e 00 00       	call   f0103ad2 <cprintf>
		return 0;
	}
	void** addr = (void**) xtoi(argv[1]);
	uint32_t n = xtoi(argv[2]);
	int i;
	for (i = 0; i < n; ++i)
f0100cbb:	83 c7 01             	add    $0x1,%edi
f0100cbe:	83 c3 04             	add    $0x4,%ebx
f0100cc1:	83 c4 10             	add    $0x10,%esp
f0100cc4:	39 f7                	cmp    %esi,%edi
f0100cc6:	75 e3                	jne    f0100cab <showvm+0x48>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
	return 0;
}
f0100cc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cd0:	5b                   	pop    %ebx
f0100cd1:	5e                   	pop    %esi
f0100cd2:	5f                   	pop    %edi
f0100cd3:	5d                   	pop    %ebp
f0100cd4:	c3                   	ret    

f0100cd5 <pprint>:
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
f0100cd5:	55                   	push   %ebp
f0100cd6:	89 e5                	mov    %esp,%ebp
f0100cd8:	83 ec 08             	sub    $0x8,%esp
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
f0100cdb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cde:	8b 00                	mov    (%eax),%eax
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
f0100ce0:	89 c2                	mov    %eax,%edx
f0100ce2:	83 e2 04             	and    $0x4,%edx
f0100ce5:	52                   	push   %edx
f0100ce6:	89 c2                	mov    %eax,%edx
f0100ce8:	83 e2 02             	and    $0x2,%edx
f0100ceb:	52                   	push   %edx
f0100cec:	83 e0 01             	and    $0x1,%eax
f0100cef:	50                   	push   %eax
f0100cf0:	68 e4 6a 10 f0       	push   $0xf0106ae4
f0100cf5:	e8 d8 2d 00 00       	call   f0103ad2 <cprintf>
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
f0100cfa:	83 c4 10             	add    $0x10,%esp
f0100cfd:	c9                   	leave  
f0100cfe:	c3                   	ret    

f0100cff <showmappings>:
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100cff:	55                   	push   %ebp
f0100d00:	89 e5                	mov    %esp,%ebp
f0100d02:	57                   	push   %edi
f0100d03:	56                   	push   %esi
f0100d04:	53                   	push   %ebx
f0100d05:	83 ec 0c             	sub    $0xc,%esp
f0100d08:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100d0b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100d0f:	75 15                	jne    f0100d26 <showmappings+0x27>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
f0100d11:	83 ec 0c             	sub    $0xc,%esp
f0100d14:	68 08 6b 10 f0       	push   $0xf0106b08
f0100d19:	e8 b4 2d 00 00       	call   f0103ad2 <cprintf>
		return 0;
f0100d1e:	83 c4 10             	add    $0x10,%esp
f0100d21:	e9 9a 00 00 00       	jmp    f0100dc0 <showmappings+0xc1>
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
f0100d26:	83 ec 0c             	sub    $0xc,%esp
f0100d29:	ff 76 04             	pushl  0x4(%esi)
f0100d2c:	e8 02 ff ff ff       	call   f0100c33 <xtoi>
f0100d31:	89 c3                	mov    %eax,%ebx
f0100d33:	83 c4 04             	add    $0x4,%esp
f0100d36:	ff 76 08             	pushl  0x8(%esi)
f0100d39:	e8 f5 fe ff ff       	call   f0100c33 <xtoi>
f0100d3e:	89 c7                	mov    %eax,%edi
	cprintf("begin: %x, end: %x\n", begin, end);
f0100d40:	83 c4 0c             	add    $0xc,%esp
f0100d43:	50                   	push   %eax
f0100d44:	53                   	push   %ebx
f0100d45:	68 e6 68 10 f0       	push   $0xf01068e6
f0100d4a:	e8 83 2d 00 00       	call   f0103ad2 <cprintf>
	for (; begin <= end; begin += PGSIZE) {
f0100d4f:	83 c4 10             	add    $0x10,%esp
f0100d52:	eb 68                	jmp    f0100dbc <showmappings+0xbd>
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f0100d54:	83 ec 04             	sub    $0x4,%esp
f0100d57:	6a 01                	push   $0x1
f0100d59:	53                   	push   %ebx
f0100d5a:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0100d60:	e8 7f 06 00 00       	call   f01013e4 <pgdir_walk>
f0100d65:	89 c6                	mov    %eax,%esi
		if (!pte) panic("boot_map_region panic, out of memory");
f0100d67:	83 c4 10             	add    $0x10,%esp
f0100d6a:	85 c0                	test   %eax,%eax
f0100d6c:	75 17                	jne    f0100d85 <showmappings+0x86>
f0100d6e:	83 ec 04             	sub    $0x4,%esp
f0100d71:	68 38 6b 10 f0       	push   $0xf0106b38
f0100d76:	68 d1 00 00 00       	push   $0xd1
f0100d7b:	68 fa 68 10 f0       	push   $0xf01068fa
f0100d80:	e8 0f f3 ff ff       	call   f0100094 <_panic>
		if (*pte & PTE_P) {
f0100d85:	f6 00 01             	testb  $0x1,(%eax)
f0100d88:	74 1b                	je     f0100da5 <showmappings+0xa6>
			cprintf("page %x with ", begin);
f0100d8a:	83 ec 08             	sub    $0x8,%esp
f0100d8d:	53                   	push   %ebx
f0100d8e:	68 09 69 10 f0       	push   $0xf0106909
f0100d93:	e8 3a 2d 00 00       	call   f0103ad2 <cprintf>
			pprint(pte);
f0100d98:	89 34 24             	mov    %esi,(%esp)
f0100d9b:	e8 35 ff ff ff       	call   f0100cd5 <pprint>
f0100da0:	83 c4 10             	add    $0x10,%esp
f0100da3:	eb 11                	jmp    f0100db6 <showmappings+0xb7>
		} else cprintf("page not exist: %x\n", begin);
f0100da5:	83 ec 08             	sub    $0x8,%esp
f0100da8:	53                   	push   %ebx
f0100da9:	68 17 69 10 f0       	push   $0xf0106917
f0100dae:	e8 1f 2d 00 00       	call   f0103ad2 <cprintf>
f0100db3:	83 c4 10             	add    $0x10,%esp
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
		return 0;
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
	cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin <= end; begin += PGSIZE) {
f0100db6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100dbc:	39 fb                	cmp    %edi,%ebx
f0100dbe:	76 94                	jbe    f0100d54 <showmappings+0x55>
			cprintf("page %x with ", begin);
			pprint(pte);
		} else cprintf("page not exist: %x\n", begin);
	}
	return 0;
}
f0100dc0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dc8:	5b                   	pop    %ebx
f0100dc9:	5e                   	pop    %esi
f0100dca:	5f                   	pop    %edi
f0100dcb:	5d                   	pop    %ebp
f0100dcc:	c3                   	ret    

f0100dcd <setm>:

int setm(int argc, char **argv, struct Trapframe *tf) {
f0100dcd:	55                   	push   %ebp
f0100dce:	89 e5                	mov    %esp,%ebp
f0100dd0:	57                   	push   %edi
f0100dd1:	56                   	push   %esi
f0100dd2:	53                   	push   %ebx
f0100dd3:	83 ec 0c             	sub    $0xc,%esp
f0100dd6:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100dd9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100ddd:	75 15                	jne    f0100df4 <setm+0x27>
		cprintf("Usage: setm 0xaddr [0|1 :clear or set] [P|W|U]\n");
f0100ddf:	83 ec 0c             	sub    $0xc,%esp
f0100de2:	68 60 6b 10 f0       	push   $0xf0106b60
f0100de7:	e8 e6 2c 00 00       	call   f0103ad2 <cprintf>
		return 0;
f0100dec:	83 c4 10             	add    $0x10,%esp
f0100def:	e9 85 00 00 00       	jmp    f0100e79 <setm+0xac>
	}
	uint32_t addr = xtoi(argv[1]);
f0100df4:	83 ec 0c             	sub    $0xc,%esp
f0100df7:	ff 76 04             	pushl  0x4(%esi)
f0100dfa:	e8 34 fe ff ff       	call   f0100c33 <xtoi>
f0100dff:	89 c7                	mov    %eax,%edi
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100e01:	83 c4 0c             	add    $0xc,%esp
f0100e04:	6a 01                	push   $0x1
f0100e06:	50                   	push   %eax
f0100e07:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0100e0d:	e8 d2 05 00 00       	call   f01013e4 <pgdir_walk>
f0100e12:	89 c3                	mov    %eax,%ebx
	cprintf("%x before setm: ", addr);
f0100e14:	83 c4 08             	add    $0x8,%esp
f0100e17:	57                   	push   %edi
f0100e18:	68 2b 69 10 f0       	push   $0xf010692b
f0100e1d:	e8 b0 2c 00 00       	call   f0103ad2 <cprintf>
	pprint(pte);
f0100e22:	89 1c 24             	mov    %ebx,(%esp)
f0100e25:	e8 ab fe ff ff       	call   f0100cd5 <pprint>
	uint32_t perm = 0;
	if (argv[3][0] == 'P') perm = PTE_P;
f0100e2a:	8b 46 0c             	mov    0xc(%esi),%eax
f0100e2d:	0f b6 10             	movzbl (%eax),%edx
	if (argv[3][0] == 'W') perm = PTE_W;
f0100e30:	83 c4 10             	add    $0x10,%esp
f0100e33:	b8 02 00 00 00       	mov    $0x2,%eax
f0100e38:	80 fa 57             	cmp    $0x57,%dl
f0100e3b:	74 13                	je     f0100e50 <setm+0x83>
	if (argv[3][0] == 'U') perm = PTE_U;
f0100e3d:	b8 04 00 00 00       	mov    $0x4,%eax
f0100e42:	80 fa 55             	cmp    $0x55,%dl
f0100e45:	74 09                	je     f0100e50 <setm+0x83>
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	cprintf("%x before setm: ", addr);
	pprint(pte);
	uint32_t perm = 0;
f0100e47:	80 fa 50             	cmp    $0x50,%dl
f0100e4a:	0f 94 c0             	sete   %al
f0100e4d:	0f b6 c0             	movzbl %al,%eax
	if (argv[3][0] == 'P') perm = PTE_P;
	if (argv[3][0] == 'W') perm = PTE_W;
	if (argv[3][0] == 'U') perm = PTE_U;
	if (argv[2][0] == '0') 	//clear
f0100e50:	8b 56 08             	mov    0x8(%esi),%edx
f0100e53:	80 3a 30             	cmpb   $0x30,(%edx)
f0100e56:	75 06                	jne    f0100e5e <setm+0x91>
		*pte = *pte & ~perm;
f0100e58:	f7 d0                	not    %eax
f0100e5a:	21 03                	and    %eax,(%ebx)
f0100e5c:	eb 02                	jmp    f0100e60 <setm+0x93>
	else 	//set
		*pte = *pte | perm;
f0100e5e:	09 03                	or     %eax,(%ebx)
	cprintf("%x after  setm: ", addr);
f0100e60:	83 ec 08             	sub    $0x8,%esp
f0100e63:	57                   	push   %edi
f0100e64:	68 3c 69 10 f0       	push   $0xf010693c
f0100e69:	e8 64 2c 00 00       	call   f0103ad2 <cprintf>
	pprint(pte);
f0100e6e:	89 1c 24             	mov    %ebx,(%esp)
f0100e71:	e8 5f fe ff ff       	call   f0100cd5 <pprint>
	return 0;
f0100e76:	83 c4 10             	add    $0x10,%esp
}
f0100e79:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e81:	5b                   	pop    %ebx
f0100e82:	5e                   	pop    %esi
f0100e83:	5f                   	pop    %edi
f0100e84:	5d                   	pop    %ebp
f0100e85:	c3                   	ret    

f0100e86 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e86:	55                   	push   %ebp
f0100e87:	89 e5                	mov    %esp,%ebp
f0100e89:	53                   	push   %ebx
f0100e8a:	83 ec 04             	sub    $0x4,%esp
f0100e8d:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100e8f:	83 3d 38 b2 22 f0 00 	cmpl   $0x0,0xf022b238
f0100e96:	75 0f                	jne    f0100ea7 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e98:	b8 07 e0 26 f0       	mov    $0xf026e007,%eax
f0100e9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ea2:	a3 38 b2 22 f0       	mov    %eax,0xf022b238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100ea7:	83 ec 08             	sub    $0x8,%esp
f0100eaa:	ff 35 38 b2 22 f0    	pushl  0xf022b238
f0100eb0:	68 2c 6c 10 f0       	push   $0xf0106c2c
f0100eb5:	e8 18 2c 00 00       	call   f0103ad2 <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100eba:	89 d8                	mov    %ebx,%eax
f0100ebc:	03 05 38 b2 22 f0    	add    0xf022b238,%eax
f0100ec2:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100ec7:	83 c4 08             	add    $0x8,%esp
f0100eca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ecf:	50                   	push   %eax
f0100ed0:	68 45 6c 10 f0       	push   $0xf0106c45
f0100ed5:	e8 f8 2b 00 00       	call   f0103ad2 <cprintf>
	if (n != 0) {
f0100eda:	83 c4 10             	add    $0x10,%esp
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
		return next;
	} else return nextfree;
f0100edd:	a1 38 b2 22 f0       	mov    0xf022b238,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if (n != 0) {
f0100ee2:	85 db                	test   %ebx,%ebx
f0100ee4:	74 13                	je     f0100ef9 <boot_alloc+0x73>
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100ee6:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100eed:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ef3:	89 15 38 b2 22 f0    	mov    %edx,0xf022b238
		return next;
	} else return nextfree;

	return NULL;
}
f0100ef9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100efc:	c9                   	leave  
f0100efd:	c3                   	ret    

f0100efe <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100efe:	89 d1                	mov    %edx,%ecx
f0100f00:	c1 e9 16             	shr    $0x16,%ecx
f0100f03:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100f06:	a8 01                	test   $0x1,%al
f0100f08:	74 52                	je     f0100f5c <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f0f:	89 c1                	mov    %eax,%ecx
f0100f11:	c1 e9 0c             	shr    $0xc,%ecx
f0100f14:	3b 0d 90 be 22 f0    	cmp    0xf022be90,%ecx
f0100f1a:	72 1b                	jb     f0100f37 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100f1c:	55                   	push   %ebp
f0100f1d:	89 e5                	mov    %esp,%ebp
f0100f1f:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f22:	50                   	push   %eax
f0100f23:	68 3c 65 10 f0       	push   $0xf010653c
f0100f28:	68 92 03 00 00       	push   $0x392
f0100f2d:	68 58 6c 10 f0       	push   $0xf0106c58
f0100f32:	e8 5d f1 ff ff       	call   f0100094 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100f37:	c1 ea 0c             	shr    $0xc,%edx
f0100f3a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f40:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100f47:	89 c2                	mov    %eax,%edx
f0100f49:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f51:	85 d2                	test   %edx,%edx
f0100f53:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100f58:	0f 44 c2             	cmove  %edx,%eax
f0100f5b:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100f5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100f61:	c3                   	ret    

f0100f62 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100f62:	55                   	push   %ebp
f0100f63:	89 e5                	mov    %esp,%ebp
f0100f65:	57                   	push   %edi
f0100f66:	56                   	push   %esi
f0100f67:	53                   	push   %ebx
f0100f68:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f6b:	84 c0                	test   %al,%al
f0100f6d:	0f 85 a0 02 00 00    	jne    f0101213 <check_page_free_list+0x2b1>
f0100f73:	e9 ad 02 00 00       	jmp    f0101225 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100f78:	83 ec 04             	sub    $0x4,%esp
f0100f7b:	68 58 70 10 f0       	push   $0xf0107058
f0100f80:	68 be 02 00 00       	push   $0x2be
f0100f85:	68 58 6c 10 f0       	push   $0xf0106c58
f0100f8a:	e8 05 f1 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100f8f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f92:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f95:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f98:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f9b:	89 c2                	mov    %eax,%edx
f0100f9d:	2b 15 98 be 22 f0    	sub    0xf022be98,%edx
f0100fa3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100fa9:	0f 95 c2             	setne  %dl
f0100fac:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100faf:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100fb3:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100fb5:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fb9:	8b 00                	mov    (%eax),%eax
f0100fbb:	85 c0                	test   %eax,%eax
f0100fbd:	75 dc                	jne    f0100f9b <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100fbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fc2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fcb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fce:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100fd0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100fd3:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fd8:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100fdd:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0100fe3:	eb 53                	jmp    f0101038 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fe5:	89 d8                	mov    %ebx,%eax
f0100fe7:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f0100fed:	c1 f8 03             	sar    $0x3,%eax
f0100ff0:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ff3:	89 c2                	mov    %eax,%edx
f0100ff5:	c1 ea 16             	shr    $0x16,%edx
f0100ff8:	39 f2                	cmp    %esi,%edx
f0100ffa:	73 3a                	jae    f0101036 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ffc:	89 c2                	mov    %eax,%edx
f0100ffe:	c1 ea 0c             	shr    $0xc,%edx
f0101001:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f0101007:	72 12                	jb     f010101b <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101009:	50                   	push   %eax
f010100a:	68 3c 65 10 f0       	push   $0xf010653c
f010100f:	6a 58                	push   $0x58
f0101011:	68 64 6c 10 f0       	push   $0xf0106c64
f0101016:	e8 79 f0 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f010101b:	83 ec 04             	sub    $0x4,%esp
f010101e:	68 80 00 00 00       	push   $0x80
f0101023:	68 97 00 00 00       	push   $0x97
f0101028:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010102d:	50                   	push   %eax
f010102e:	e8 0a 47 00 00       	call   f010573d <memset>
f0101033:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101036:	8b 1b                	mov    (%ebx),%ebx
f0101038:	85 db                	test   %ebx,%ebx
f010103a:	75 a9                	jne    f0100fe5 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f010103c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101041:	e8 40 fe ff ff       	call   f0100e86 <boot_alloc>
f0101046:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101049:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010104f:	8b 0d 98 be 22 f0    	mov    0xf022be98,%ecx
		assert(pp < pages + npages);
f0101055:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f010105a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010105d:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0101060:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101063:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101066:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010106b:	e9 52 01 00 00       	jmp    f01011c2 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101070:	39 ca                	cmp    %ecx,%edx
f0101072:	73 19                	jae    f010108d <check_page_free_list+0x12b>
f0101074:	68 72 6c 10 f0       	push   $0xf0106c72
f0101079:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010107e:	68 d8 02 00 00       	push   $0x2d8
f0101083:	68 58 6c 10 f0       	push   $0xf0106c58
f0101088:	e8 07 f0 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f010108d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101090:	72 19                	jb     f01010ab <check_page_free_list+0x149>
f0101092:	68 93 6c 10 f0       	push   $0xf0106c93
f0101097:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010109c:	68 d9 02 00 00       	push   $0x2d9
f01010a1:	68 58 6c 10 f0       	push   $0xf0106c58
f01010a6:	e8 e9 ef ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010ab:	89 d0                	mov    %edx,%eax
f01010ad:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01010b0:	a8 07                	test   $0x7,%al
f01010b2:	74 19                	je     f01010cd <check_page_free_list+0x16b>
f01010b4:	68 7c 70 10 f0       	push   $0xf010707c
f01010b9:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01010be:	68 da 02 00 00       	push   $0x2da
f01010c3:	68 58 6c 10 f0       	push   $0xf0106c58
f01010c8:	e8 c7 ef ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010cd:	c1 f8 03             	sar    $0x3,%eax
f01010d0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010d3:	85 c0                	test   %eax,%eax
f01010d5:	75 19                	jne    f01010f0 <check_page_free_list+0x18e>
f01010d7:	68 a7 6c 10 f0       	push   $0xf0106ca7
f01010dc:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01010e1:	68 dd 02 00 00       	push   $0x2dd
f01010e6:	68 58 6c 10 f0       	push   $0xf0106c58
f01010eb:	e8 a4 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01010f0:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010f5:	75 19                	jne    f0101110 <check_page_free_list+0x1ae>
f01010f7:	68 b8 6c 10 f0       	push   $0xf0106cb8
f01010fc:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101101:	68 de 02 00 00       	push   $0x2de
f0101106:	68 58 6c 10 f0       	push   $0xf0106c58
f010110b:	e8 84 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101110:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101115:	75 19                	jne    f0101130 <check_page_free_list+0x1ce>
f0101117:	68 b0 70 10 f0       	push   $0xf01070b0
f010111c:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101121:	68 df 02 00 00       	push   $0x2df
f0101126:	68 58 6c 10 f0       	push   $0xf0106c58
f010112b:	e8 64 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101130:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101135:	75 19                	jne    f0101150 <check_page_free_list+0x1ee>
f0101137:	68 d1 6c 10 f0       	push   $0xf0106cd1
f010113c:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101141:	68 e0 02 00 00       	push   $0x2e0
f0101146:	68 58 6c 10 f0       	push   $0xf0106c58
f010114b:	e8 44 ef ff ff       	call   f0100094 <_panic>
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101150:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101155:	0f 86 f1 00 00 00    	jbe    f010124c <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010115b:	89 c7                	mov    %eax,%edi
f010115d:	c1 ef 0c             	shr    $0xc,%edi
f0101160:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0101163:	77 12                	ja     f0101177 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101165:	50                   	push   %eax
f0101166:	68 3c 65 10 f0       	push   $0xf010653c
f010116b:	6a 58                	push   $0x58
f010116d:	68 64 6c 10 f0       	push   $0xf0106c64
f0101172:	e8 1d ef ff ff       	call   f0100094 <_panic>
f0101177:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f010117d:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101180:	0f 86 b6 00 00 00    	jbe    f010123c <check_page_free_list+0x2da>
f0101186:	68 d4 70 10 f0       	push   $0xf01070d4
f010118b:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101190:	68 e3 02 00 00       	push   $0x2e3
f0101195:	68 58 6c 10 f0       	push   $0xf0106c58
f010119a:	e8 f5 ee ff ff       	call   f0100094 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010119f:	68 eb 6c 10 f0       	push   $0xf0106ceb
f01011a4:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01011a9:	68 e5 02 00 00       	push   $0x2e5
f01011ae:	68 58 6c 10 f0       	push   $0xf0106c58
f01011b3:	e8 dc ee ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01011b8:	83 c6 01             	add    $0x1,%esi
f01011bb:	eb 03                	jmp    f01011c0 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f01011bd:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011c0:	8b 12                	mov    (%edx),%edx
f01011c2:	85 d2                	test   %edx,%edx
f01011c4:	0f 85 a6 fe ff ff    	jne    f0101070 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01011ca:	85 f6                	test   %esi,%esi
f01011cc:	7f 19                	jg     f01011e7 <check_page_free_list+0x285>
f01011ce:	68 08 6d 10 f0       	push   $0xf0106d08
f01011d3:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01011d8:	68 ed 02 00 00       	push   $0x2ed
f01011dd:	68 58 6c 10 f0       	push   $0xf0106c58
f01011e2:	e8 ad ee ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f01011e7:	85 db                	test   %ebx,%ebx
f01011e9:	7f 19                	jg     f0101204 <check_page_free_list+0x2a2>
f01011eb:	68 1a 6d 10 f0       	push   $0xf0106d1a
f01011f0:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01011f5:	68 ee 02 00 00       	push   $0x2ee
f01011fa:	68 58 6c 10 f0       	push   $0xf0106c58
f01011ff:	e8 90 ee ff ff       	call   f0100094 <_panic>
	cprintf("check_page_free_list done\n");
f0101204:	83 ec 0c             	sub    $0xc,%esp
f0101207:	68 2b 6d 10 f0       	push   $0xf0106d2b
f010120c:	e8 c1 28 00 00       	call   f0103ad2 <cprintf>
}
f0101211:	eb 49                	jmp    f010125c <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101213:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101218:	85 c0                	test   %eax,%eax
f010121a:	0f 85 6f fd ff ff    	jne    f0100f8f <check_page_free_list+0x2d>
f0101220:	e9 53 fd ff ff       	jmp    f0100f78 <check_page_free_list+0x16>
f0101225:	83 3d 40 b2 22 f0 00 	cmpl   $0x0,0xf022b240
f010122c:	0f 84 46 fd ff ff    	je     f0100f78 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101232:	be 00 04 00 00       	mov    $0x400,%esi
f0101237:	e9 a1 fd ff ff       	jmp    f0100fdd <check_page_free_list+0x7b>
		assert(page2pa(pp) != EXTPHYSMEM);
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010123c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101241:	0f 85 76 ff ff ff    	jne    f01011bd <check_page_free_list+0x25b>
f0101247:	e9 53 ff ff ff       	jmp    f010119f <check_page_free_list+0x23d>
f010124c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101251:	0f 85 61 ff ff ff    	jne    f01011b8 <check_page_free_list+0x256>
f0101257:	e9 43 ff ff ff       	jmp    f010119f <check_page_free_list+0x23d>
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
	cprintf("check_page_free_list done\n");
}
f010125c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010125f:	5b                   	pop    %ebx
f0101260:	5e                   	pop    %esi
f0101261:	5f                   	pop    %edi
f0101262:	5d                   	pop    %ebp
f0101263:	c3                   	ret    

f0101264 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101264:	55                   	push   %ebp
f0101265:	89 e5                	mov    %esp,%ebp
f0101267:	56                   	push   %esi
f0101268:	53                   	push   %ebx
	//     page tables and other data structures?
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	cprintf("MPENTRY_PADDR: %x\n", MPENTRY_PADDR);
f0101269:	83 ec 08             	sub    $0x8,%esp
f010126c:	68 00 70 00 00       	push   $0x7000
f0101271:	68 46 6d 10 f0       	push   $0xf0106d46
f0101276:	e8 57 28 00 00       	call   f0103ad2 <cprintf>
	cprintf("npages_basemem: %x\n", npages_basemem);
f010127b:	83 c4 08             	add    $0x8,%esp
f010127e:	ff 35 44 b2 22 f0    	pushl  0xf022b244
f0101284:	68 59 6d 10 f0       	push   $0xf0106d59
f0101289:	e8 44 28 00 00       	call   f0103ad2 <cprintf>
f010128e:	8b 0d 40 b2 22 f0    	mov    0xf022b240,%ecx
f0101294:	83 c4 10             	add    $0x10,%esp
f0101297:	b8 08 00 00 00       	mov    $0x8,%eax
	size_t i;
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
		pages[i].pp_ref = 0;
f010129c:	89 c2                	mov    %eax,%edx
f010129e:	03 15 98 be 22 f0    	add    0xf022be98,%edx
f01012a4:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f01012aa:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f01012ac:	89 c1                	mov    %eax,%ecx
f01012ae:	03 0d 98 be 22 f0    	add    0xf022be98,%ecx
f01012b4:	83 c0 08             	add    $0x8,%eax
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	cprintf("MPENTRY_PADDR: %x\n", MPENTRY_PADDR);
	cprintf("npages_basemem: %x\n", npages_basemem);
	size_t i;
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
f01012b7:	83 f8 38             	cmp    $0x38,%eax
f01012ba:	75 e0                	jne    f010129c <page_init+0x38>
f01012bc:	89 0d 40 b2 22 f0    	mov    %ecx,0xf022b240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	// int med = (int)ROUNDUP(kern_top - 0xf0000000, PGSIZE)/PGSIZE;
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f01012c2:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
f01012c7:	05 ff 0f 02 10       	add    $0x10020fff,%eax
f01012cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01012d1:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012d7:	85 c0                	test   %eax,%eax
f01012d9:	0f 48 c2             	cmovs  %edx,%eax
f01012dc:	c1 f8 0c             	sar    $0xc,%eax
f01012df:	89 c3                	mov    %eax,%ebx
	// med = (int) percpu_kstacks[NCPU-1];
	cprintf("med: %x\n", med);
f01012e1:	83 ec 08             	sub    $0x8,%esp
f01012e4:	50                   	push   %eax
f01012e5:	68 6d 6d 10 f0       	push   $0xf0106d6d
f01012ea:	e8 e3 27 00 00       	call   f0103ad2 <cprintf>
	for (i = med; i < npages; i++) {
f01012ef:	89 da                	mov    %ebx,%edx
f01012f1:	8b 35 40 b2 22 f0    	mov    0xf022b240,%esi
f01012f7:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f01012fe:	83 c4 10             	add    $0x10,%esp
f0101301:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101306:	eb 23                	jmp    f010132b <page_init+0xc7>
		pages[i].pp_ref = 0;
f0101308:	89 c1                	mov    %eax,%ecx
f010130a:	03 0d 98 be 22 f0    	add    0xf022be98,%ecx
f0101310:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101316:	89 31                	mov    %esi,(%ecx)
		page_free_list = &pages[i];
f0101318:	89 c6                	mov    %eax,%esi
f010131a:	03 35 98 be 22 f0    	add    0xf022be98,%esi
	}
	// int med = (int)ROUNDUP(kern_top - 0xf0000000, PGSIZE)/PGSIZE;
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	// med = (int) percpu_kstacks[NCPU-1];
	cprintf("med: %x\n", med);
	for (i = med; i < npages; i++) {
f0101320:	83 c2 01             	add    $0x1,%edx
f0101323:	83 c0 08             	add    $0x8,%eax
f0101326:	b9 01 00 00 00       	mov    $0x1,%ecx
f010132b:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f0101331:	72 d5                	jb     f0101308 <page_init+0xa4>
f0101333:	84 c9                	test   %cl,%cl
f0101335:	74 06                	je     f010133d <page_init+0xd9>
f0101337:	89 35 40 b2 22 f0    	mov    %esi,0xf022b240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f010133d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101340:	5b                   	pop    %ebx
f0101341:	5e                   	pop    %esi
f0101342:	5d                   	pop    %ebp
f0101343:	c3                   	ret    

f0101344 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101344:	55                   	push   %ebp
f0101345:	89 e5                	mov    %esp,%ebp
f0101347:	53                   	push   %ebx
f0101348:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list) {
f010134b:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0101351:	85 db                	test   %ebx,%ebx
f0101353:	74 52                	je     f01013a7 <page_alloc+0x63>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f0101355:	8b 03                	mov    (%ebx),%eax
f0101357:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
		// cprintf("alocccccccccccccc pa: %x\n", page2pa(ret));
		if (alloc_flags & ALLOC_ZERO) 
f010135c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101360:	74 45                	je     f01013a7 <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101362:	89 d8                	mov    %ebx,%eax
f0101364:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f010136a:	c1 f8 03             	sar    $0x3,%eax
f010136d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101370:	89 c2                	mov    %eax,%edx
f0101372:	c1 ea 0c             	shr    $0xc,%edx
f0101375:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f010137b:	72 12                	jb     f010138f <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010137d:	50                   	push   %eax
f010137e:	68 3c 65 10 f0       	push   $0xf010653c
f0101383:	6a 58                	push   $0x58
f0101385:	68 64 6c 10 f0       	push   $0xf0106c64
f010138a:	e8 05 ed ff ff       	call   f0100094 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f010138f:	83 ec 04             	sub    $0x4,%esp
f0101392:	68 00 10 00 00       	push   $0x1000
f0101397:	6a 00                	push   $0x0
f0101399:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010139e:	50                   	push   %eax
f010139f:	e8 99 43 00 00       	call   f010573d <memset>
f01013a4:	83 c4 10             	add    $0x10,%esp
		return ret;
	}
	return NULL;
}
f01013a7:	89 d8                	mov    %ebx,%eax
f01013a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013ac:	c9                   	leave  
f01013ad:	c3                   	ret    

f01013ae <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01013ae:	55                   	push   %ebp
f01013af:	89 e5                	mov    %esp,%ebp
f01013b1:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("freeeeeeeeeee pa: %x\n", page2pa(pp));
	pp->pp_link = page_free_list;
f01013b4:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f01013ba:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01013bc:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
}
f01013c1:	5d                   	pop    %ebp
f01013c2:	c3                   	ret    

f01013c3 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01013c3:	55                   	push   %ebp
f01013c4:	89 e5                	mov    %esp,%ebp
f01013c6:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01013c9:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01013cd:	83 e8 01             	sub    $0x1,%eax
f01013d0:	66 89 42 04          	mov    %ax,0x4(%edx)
f01013d4:	66 85 c0             	test   %ax,%ax
f01013d7:	75 09                	jne    f01013e2 <page_decref+0x1f>
		page_free(pp);
f01013d9:	52                   	push   %edx
f01013da:	e8 cf ff ff ff       	call   f01013ae <page_free>
f01013df:	83 c4 04             	add    $0x4,%esp
}
f01013e2:	c9                   	leave  
f01013e3:	c3                   	ret    

f01013e4 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01013e4:	55                   	push   %ebp
f01013e5:	89 e5                	mov    %esp,%ebp
f01013e7:	56                   	push   %esi
f01013e8:	53                   	push   %ebx
f01013e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int dindex = PDX(va), tindex = PTX(va);
f01013ec:	89 de                	mov    %ebx,%esi
f01013ee:	c1 ee 0c             	shr    $0xc,%esi
f01013f1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f01013f7:	c1 eb 16             	shr    $0x16,%ebx
f01013fa:	c1 e3 02             	shl    $0x2,%ebx
f01013fd:	03 5d 08             	add    0x8(%ebp),%ebx
f0101400:	f6 03 01             	testb  $0x1,(%ebx)
f0101403:	75 2d                	jne    f0101432 <pgdir_walk+0x4e>
		if (create) {
f0101405:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101409:	74 59                	je     f0101464 <pgdir_walk+0x80>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f010140b:	83 ec 0c             	sub    $0xc,%esp
f010140e:	6a 01                	push   $0x1
f0101410:	e8 2f ff ff ff       	call   f0101344 <page_alloc>
			if (!pg) return NULL;	//allocation fails
f0101415:	83 c4 10             	add    $0x10,%esp
f0101418:	85 c0                	test   %eax,%eax
f010141a:	74 4f                	je     f010146b <pgdir_walk+0x87>
			pg->pp_ref++;
f010141c:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f0101421:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f0101427:	c1 f8 03             	sar    $0x3,%eax
f010142a:	c1 e0 0c             	shl    $0xc,%eax
f010142d:	83 c8 07             	or     $0x7,%eax
f0101430:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f0101432:	8b 03                	mov    (%ebx),%eax
f0101434:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101439:	89 c2                	mov    %eax,%edx
f010143b:	c1 ea 0c             	shr    $0xc,%edx
f010143e:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f0101444:	72 15                	jb     f010145b <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101446:	50                   	push   %eax
f0101447:	68 3c 65 10 f0       	push   $0xf010653c
f010144c:	68 be 01 00 00       	push   $0x1be
f0101451:	68 58 6c 10 f0       	push   $0xf0106c58
f0101456:	e8 39 ec ff ff       	call   f0100094 <_panic>
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f010145b:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0101462:	eb 0c                	jmp    f0101470 <pgdir_walk+0x8c>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f0101464:	b8 00 00 00 00       	mov    $0x0,%eax
f0101469:	eb 05                	jmp    f0101470 <pgdir_walk+0x8c>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f010146b:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f0101470:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101473:	5b                   	pop    %ebx
f0101474:	5e                   	pop    %esi
f0101475:	5d                   	pop    %ebp
f0101476:	c3                   	ret    

f0101477 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101477:	55                   	push   %ebp
f0101478:	89 e5                	mov    %esp,%ebp
f010147a:	57                   	push   %edi
f010147b:	56                   	push   %esi
f010147c:	53                   	push   %ebx
f010147d:	83 ec 1c             	sub    $0x1c,%esp
f0101480:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101483:	89 d7                	mov    %edx,%edi
f0101485:	89 cb                	mov    %ecx,%ebx
	int i;
	cprintf("thiscpu: %x\n", thiscpu);
f0101487:	e8 d0 48 00 00       	call   f0105d5c <cpunum>
f010148c:	83 ec 08             	sub    $0x8,%esp
f010148f:	6b c0 74             	imul   $0x74,%eax,%eax
f0101492:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0101497:	50                   	push   %eax
f0101498:	68 76 6d 10 f0       	push   $0xf0106d76
f010149d:	e8 30 26 00 00       	call   f0103ad2 <cprintf>
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f01014a2:	83 c4 0c             	add    $0xc,%esp
f01014a5:	ff 75 08             	pushl  0x8(%ebp)
f01014a8:	57                   	push   %edi
f01014a9:	68 1c 71 10 f0       	push   $0xf010711c
f01014ae:	e8 1f 26 00 00       	call   f0103ad2 <cprintf>
f01014b3:	c1 eb 0c             	shr    $0xc,%ebx
f01014b6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01014b9:	83 c4 10             	add    $0x10,%esp
f01014bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01014bf:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f01014c4:	29 df                	sub    %ebx,%edi
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f01014c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014c9:	83 c8 01             	or     $0x1,%eax
f01014cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("thiscpu: %x\n", thiscpu);
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01014cf:	eb 3f                	jmp    f0101510 <boot_map_region+0x99>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f01014d1:	83 ec 04             	sub    $0x4,%esp
f01014d4:	6a 01                	push   $0x1
f01014d6:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01014d9:	50                   	push   %eax
f01014da:	ff 75 e0             	pushl  -0x20(%ebp)
f01014dd:	e8 02 ff ff ff       	call   f01013e4 <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f01014e2:	83 c4 10             	add    $0x10,%esp
f01014e5:	85 c0                	test   %eax,%eax
f01014e7:	75 17                	jne    f0101500 <boot_map_region+0x89>
f01014e9:	83 ec 04             	sub    $0x4,%esp
f01014ec:	68 38 6b 10 f0       	push   $0xf0106b38
f01014f1:	68 dd 01 00 00       	push   $0x1dd
f01014f6:	68 58 6c 10 f0       	push   $0xf0106c58
f01014fb:	e8 94 eb ff ff       	call   f0100094 <_panic>
		*pte = pa | perm | PTE_P;
f0101500:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101503:	09 da                	or     %ebx,%edx
f0101505:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("thiscpu: %x\n", thiscpu);
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101507:	83 c6 01             	add    $0x1,%esi
f010150a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101510:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101513:	75 bc                	jne    f01014d1 <boot_map_region+0x5a>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
f0101515:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101518:	5b                   	pop    %ebx
f0101519:	5e                   	pop    %esi
f010151a:	5f                   	pop    %edi
f010151b:	5d                   	pop    %ebp
f010151c:	c3                   	ret    

f010151d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010151d:	55                   	push   %ebp
f010151e:	89 e5                	mov    %esp,%ebp
f0101520:	53                   	push   %ebx
f0101521:	83 ec 08             	sub    $0x8,%esp
f0101524:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f0101527:	6a 00                	push   $0x0
f0101529:	ff 75 0c             	pushl  0xc(%ebp)
f010152c:	ff 75 08             	pushl  0x8(%ebp)
f010152f:	e8 b0 fe ff ff       	call   f01013e4 <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f0101534:	83 c4 10             	add    $0x10,%esp
f0101537:	85 c0                	test   %eax,%eax
f0101539:	74 37                	je     f0101572 <page_lookup+0x55>
f010153b:	f6 00 01             	testb  $0x1,(%eax)
f010153e:	74 39                	je     f0101579 <page_lookup+0x5c>
	if (pte_store)
f0101540:	85 db                	test   %ebx,%ebx
f0101542:	74 02                	je     f0101546 <page_lookup+0x29>
		*pte_store = pte;	//found and set
f0101544:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101546:	8b 00                	mov    (%eax),%eax
f0101548:	c1 e8 0c             	shr    $0xc,%eax
f010154b:	3b 05 90 be 22 f0    	cmp    0xf022be90,%eax
f0101551:	72 14                	jb     f0101567 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101553:	83 ec 04             	sub    $0x4,%esp
f0101556:	68 50 71 10 f0       	push   $0xf0107150
f010155b:	6a 51                	push   $0x51
f010155d:	68 64 6c 10 f0       	push   $0xf0106c64
f0101562:	e8 2d eb ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0101567:	8b 15 98 be 22 f0    	mov    0xf022be98,%edx
f010156d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(PTE_ADDR(*pte));		
f0101570:	eb 0c                	jmp    f010157e <page_lookup+0x61>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f0101572:	b8 00 00 00 00       	mov    $0x0,%eax
f0101577:	eb 05                	jmp    f010157e <page_lookup+0x61>
f0101579:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f010157e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101581:	c9                   	leave  
f0101582:	c3                   	ret    

f0101583 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101583:	55                   	push   %ebp
f0101584:	89 e5                	mov    %esp,%ebp
f0101586:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101589:	e8 ce 47 00 00       	call   f0105d5c <cpunum>
f010158e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101591:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0101598:	74 16                	je     f01015b0 <tlb_invalidate+0x2d>
f010159a:	e8 bd 47 00 00       	call   f0105d5c <cpunum>
f010159f:	6b c0 74             	imul   $0x74,%eax,%eax
f01015a2:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01015a8:	8b 55 08             	mov    0x8(%ebp),%edx
f01015ab:	39 50 60             	cmp    %edx,0x60(%eax)
f01015ae:	75 06                	jne    f01015b6 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01015b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015b3:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01015b6:	c9                   	leave  
f01015b7:	c3                   	ret    

f01015b8 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01015b8:	55                   	push   %ebp
f01015b9:	89 e5                	mov    %esp,%ebp
f01015bb:	56                   	push   %esi
f01015bc:	53                   	push   %ebx
f01015bd:	83 ec 14             	sub    $0x14,%esp
f01015c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01015c3:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f01015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01015c9:	50                   	push   %eax
f01015ca:	56                   	push   %esi
f01015cb:	53                   	push   %ebx
f01015cc:	e8 4c ff ff ff       	call   f010151d <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f01015d1:	83 c4 10             	add    $0x10,%esp
f01015d4:	85 c0                	test   %eax,%eax
f01015d6:	74 27                	je     f01015ff <page_remove+0x47>
f01015d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01015db:	f6 02 01             	testb  $0x1,(%edx)
f01015de:	74 1f                	je     f01015ff <page_remove+0x47>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f01015e0:	83 ec 0c             	sub    $0xc,%esp
f01015e3:	50                   	push   %eax
f01015e4:	e8 da fd ff ff       	call   f01013c3 <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f01015e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
f01015f2:	83 c4 08             	add    $0x8,%esp
f01015f5:	56                   	push   %esi
f01015f6:	53                   	push   %ebx
f01015f7:	e8 87 ff ff ff       	call   f0101583 <tlb_invalidate>
f01015fc:	83 c4 10             	add    $0x10,%esp
}
f01015ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101602:	5b                   	pop    %ebx
f0101603:	5e                   	pop    %esi
f0101604:	5d                   	pop    %ebp
f0101605:	c3                   	ret    

f0101606 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101606:	55                   	push   %ebp
f0101607:	89 e5                	mov    %esp,%ebp
f0101609:	57                   	push   %edi
f010160a:	56                   	push   %esi
f010160b:	53                   	push   %ebx
f010160c:	83 ec 10             	sub    $0x10,%esp
f010160f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101612:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f0101615:	6a 01                	push   $0x1
f0101617:	57                   	push   %edi
f0101618:	ff 75 08             	pushl  0x8(%ebp)
f010161b:	e8 c4 fd ff ff       	call   f01013e4 <pgdir_walk>
	if (!pte) 	//page table not allocated
f0101620:	83 c4 10             	add    $0x10,%esp
f0101623:	85 c0                	test   %eax,%eax
f0101625:	74 38                	je     f010165f <page_insert+0x59>
f0101627:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f0101629:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f010162e:	f6 00 01             	testb  $0x1,(%eax)
f0101631:	74 0f                	je     f0101642 <page_insert+0x3c>
		page_remove(pgdir, va);
f0101633:	83 ec 08             	sub    $0x8,%esp
f0101636:	57                   	push   %edi
f0101637:	ff 75 08             	pushl  0x8(%ebp)
f010163a:	e8 79 ff ff ff       	call   f01015b8 <page_remove>
f010163f:	83 c4 10             	add    $0x10,%esp
	*pte = page2pa(pp) | perm | PTE_P;
f0101642:	2b 1d 98 be 22 f0    	sub    0xf022be98,%ebx
f0101648:	c1 fb 03             	sar    $0x3,%ebx
f010164b:	c1 e3 0c             	shl    $0xc,%ebx
f010164e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101651:	83 c8 01             	or     $0x1,%eax
f0101654:	09 c3                	or     %eax,%ebx
f0101656:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101658:	b8 00 00 00 00       	mov    $0x0,%eax
f010165d:	eb 05                	jmp    f0101664 <page_insert+0x5e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f010165f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
		page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0101664:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101667:	5b                   	pop    %ebx
f0101668:	5e                   	pop    %esi
f0101669:	5f                   	pop    %edi
f010166a:	5d                   	pop    %ebp
f010166b:	c3                   	ret    

f010166c <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010166c:	55                   	push   %ebp
f010166d:	89 e5                	mov    %esp,%ebp
f010166f:	53                   	push   %ebx
f0101670:	83 ec 04             	sub    $0x4,%esp
f0101673:	8b 45 08             	mov    0x8(%ebp),%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(pa+size, PGSIZE);
f0101676:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101679:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f0101680:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	size -= pa;
f0101685:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010168b:	29 c3                	sub    %eax,%ebx
	if (base+size >= MMIOLIM) panic("not enough memory");
f010168d:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f0101693:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f0101696:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f010169c:	76 17                	jbe    f01016b5 <mmio_map_region+0x49>
f010169e:	83 ec 04             	sub    $0x4,%esp
f01016a1:	68 83 6d 10 f0       	push   $0xf0106d83
f01016a6:	68 6c 02 00 00       	push   $0x26c
f01016ab:	68 58 6c 10 f0       	push   $0xf0106c58
f01016b0:	e8 df e9 ff ff       	call   f0100094 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f01016b5:	83 ec 08             	sub    $0x8,%esp
f01016b8:	6a 1a                	push   $0x1a
f01016ba:	50                   	push   %eax
f01016bb:	89 d9                	mov    %ebx,%ecx
f01016bd:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f01016c2:	e8 b0 fd ff ff       	call   f0101477 <boot_map_region>
	base += size;
f01016c7:	a1 00 13 12 f0       	mov    0xf0121300,%eax
f01016cc:	01 c3                	add    %eax,%ebx
f01016ce:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
	return (void*) (base - size);
	// panic("mmio_map_region not implemented");
}
f01016d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016d7:	c9                   	leave  
f01016d8:	c3                   	ret    

f01016d9 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016d9:	55                   	push   %ebp
f01016da:	89 e5                	mov    %esp,%ebp
f01016dc:	57                   	push   %edi
f01016dd:	56                   	push   %esi
f01016de:	53                   	push   %ebx
f01016df:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01016e2:	6a 15                	push   $0x15
f01016e4:	e8 6a 22 00 00       	call   f0103953 <mc146818_read>
f01016e9:	89 c3                	mov    %eax,%ebx
f01016eb:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01016f2:	e8 5c 22 00 00       	call   f0103953 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016f7:	c1 e0 08             	shl    $0x8,%eax
f01016fa:	09 d8                	or     %ebx,%eax
f01016fc:	c1 e0 0a             	shl    $0xa,%eax
f01016ff:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101705:	85 c0                	test   %eax,%eax
f0101707:	0f 48 c2             	cmovs  %edx,%eax
f010170a:	c1 f8 0c             	sar    $0xc,%eax
f010170d:	a3 44 b2 22 f0       	mov    %eax,0xf022b244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101712:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101719:	e8 35 22 00 00       	call   f0103953 <mc146818_read>
f010171e:	89 c3                	mov    %eax,%ebx
f0101720:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101727:	e8 27 22 00 00       	call   f0103953 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010172c:	c1 e0 08             	shl    $0x8,%eax
f010172f:	09 d8                	or     %ebx,%eax
f0101731:	c1 e0 0a             	shl    $0xa,%eax
f0101734:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010173a:	83 c4 10             	add    $0x10,%esp
f010173d:	85 c0                	test   %eax,%eax
f010173f:	0f 48 c2             	cmovs  %edx,%eax
f0101742:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101745:	85 c0                	test   %eax,%eax
f0101747:	74 0e                	je     f0101757 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101749:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010174f:	89 15 90 be 22 f0    	mov    %edx,0xf022be90
f0101755:	eb 0c                	jmp    f0101763 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101757:	8b 15 44 b2 22 f0    	mov    0xf022b244,%edx
f010175d:	89 15 90 be 22 f0    	mov    %edx,0xf022be90

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101763:	c1 e0 0c             	shl    $0xc,%eax
f0101766:	c1 e8 0a             	shr    $0xa,%eax
f0101769:	50                   	push   %eax
f010176a:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f010176f:	c1 e0 0c             	shl    $0xc,%eax
f0101772:	c1 e8 0a             	shr    $0xa,%eax
f0101775:	50                   	push   %eax
f0101776:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f010177b:	c1 e0 0c             	shl    $0xc,%eax
f010177e:	c1 e8 0a             	shr    $0xa,%eax
f0101781:	50                   	push   %eax
f0101782:	68 70 71 10 f0       	push   $0xf0107170
f0101787:	e8 46 23 00 00       	call   f0103ad2 <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010178c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101791:	e8 f0 f6 ff ff       	call   f0100e86 <boot_alloc>
f0101796:	a3 94 be 22 f0       	mov    %eax,0xf022be94
	memset(kern_pgdir, 0, PGSIZE);
f010179b:	83 c4 0c             	add    $0xc,%esp
f010179e:	68 00 10 00 00       	push   $0x1000
f01017a3:	6a 00                	push   $0x0
f01017a5:	50                   	push   %eax
f01017a6:	e8 92 3f 00 00       	call   f010573d <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01017ab:	a1 94 be 22 f0       	mov    0xf022be94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01017b0:	83 c4 10             	add    $0x10,%esp
f01017b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01017b8:	77 15                	ja     f01017cf <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01017ba:	50                   	push   %eax
f01017bb:	68 88 65 10 f0       	push   $0xf0106588
f01017c0:	68 96 00 00 00       	push   $0x96
f01017c5:	68 58 6c 10 f0       	push   $0xf0106c58
f01017ca:	e8 c5 e8 ff ff       	call   f0100094 <_panic>
f01017cf:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01017d5:	83 ca 05             	or     $0x5,%edx
f01017d8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f01017de:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f01017e3:	c1 e0 03             	shl    $0x3,%eax
f01017e6:	e8 9b f6 ff ff       	call   f0100e86 <boot_alloc>
f01017eb:	a3 98 be 22 f0       	mov    %eax,0xf022be98

	cprintf("npages: %d\n", npages);
f01017f0:	83 ec 08             	sub    $0x8,%esp
f01017f3:	ff 35 90 be 22 f0    	pushl  0xf022be90
f01017f9:	68 95 6d 10 f0       	push   $0xf0106d95
f01017fe:	e8 cf 22 00 00       	call   f0103ad2 <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f0101803:	83 c4 08             	add    $0x8,%esp
f0101806:	ff 35 44 b2 22 f0    	pushl  0xf022b244
f010180c:	68 a1 6d 10 f0       	push   $0xf0106da1
f0101811:	e8 bc 22 00 00       	call   f0103ad2 <cprintf>
	cprintf("pages: %x\n", pages);
f0101816:	83 c4 08             	add    $0x8,%esp
f0101819:	ff 35 98 be 22 f0    	pushl  0xf022be98
f010181f:	68 b5 6d 10 f0       	push   $0xf0106db5
f0101824:	e8 a9 22 00 00       	call   f0103ad2 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f0101829:	b8 00 00 02 00       	mov    $0x20000,%eax
f010182e:	e8 53 f6 ff ff       	call   f0100e86 <boot_alloc>
f0101833:	a3 48 b2 22 f0       	mov    %eax,0xf022b248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101838:	e8 27 fa ff ff       	call   f0101264 <page_init>

	check_page_free_list(1);
f010183d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101842:	e8 1b f7 ff ff       	call   f0100f62 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101847:	83 c4 10             	add    $0x10,%esp
f010184a:	83 3d 98 be 22 f0 00 	cmpl   $0x0,0xf022be98
f0101851:	75 17                	jne    f010186a <mem_init+0x191>
		panic("'pages' is a null pointer!");
f0101853:	83 ec 04             	sub    $0x4,%esp
f0101856:	68 c0 6d 10 f0       	push   $0xf0106dc0
f010185b:	68 00 03 00 00       	push   $0x300
f0101860:	68 58 6c 10 f0       	push   $0xf0106c58
f0101865:	e8 2a e8 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010186a:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f010186f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101874:	eb 05                	jmp    f010187b <mem_init+0x1a2>
		++nfree;
f0101876:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101879:	8b 00                	mov    (%eax),%eax
f010187b:	85 c0                	test   %eax,%eax
f010187d:	75 f7                	jne    f0101876 <mem_init+0x19d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010187f:	83 ec 0c             	sub    $0xc,%esp
f0101882:	6a 00                	push   $0x0
f0101884:	e8 bb fa ff ff       	call   f0101344 <page_alloc>
f0101889:	89 c7                	mov    %eax,%edi
f010188b:	83 c4 10             	add    $0x10,%esp
f010188e:	85 c0                	test   %eax,%eax
f0101890:	75 19                	jne    f01018ab <mem_init+0x1d2>
f0101892:	68 db 6d 10 f0       	push   $0xf0106ddb
f0101897:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010189c:	68 08 03 00 00       	push   $0x308
f01018a1:	68 58 6c 10 f0       	push   $0xf0106c58
f01018a6:	e8 e9 e7 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01018ab:	83 ec 0c             	sub    $0xc,%esp
f01018ae:	6a 00                	push   $0x0
f01018b0:	e8 8f fa ff ff       	call   f0101344 <page_alloc>
f01018b5:	89 c6                	mov    %eax,%esi
f01018b7:	83 c4 10             	add    $0x10,%esp
f01018ba:	85 c0                	test   %eax,%eax
f01018bc:	75 19                	jne    f01018d7 <mem_init+0x1fe>
f01018be:	68 f1 6d 10 f0       	push   $0xf0106df1
f01018c3:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01018c8:	68 09 03 00 00       	push   $0x309
f01018cd:	68 58 6c 10 f0       	push   $0xf0106c58
f01018d2:	e8 bd e7 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01018d7:	83 ec 0c             	sub    $0xc,%esp
f01018da:	6a 00                	push   $0x0
f01018dc:	e8 63 fa ff ff       	call   f0101344 <page_alloc>
f01018e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018e4:	83 c4 10             	add    $0x10,%esp
f01018e7:	85 c0                	test   %eax,%eax
f01018e9:	75 19                	jne    f0101904 <mem_init+0x22b>
f01018eb:	68 07 6e 10 f0       	push   $0xf0106e07
f01018f0:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01018f5:	68 0a 03 00 00       	push   $0x30a
f01018fa:	68 58 6c 10 f0       	push   $0xf0106c58
f01018ff:	e8 90 e7 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101904:	39 f7                	cmp    %esi,%edi
f0101906:	75 19                	jne    f0101921 <mem_init+0x248>
f0101908:	68 1d 6e 10 f0       	push   $0xf0106e1d
f010190d:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101912:	68 0d 03 00 00       	push   $0x30d
f0101917:	68 58 6c 10 f0       	push   $0xf0106c58
f010191c:	e8 73 e7 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101921:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101924:	39 c6                	cmp    %eax,%esi
f0101926:	74 04                	je     f010192c <mem_init+0x253>
f0101928:	39 c7                	cmp    %eax,%edi
f010192a:	75 19                	jne    f0101945 <mem_init+0x26c>
f010192c:	68 ac 71 10 f0       	push   $0xf01071ac
f0101931:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101936:	68 0e 03 00 00       	push   $0x30e
f010193b:	68 58 6c 10 f0       	push   $0xf0106c58
f0101940:	e8 4f e7 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101945:	8b 0d 98 be 22 f0    	mov    0xf022be98,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010194b:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0101951:	c1 e2 0c             	shl    $0xc,%edx
f0101954:	89 f8                	mov    %edi,%eax
f0101956:	29 c8                	sub    %ecx,%eax
f0101958:	c1 f8 03             	sar    $0x3,%eax
f010195b:	c1 e0 0c             	shl    $0xc,%eax
f010195e:	39 d0                	cmp    %edx,%eax
f0101960:	72 19                	jb     f010197b <mem_init+0x2a2>
f0101962:	68 2f 6e 10 f0       	push   $0xf0106e2f
f0101967:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010196c:	68 0f 03 00 00       	push   $0x30f
f0101971:	68 58 6c 10 f0       	push   $0xf0106c58
f0101976:	e8 19 e7 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010197b:	89 f0                	mov    %esi,%eax
f010197d:	29 c8                	sub    %ecx,%eax
f010197f:	c1 f8 03             	sar    $0x3,%eax
f0101982:	c1 e0 0c             	shl    $0xc,%eax
f0101985:	39 c2                	cmp    %eax,%edx
f0101987:	77 19                	ja     f01019a2 <mem_init+0x2c9>
f0101989:	68 4c 6e 10 f0       	push   $0xf0106e4c
f010198e:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101993:	68 10 03 00 00       	push   $0x310
f0101998:	68 58 6c 10 f0       	push   $0xf0106c58
f010199d:	e8 f2 e6 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01019a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a5:	29 c8                	sub    %ecx,%eax
f01019a7:	c1 f8 03             	sar    $0x3,%eax
f01019aa:	c1 e0 0c             	shl    $0xc,%eax
f01019ad:	39 c2                	cmp    %eax,%edx
f01019af:	77 19                	ja     f01019ca <mem_init+0x2f1>
f01019b1:	68 69 6e 10 f0       	push   $0xf0106e69
f01019b6:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01019bb:	68 11 03 00 00       	push   $0x311
f01019c0:	68 58 6c 10 f0       	push   $0xf0106c58
f01019c5:	e8 ca e6 ff ff       	call   f0100094 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019ca:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f01019cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019d2:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f01019d9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019dc:	83 ec 0c             	sub    $0xc,%esp
f01019df:	6a 00                	push   $0x0
f01019e1:	e8 5e f9 ff ff       	call   f0101344 <page_alloc>
f01019e6:	83 c4 10             	add    $0x10,%esp
f01019e9:	85 c0                	test   %eax,%eax
f01019eb:	74 19                	je     f0101a06 <mem_init+0x32d>
f01019ed:	68 86 6e 10 f0       	push   $0xf0106e86
f01019f2:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01019f7:	68 19 03 00 00       	push   $0x319
f01019fc:	68 58 6c 10 f0       	push   $0xf0106c58
f0101a01:	e8 8e e6 ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101a06:	83 ec 0c             	sub    $0xc,%esp
f0101a09:	57                   	push   %edi
f0101a0a:	e8 9f f9 ff ff       	call   f01013ae <page_free>
	page_free(pp1);
f0101a0f:	89 34 24             	mov    %esi,(%esp)
f0101a12:	e8 97 f9 ff ff       	call   f01013ae <page_free>
	page_free(pp2);
f0101a17:	83 c4 04             	add    $0x4,%esp
f0101a1a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a1d:	e8 8c f9 ff ff       	call   f01013ae <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a29:	e8 16 f9 ff ff       	call   f0101344 <page_alloc>
f0101a2e:	89 c6                	mov    %eax,%esi
f0101a30:	83 c4 10             	add    $0x10,%esp
f0101a33:	85 c0                	test   %eax,%eax
f0101a35:	75 19                	jne    f0101a50 <mem_init+0x377>
f0101a37:	68 db 6d 10 f0       	push   $0xf0106ddb
f0101a3c:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101a41:	68 20 03 00 00       	push   $0x320
f0101a46:	68 58 6c 10 f0       	push   $0xf0106c58
f0101a4b:	e8 44 e6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a50:	83 ec 0c             	sub    $0xc,%esp
f0101a53:	6a 00                	push   $0x0
f0101a55:	e8 ea f8 ff ff       	call   f0101344 <page_alloc>
f0101a5a:	89 c7                	mov    %eax,%edi
f0101a5c:	83 c4 10             	add    $0x10,%esp
f0101a5f:	85 c0                	test   %eax,%eax
f0101a61:	75 19                	jne    f0101a7c <mem_init+0x3a3>
f0101a63:	68 f1 6d 10 f0       	push   $0xf0106df1
f0101a68:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101a6d:	68 21 03 00 00       	push   $0x321
f0101a72:	68 58 6c 10 f0       	push   $0xf0106c58
f0101a77:	e8 18 e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a7c:	83 ec 0c             	sub    $0xc,%esp
f0101a7f:	6a 00                	push   $0x0
f0101a81:	e8 be f8 ff ff       	call   f0101344 <page_alloc>
f0101a86:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a89:	83 c4 10             	add    $0x10,%esp
f0101a8c:	85 c0                	test   %eax,%eax
f0101a8e:	75 19                	jne    f0101aa9 <mem_init+0x3d0>
f0101a90:	68 07 6e 10 f0       	push   $0xf0106e07
f0101a95:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101a9a:	68 22 03 00 00       	push   $0x322
f0101a9f:	68 58 6c 10 f0       	push   $0xf0106c58
f0101aa4:	e8 eb e5 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101aa9:	39 fe                	cmp    %edi,%esi
f0101aab:	75 19                	jne    f0101ac6 <mem_init+0x3ed>
f0101aad:	68 1d 6e 10 f0       	push   $0xf0106e1d
f0101ab2:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101ab7:	68 24 03 00 00       	push   $0x324
f0101abc:	68 58 6c 10 f0       	push   $0xf0106c58
f0101ac1:	e8 ce e5 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ac6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ac9:	39 c7                	cmp    %eax,%edi
f0101acb:	74 04                	je     f0101ad1 <mem_init+0x3f8>
f0101acd:	39 c6                	cmp    %eax,%esi
f0101acf:	75 19                	jne    f0101aea <mem_init+0x411>
f0101ad1:	68 ac 71 10 f0       	push   $0xf01071ac
f0101ad6:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101adb:	68 25 03 00 00       	push   $0x325
f0101ae0:	68 58 6c 10 f0       	push   $0xf0106c58
f0101ae5:	e8 aa e5 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101aea:	83 ec 0c             	sub    $0xc,%esp
f0101aed:	6a 00                	push   $0x0
f0101aef:	e8 50 f8 ff ff       	call   f0101344 <page_alloc>
f0101af4:	83 c4 10             	add    $0x10,%esp
f0101af7:	85 c0                	test   %eax,%eax
f0101af9:	74 19                	je     f0101b14 <mem_init+0x43b>
f0101afb:	68 86 6e 10 f0       	push   $0xf0106e86
f0101b00:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101b05:	68 26 03 00 00       	push   $0x326
f0101b0a:	68 58 6c 10 f0       	push   $0xf0106c58
f0101b0f:	e8 80 e5 ff ff       	call   f0100094 <_panic>
f0101b14:	89 f0                	mov    %esi,%eax
f0101b16:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f0101b1c:	c1 f8 03             	sar    $0x3,%eax
f0101b1f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b22:	89 c2                	mov    %eax,%edx
f0101b24:	c1 ea 0c             	shr    $0xc,%edx
f0101b27:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f0101b2d:	72 12                	jb     f0101b41 <mem_init+0x468>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b2f:	50                   	push   %eax
f0101b30:	68 3c 65 10 f0       	push   $0xf010653c
f0101b35:	6a 58                	push   $0x58
f0101b37:	68 64 6c 10 f0       	push   $0xf0106c64
f0101b3c:	e8 53 e5 ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101b41:	83 ec 04             	sub    $0x4,%esp
f0101b44:	68 00 10 00 00       	push   $0x1000
f0101b49:	6a 01                	push   $0x1
f0101b4b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b50:	50                   	push   %eax
f0101b51:	e8 e7 3b 00 00       	call   f010573d <memset>
	page_free(pp0);
f0101b56:	89 34 24             	mov    %esi,(%esp)
f0101b59:	e8 50 f8 ff ff       	call   f01013ae <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b65:	e8 da f7 ff ff       	call   f0101344 <page_alloc>
f0101b6a:	83 c4 10             	add    $0x10,%esp
f0101b6d:	85 c0                	test   %eax,%eax
f0101b6f:	75 19                	jne    f0101b8a <mem_init+0x4b1>
f0101b71:	68 95 6e 10 f0       	push   $0xf0106e95
f0101b76:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101b7b:	68 2b 03 00 00       	push   $0x32b
f0101b80:	68 58 6c 10 f0       	push   $0xf0106c58
f0101b85:	e8 0a e5 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101b8a:	39 c6                	cmp    %eax,%esi
f0101b8c:	74 19                	je     f0101ba7 <mem_init+0x4ce>
f0101b8e:	68 b3 6e 10 f0       	push   $0xf0106eb3
f0101b93:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101b98:	68 2c 03 00 00       	push   $0x32c
f0101b9d:	68 58 6c 10 f0       	push   $0xf0106c58
f0101ba2:	e8 ed e4 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ba7:	89 f0                	mov    %esi,%eax
f0101ba9:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f0101baf:	c1 f8 03             	sar    $0x3,%eax
f0101bb2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bb5:	89 c2                	mov    %eax,%edx
f0101bb7:	c1 ea 0c             	shr    $0xc,%edx
f0101bba:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f0101bc0:	72 12                	jb     f0101bd4 <mem_init+0x4fb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bc2:	50                   	push   %eax
f0101bc3:	68 3c 65 10 f0       	push   $0xf010653c
f0101bc8:	6a 58                	push   $0x58
f0101bca:	68 64 6c 10 f0       	push   $0xf0106c64
f0101bcf:	e8 c0 e4 ff ff       	call   f0100094 <_panic>
f0101bd4:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101bda:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101be0:	80 38 00             	cmpb   $0x0,(%eax)
f0101be3:	74 19                	je     f0101bfe <mem_init+0x525>
f0101be5:	68 c3 6e 10 f0       	push   $0xf0106ec3
f0101bea:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101bef:	68 2f 03 00 00       	push   $0x32f
f0101bf4:	68 58 6c 10 f0       	push   $0xf0106c58
f0101bf9:	e8 96 e4 ff ff       	call   f0100094 <_panic>
f0101bfe:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101c01:	39 d0                	cmp    %edx,%eax
f0101c03:	75 db                	jne    f0101be0 <mem_init+0x507>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101c05:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c08:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	// free the pages we took
	page_free(pp0);
f0101c0d:	83 ec 0c             	sub    $0xc,%esp
f0101c10:	56                   	push   %esi
f0101c11:	e8 98 f7 ff ff       	call   f01013ae <page_free>
	page_free(pp1);
f0101c16:	89 3c 24             	mov    %edi,(%esp)
f0101c19:	e8 90 f7 ff ff       	call   f01013ae <page_free>
	page_free(pp2);
f0101c1e:	83 c4 04             	add    $0x4,%esp
f0101c21:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c24:	e8 85 f7 ff ff       	call   f01013ae <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c29:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101c2e:	83 c4 10             	add    $0x10,%esp
f0101c31:	eb 05                	jmp    f0101c38 <mem_init+0x55f>
		--nfree;
f0101c33:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c36:	8b 00                	mov    (%eax),%eax
f0101c38:	85 c0                	test   %eax,%eax
f0101c3a:	75 f7                	jne    f0101c33 <mem_init+0x55a>
		--nfree;
	assert(nfree == 0);
f0101c3c:	85 db                	test   %ebx,%ebx
f0101c3e:	74 19                	je     f0101c59 <mem_init+0x580>
f0101c40:	68 cd 6e 10 f0       	push   $0xf0106ecd
f0101c45:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101c4a:	68 3c 03 00 00       	push   $0x33c
f0101c4f:	68 58 6c 10 f0       	push   $0xf0106c58
f0101c54:	e8 3b e4 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101c59:	83 ec 0c             	sub    $0xc,%esp
f0101c5c:	68 cc 71 10 f0       	push   $0xf01071cc
f0101c61:	e8 6c 1e 00 00       	call   f0103ad2 <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101c66:	c7 04 24 d8 6e 10 f0 	movl   $0xf0106ed8,(%esp)
f0101c6d:	e8 60 1e 00 00       	call   f0103ad2 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c79:	e8 c6 f6 ff ff       	call   f0101344 <page_alloc>
f0101c7e:	89 c6                	mov    %eax,%esi
f0101c80:	83 c4 10             	add    $0x10,%esp
f0101c83:	85 c0                	test   %eax,%eax
f0101c85:	75 19                	jne    f0101ca0 <mem_init+0x5c7>
f0101c87:	68 db 6d 10 f0       	push   $0xf0106ddb
f0101c8c:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101c91:	68 a7 03 00 00       	push   $0x3a7
f0101c96:	68 58 6c 10 f0       	push   $0xf0106c58
f0101c9b:	e8 f4 e3 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ca0:	83 ec 0c             	sub    $0xc,%esp
f0101ca3:	6a 00                	push   $0x0
f0101ca5:	e8 9a f6 ff ff       	call   f0101344 <page_alloc>
f0101caa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cad:	83 c4 10             	add    $0x10,%esp
f0101cb0:	85 c0                	test   %eax,%eax
f0101cb2:	75 19                	jne    f0101ccd <mem_init+0x5f4>
f0101cb4:	68 f1 6d 10 f0       	push   $0xf0106df1
f0101cb9:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101cbe:	68 a8 03 00 00       	push   $0x3a8
f0101cc3:	68 58 6c 10 f0       	push   $0xf0106c58
f0101cc8:	e8 c7 e3 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ccd:	83 ec 0c             	sub    $0xc,%esp
f0101cd0:	6a 00                	push   $0x0
f0101cd2:	e8 6d f6 ff ff       	call   f0101344 <page_alloc>
f0101cd7:	89 c3                	mov    %eax,%ebx
f0101cd9:	83 c4 10             	add    $0x10,%esp
f0101cdc:	85 c0                	test   %eax,%eax
f0101cde:	75 19                	jne    f0101cf9 <mem_init+0x620>
f0101ce0:	68 07 6e 10 f0       	push   $0xf0106e07
f0101ce5:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101cea:	68 a9 03 00 00       	push   $0x3a9
f0101cef:	68 58 6c 10 f0       	push   $0xf0106c58
f0101cf4:	e8 9b e3 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cf9:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101cfc:	75 19                	jne    f0101d17 <mem_init+0x63e>
f0101cfe:	68 1d 6e 10 f0       	push   $0xf0106e1d
f0101d03:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101d08:	68 ac 03 00 00       	push   $0x3ac
f0101d0d:	68 58 6c 10 f0       	push   $0xf0106c58
f0101d12:	e8 7d e3 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d17:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101d1a:	74 04                	je     f0101d20 <mem_init+0x647>
f0101d1c:	39 c6                	cmp    %eax,%esi
f0101d1e:	75 19                	jne    f0101d39 <mem_init+0x660>
f0101d20:	68 ac 71 10 f0       	push   $0xf01071ac
f0101d25:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101d2a:	68 ad 03 00 00       	push   $0x3ad
f0101d2f:	68 58 6c 10 f0       	push   $0xf0106c58
f0101d34:	e8 5b e3 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101d39:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101d3e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101d41:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101d48:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d4b:	83 ec 0c             	sub    $0xc,%esp
f0101d4e:	6a 00                	push   $0x0
f0101d50:	e8 ef f5 ff ff       	call   f0101344 <page_alloc>
f0101d55:	83 c4 10             	add    $0x10,%esp
f0101d58:	85 c0                	test   %eax,%eax
f0101d5a:	74 19                	je     f0101d75 <mem_init+0x69c>
f0101d5c:	68 86 6e 10 f0       	push   $0xf0106e86
f0101d61:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101d66:	68 b4 03 00 00       	push   $0x3b4
f0101d6b:	68 58 6c 10 f0       	push   $0xf0106c58
f0101d70:	e8 1f e3 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d75:	83 ec 04             	sub    $0x4,%esp
f0101d78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d7b:	50                   	push   %eax
f0101d7c:	6a 00                	push   $0x0
f0101d7e:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0101d84:	e8 94 f7 ff ff       	call   f010151d <page_lookup>
f0101d89:	83 c4 10             	add    $0x10,%esp
f0101d8c:	85 c0                	test   %eax,%eax
f0101d8e:	74 19                	je     f0101da9 <mem_init+0x6d0>
f0101d90:	68 ec 71 10 f0       	push   $0xf01071ec
f0101d95:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101d9a:	68 b7 03 00 00       	push   $0x3b7
f0101d9f:	68 58 6c 10 f0       	push   $0xf0106c58
f0101da4:	e8 eb e2 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101da9:	6a 02                	push   $0x2
f0101dab:	6a 00                	push   $0x0
f0101dad:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101db0:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0101db6:	e8 4b f8 ff ff       	call   f0101606 <page_insert>
f0101dbb:	83 c4 10             	add    $0x10,%esp
f0101dbe:	85 c0                	test   %eax,%eax
f0101dc0:	78 19                	js     f0101ddb <mem_init+0x702>
f0101dc2:	68 24 72 10 f0       	push   $0xf0107224
f0101dc7:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101dcc:	68 ba 03 00 00       	push   $0x3ba
f0101dd1:	68 58 6c 10 f0       	push   $0xf0106c58
f0101dd6:	e8 b9 e2 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ddb:	83 ec 0c             	sub    $0xc,%esp
f0101dde:	56                   	push   %esi
f0101ddf:	e8 ca f5 ff ff       	call   f01013ae <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101de4:	6a 02                	push   $0x2
f0101de6:	6a 00                	push   $0x0
f0101de8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101deb:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0101df1:	e8 10 f8 ff ff       	call   f0101606 <page_insert>
f0101df6:	83 c4 20             	add    $0x20,%esp
f0101df9:	85 c0                	test   %eax,%eax
f0101dfb:	74 19                	je     f0101e16 <mem_init+0x73d>
f0101dfd:	68 54 72 10 f0       	push   $0xf0107254
f0101e02:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101e07:	68 be 03 00 00       	push   $0x3be
f0101e0c:	68 58 6c 10 f0       	push   $0xf0106c58
f0101e11:	e8 7e e2 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e16:	8b 3d 94 be 22 f0    	mov    0xf022be94,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e1c:	a1 98 be 22 f0       	mov    0xf022be98,%eax
f0101e21:	89 c1                	mov    %eax,%ecx
f0101e23:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e26:	8b 17                	mov    (%edi),%edx
f0101e28:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e2e:	89 f0                	mov    %esi,%eax
f0101e30:	29 c8                	sub    %ecx,%eax
f0101e32:	c1 f8 03             	sar    $0x3,%eax
f0101e35:	c1 e0 0c             	shl    $0xc,%eax
f0101e38:	39 c2                	cmp    %eax,%edx
f0101e3a:	74 19                	je     f0101e55 <mem_init+0x77c>
f0101e3c:	68 84 72 10 f0       	push   $0xf0107284
f0101e41:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101e46:	68 bf 03 00 00       	push   $0x3bf
f0101e4b:	68 58 6c 10 f0       	push   $0xf0106c58
f0101e50:	e8 3f e2 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e55:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e5a:	89 f8                	mov    %edi,%eax
f0101e5c:	e8 9d f0 ff ff       	call   f0100efe <check_va2pa>
f0101e61:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101e64:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101e67:	c1 fa 03             	sar    $0x3,%edx
f0101e6a:	c1 e2 0c             	shl    $0xc,%edx
f0101e6d:	39 d0                	cmp    %edx,%eax
f0101e6f:	74 19                	je     f0101e8a <mem_init+0x7b1>
f0101e71:	68 ac 72 10 f0       	push   $0xf01072ac
f0101e76:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101e7b:	68 c0 03 00 00       	push   $0x3c0
f0101e80:	68 58 6c 10 f0       	push   $0xf0106c58
f0101e85:	e8 0a e2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101e8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e8d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e92:	74 19                	je     f0101ead <mem_init+0x7d4>
f0101e94:	68 e8 6e 10 f0       	push   $0xf0106ee8
f0101e99:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101e9e:	68 c1 03 00 00       	push   $0x3c1
f0101ea3:	68 58 6c 10 f0       	push   $0xf0106c58
f0101ea8:	e8 e7 e1 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101ead:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101eb2:	74 19                	je     f0101ecd <mem_init+0x7f4>
f0101eb4:	68 f9 6e 10 f0       	push   $0xf0106ef9
f0101eb9:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101ebe:	68 c2 03 00 00       	push   $0x3c2
f0101ec3:	68 58 6c 10 f0       	push   $0xf0106c58
f0101ec8:	e8 c7 e1 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ecd:	6a 02                	push   $0x2
f0101ecf:	68 00 10 00 00       	push   $0x1000
f0101ed4:	53                   	push   %ebx
f0101ed5:	57                   	push   %edi
f0101ed6:	e8 2b f7 ff ff       	call   f0101606 <page_insert>
f0101edb:	83 c4 10             	add    $0x10,%esp
f0101ede:	85 c0                	test   %eax,%eax
f0101ee0:	74 19                	je     f0101efb <mem_init+0x822>
f0101ee2:	68 dc 72 10 f0       	push   $0xf01072dc
f0101ee7:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101eec:	68 c5 03 00 00       	push   $0x3c5
f0101ef1:	68 58 6c 10 f0       	push   $0xf0106c58
f0101ef6:	e8 99 e1 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101efb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f00:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f0101f05:	e8 f4 ef ff ff       	call   f0100efe <check_va2pa>
f0101f0a:	89 da                	mov    %ebx,%edx
f0101f0c:	2b 15 98 be 22 f0    	sub    0xf022be98,%edx
f0101f12:	c1 fa 03             	sar    $0x3,%edx
f0101f15:	c1 e2 0c             	shl    $0xc,%edx
f0101f18:	39 d0                	cmp    %edx,%eax
f0101f1a:	74 19                	je     f0101f35 <mem_init+0x85c>
f0101f1c:	68 18 73 10 f0       	push   $0xf0107318
f0101f21:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101f26:	68 c6 03 00 00       	push   $0x3c6
f0101f2b:	68 58 6c 10 f0       	push   $0xf0106c58
f0101f30:	e8 5f e1 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101f35:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f3a:	74 19                	je     f0101f55 <mem_init+0x87c>
f0101f3c:	68 0a 6f 10 f0       	push   $0xf0106f0a
f0101f41:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101f46:	68 c7 03 00 00       	push   $0x3c7
f0101f4b:	68 58 6c 10 f0       	push   $0xf0106c58
f0101f50:	e8 3f e1 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f55:	83 ec 0c             	sub    $0xc,%esp
f0101f58:	6a 00                	push   $0x0
f0101f5a:	e8 e5 f3 ff ff       	call   f0101344 <page_alloc>
f0101f5f:	83 c4 10             	add    $0x10,%esp
f0101f62:	85 c0                	test   %eax,%eax
f0101f64:	74 19                	je     f0101f7f <mem_init+0x8a6>
f0101f66:	68 86 6e 10 f0       	push   $0xf0106e86
f0101f6b:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101f70:	68 ca 03 00 00       	push   $0x3ca
f0101f75:	68 58 6c 10 f0       	push   $0xf0106c58
f0101f7a:	e8 15 e1 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f7f:	6a 02                	push   $0x2
f0101f81:	68 00 10 00 00       	push   $0x1000
f0101f86:	53                   	push   %ebx
f0101f87:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0101f8d:	e8 74 f6 ff ff       	call   f0101606 <page_insert>
f0101f92:	83 c4 10             	add    $0x10,%esp
f0101f95:	85 c0                	test   %eax,%eax
f0101f97:	74 19                	je     f0101fb2 <mem_init+0x8d9>
f0101f99:	68 dc 72 10 f0       	push   $0xf01072dc
f0101f9e:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101fa3:	68 cd 03 00 00       	push   $0x3cd
f0101fa8:	68 58 6c 10 f0       	push   $0xf0106c58
f0101fad:	e8 e2 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fb2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fb7:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f0101fbc:	e8 3d ef ff ff       	call   f0100efe <check_va2pa>
f0101fc1:	89 da                	mov    %ebx,%edx
f0101fc3:	2b 15 98 be 22 f0    	sub    0xf022be98,%edx
f0101fc9:	c1 fa 03             	sar    $0x3,%edx
f0101fcc:	c1 e2 0c             	shl    $0xc,%edx
f0101fcf:	39 d0                	cmp    %edx,%eax
f0101fd1:	74 19                	je     f0101fec <mem_init+0x913>
f0101fd3:	68 18 73 10 f0       	push   $0xf0107318
f0101fd8:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101fdd:	68 ce 03 00 00       	push   $0x3ce
f0101fe2:	68 58 6c 10 f0       	push   $0xf0106c58
f0101fe7:	e8 a8 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101fec:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ff1:	74 19                	je     f010200c <mem_init+0x933>
f0101ff3:	68 0a 6f 10 f0       	push   $0xf0106f0a
f0101ff8:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0101ffd:	68 cf 03 00 00       	push   $0x3cf
f0102002:	68 58 6c 10 f0       	push   $0xf0106c58
f0102007:	e8 88 e0 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010200c:	83 ec 0c             	sub    $0xc,%esp
f010200f:	6a 00                	push   $0x0
f0102011:	e8 2e f3 ff ff       	call   f0101344 <page_alloc>
f0102016:	83 c4 10             	add    $0x10,%esp
f0102019:	85 c0                	test   %eax,%eax
f010201b:	74 19                	je     f0102036 <mem_init+0x95d>
f010201d:	68 86 6e 10 f0       	push   $0xf0106e86
f0102022:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102027:	68 d3 03 00 00       	push   $0x3d3
f010202c:	68 58 6c 10 f0       	push   $0xf0106c58
f0102031:	e8 5e e0 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102036:	8b 15 94 be 22 f0    	mov    0xf022be94,%edx
f010203c:	8b 02                	mov    (%edx),%eax
f010203e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102043:	89 c1                	mov    %eax,%ecx
f0102045:	c1 e9 0c             	shr    $0xc,%ecx
f0102048:	3b 0d 90 be 22 f0    	cmp    0xf022be90,%ecx
f010204e:	72 15                	jb     f0102065 <mem_init+0x98c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102050:	50                   	push   %eax
f0102051:	68 3c 65 10 f0       	push   $0xf010653c
f0102056:	68 d6 03 00 00       	push   $0x3d6
f010205b:	68 58 6c 10 f0       	push   $0xf0106c58
f0102060:	e8 2f e0 ff ff       	call   f0100094 <_panic>
f0102065:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010206a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010206d:	83 ec 04             	sub    $0x4,%esp
f0102070:	6a 00                	push   $0x0
f0102072:	68 00 10 00 00       	push   $0x1000
f0102077:	52                   	push   %edx
f0102078:	e8 67 f3 ff ff       	call   f01013e4 <pgdir_walk>
f010207d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102080:	8d 51 04             	lea    0x4(%ecx),%edx
f0102083:	83 c4 10             	add    $0x10,%esp
f0102086:	39 d0                	cmp    %edx,%eax
f0102088:	74 19                	je     f01020a3 <mem_init+0x9ca>
f010208a:	68 48 73 10 f0       	push   $0xf0107348
f010208f:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102094:	68 d7 03 00 00       	push   $0x3d7
f0102099:	68 58 6c 10 f0       	push   $0xf0106c58
f010209e:	e8 f1 df ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01020a3:	6a 06                	push   $0x6
f01020a5:	68 00 10 00 00       	push   $0x1000
f01020aa:	53                   	push   %ebx
f01020ab:	ff 35 94 be 22 f0    	pushl  0xf022be94
f01020b1:	e8 50 f5 ff ff       	call   f0101606 <page_insert>
f01020b6:	83 c4 10             	add    $0x10,%esp
f01020b9:	85 c0                	test   %eax,%eax
f01020bb:	74 19                	je     f01020d6 <mem_init+0x9fd>
f01020bd:	68 88 73 10 f0       	push   $0xf0107388
f01020c2:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01020c7:	68 da 03 00 00       	push   $0x3da
f01020cc:	68 58 6c 10 f0       	push   $0xf0106c58
f01020d1:	e8 be df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020d6:	8b 3d 94 be 22 f0    	mov    0xf022be94,%edi
f01020dc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020e1:	89 f8                	mov    %edi,%eax
f01020e3:	e8 16 ee ff ff       	call   f0100efe <check_va2pa>
f01020e8:	89 da                	mov    %ebx,%edx
f01020ea:	2b 15 98 be 22 f0    	sub    0xf022be98,%edx
f01020f0:	c1 fa 03             	sar    $0x3,%edx
f01020f3:	c1 e2 0c             	shl    $0xc,%edx
f01020f6:	39 d0                	cmp    %edx,%eax
f01020f8:	74 19                	je     f0102113 <mem_init+0xa3a>
f01020fa:	68 18 73 10 f0       	push   $0xf0107318
f01020ff:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102104:	68 db 03 00 00       	push   $0x3db
f0102109:	68 58 6c 10 f0       	push   $0xf0106c58
f010210e:	e8 81 df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102113:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102118:	74 19                	je     f0102133 <mem_init+0xa5a>
f010211a:	68 0a 6f 10 f0       	push   $0xf0106f0a
f010211f:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102124:	68 dc 03 00 00       	push   $0x3dc
f0102129:	68 58 6c 10 f0       	push   $0xf0106c58
f010212e:	e8 61 df ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102133:	83 ec 04             	sub    $0x4,%esp
f0102136:	6a 00                	push   $0x0
f0102138:	68 00 10 00 00       	push   $0x1000
f010213d:	57                   	push   %edi
f010213e:	e8 a1 f2 ff ff       	call   f01013e4 <pgdir_walk>
f0102143:	83 c4 10             	add    $0x10,%esp
f0102146:	f6 00 04             	testb  $0x4,(%eax)
f0102149:	75 19                	jne    f0102164 <mem_init+0xa8b>
f010214b:	68 c8 73 10 f0       	push   $0xf01073c8
f0102150:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102155:	68 dd 03 00 00       	push   $0x3dd
f010215a:	68 58 6c 10 f0       	push   $0xf0106c58
f010215f:	e8 30 df ff ff       	call   f0100094 <_panic>
	cprintf("pp2 %x\n", pp2);
f0102164:	83 ec 08             	sub    $0x8,%esp
f0102167:	53                   	push   %ebx
f0102168:	68 1b 6f 10 f0       	push   $0xf0106f1b
f010216d:	e8 60 19 00 00       	call   f0103ad2 <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0102172:	83 c4 08             	add    $0x8,%esp
f0102175:	ff 35 94 be 22 f0    	pushl  0xf022be94
f010217b:	68 23 6f 10 f0       	push   $0xf0106f23
f0102180:	e8 4d 19 00 00       	call   f0103ad2 <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0102185:	83 c4 08             	add    $0x8,%esp
f0102188:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f010218d:	ff 30                	pushl  (%eax)
f010218f:	68 32 6f 10 f0       	push   $0xf0106f32
f0102194:	e8 39 19 00 00       	call   f0103ad2 <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0102199:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f010219e:	83 c4 10             	add    $0x10,%esp
f01021a1:	f6 00 04             	testb  $0x4,(%eax)
f01021a4:	75 19                	jne    f01021bf <mem_init+0xae6>
f01021a6:	68 47 6f 10 f0       	push   $0xf0106f47
f01021ab:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01021b0:	68 e1 03 00 00       	push   $0x3e1
f01021b5:	68 58 6c 10 f0       	push   $0xf0106c58
f01021ba:	e8 d5 de ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021bf:	6a 02                	push   $0x2
f01021c1:	68 00 10 00 00       	push   $0x1000
f01021c6:	53                   	push   %ebx
f01021c7:	50                   	push   %eax
f01021c8:	e8 39 f4 ff ff       	call   f0101606 <page_insert>
f01021cd:	83 c4 10             	add    $0x10,%esp
f01021d0:	85 c0                	test   %eax,%eax
f01021d2:	74 19                	je     f01021ed <mem_init+0xb14>
f01021d4:	68 dc 72 10 f0       	push   $0xf01072dc
f01021d9:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01021de:	68 e4 03 00 00       	push   $0x3e4
f01021e3:	68 58 6c 10 f0       	push   $0xf0106c58
f01021e8:	e8 a7 de ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01021ed:	83 ec 04             	sub    $0x4,%esp
f01021f0:	6a 00                	push   $0x0
f01021f2:	68 00 10 00 00       	push   $0x1000
f01021f7:	ff 35 94 be 22 f0    	pushl  0xf022be94
f01021fd:	e8 e2 f1 ff ff       	call   f01013e4 <pgdir_walk>
f0102202:	83 c4 10             	add    $0x10,%esp
f0102205:	f6 00 02             	testb  $0x2,(%eax)
f0102208:	75 19                	jne    f0102223 <mem_init+0xb4a>
f010220a:	68 fc 73 10 f0       	push   $0xf01073fc
f010220f:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102214:	68 e5 03 00 00       	push   $0x3e5
f0102219:	68 58 6c 10 f0       	push   $0xf0106c58
f010221e:	e8 71 de ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102223:	83 ec 04             	sub    $0x4,%esp
f0102226:	6a 00                	push   $0x0
f0102228:	68 00 10 00 00       	push   $0x1000
f010222d:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0102233:	e8 ac f1 ff ff       	call   f01013e4 <pgdir_walk>
f0102238:	83 c4 10             	add    $0x10,%esp
f010223b:	f6 00 04             	testb  $0x4,(%eax)
f010223e:	74 19                	je     f0102259 <mem_init+0xb80>
f0102240:	68 30 74 10 f0       	push   $0xf0107430
f0102245:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010224a:	68 e6 03 00 00       	push   $0x3e6
f010224f:	68 58 6c 10 f0       	push   $0xf0106c58
f0102254:	e8 3b de ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102259:	6a 02                	push   $0x2
f010225b:	68 00 00 40 00       	push   $0x400000
f0102260:	56                   	push   %esi
f0102261:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0102267:	e8 9a f3 ff ff       	call   f0101606 <page_insert>
f010226c:	83 c4 10             	add    $0x10,%esp
f010226f:	85 c0                	test   %eax,%eax
f0102271:	78 19                	js     f010228c <mem_init+0xbb3>
f0102273:	68 68 74 10 f0       	push   $0xf0107468
f0102278:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010227d:	68 e9 03 00 00       	push   $0x3e9
f0102282:	68 58 6c 10 f0       	push   $0xf0106c58
f0102287:	e8 08 de ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010228c:	6a 02                	push   $0x2
f010228e:	68 00 10 00 00       	push   $0x1000
f0102293:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102296:	ff 35 94 be 22 f0    	pushl  0xf022be94
f010229c:	e8 65 f3 ff ff       	call   f0101606 <page_insert>
f01022a1:	83 c4 10             	add    $0x10,%esp
f01022a4:	85 c0                	test   %eax,%eax
f01022a6:	74 19                	je     f01022c1 <mem_init+0xbe8>
f01022a8:	68 a0 74 10 f0       	push   $0xf01074a0
f01022ad:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01022b2:	68 ec 03 00 00       	push   $0x3ec
f01022b7:	68 58 6c 10 f0       	push   $0xf0106c58
f01022bc:	e8 d3 dd ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01022c1:	83 ec 04             	sub    $0x4,%esp
f01022c4:	6a 00                	push   $0x0
f01022c6:	68 00 10 00 00       	push   $0x1000
f01022cb:	ff 35 94 be 22 f0    	pushl  0xf022be94
f01022d1:	e8 0e f1 ff ff       	call   f01013e4 <pgdir_walk>
f01022d6:	83 c4 10             	add    $0x10,%esp
f01022d9:	f6 00 04             	testb  $0x4,(%eax)
f01022dc:	74 19                	je     f01022f7 <mem_init+0xc1e>
f01022de:	68 30 74 10 f0       	push   $0xf0107430
f01022e3:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01022e8:	68 ed 03 00 00       	push   $0x3ed
f01022ed:	68 58 6c 10 f0       	push   $0xf0106c58
f01022f2:	e8 9d dd ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01022f7:	8b 3d 94 be 22 f0    	mov    0xf022be94,%edi
f01022fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0102302:	89 f8                	mov    %edi,%eax
f0102304:	e8 f5 eb ff ff       	call   f0100efe <check_va2pa>
f0102309:	89 c1                	mov    %eax,%ecx
f010230b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010230e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102311:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f0102317:	c1 f8 03             	sar    $0x3,%eax
f010231a:	c1 e0 0c             	shl    $0xc,%eax
f010231d:	39 c1                	cmp    %eax,%ecx
f010231f:	74 19                	je     f010233a <mem_init+0xc61>
f0102321:	68 dc 74 10 f0       	push   $0xf01074dc
f0102326:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010232b:	68 f0 03 00 00       	push   $0x3f0
f0102330:	68 58 6c 10 f0       	push   $0xf0106c58
f0102335:	e8 5a dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010233a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010233f:	89 f8                	mov    %edi,%eax
f0102341:	e8 b8 eb ff ff       	call   f0100efe <check_va2pa>
f0102346:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102349:	74 19                	je     f0102364 <mem_init+0xc8b>
f010234b:	68 08 75 10 f0       	push   $0xf0107508
f0102350:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102355:	68 f1 03 00 00       	push   $0x3f1
f010235a:	68 58 6c 10 f0       	push   $0xf0106c58
f010235f:	e8 30 dd ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102364:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102367:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f010236c:	74 19                	je     f0102387 <mem_init+0xcae>
f010236e:	68 5d 6f 10 f0       	push   $0xf0106f5d
f0102373:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102378:	68 f3 03 00 00       	push   $0x3f3
f010237d:	68 58 6c 10 f0       	push   $0xf0106c58
f0102382:	e8 0d dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102387:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010238c:	74 19                	je     f01023a7 <mem_init+0xcce>
f010238e:	68 6e 6f 10 f0       	push   $0xf0106f6e
f0102393:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102398:	68 f4 03 00 00       	push   $0x3f4
f010239d:	68 58 6c 10 f0       	push   $0xf0106c58
f01023a2:	e8 ed dc ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01023a7:	83 ec 0c             	sub    $0xc,%esp
f01023aa:	6a 00                	push   $0x0
f01023ac:	e8 93 ef ff ff       	call   f0101344 <page_alloc>
f01023b1:	83 c4 10             	add    $0x10,%esp
f01023b4:	85 c0                	test   %eax,%eax
f01023b6:	74 04                	je     f01023bc <mem_init+0xce3>
f01023b8:	39 c3                	cmp    %eax,%ebx
f01023ba:	74 19                	je     f01023d5 <mem_init+0xcfc>
f01023bc:	68 38 75 10 f0       	push   $0xf0107538
f01023c1:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01023c6:	68 f7 03 00 00       	push   $0x3f7
f01023cb:	68 58 6c 10 f0       	push   $0xf0106c58
f01023d0:	e8 bf dc ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01023d5:	83 ec 08             	sub    $0x8,%esp
f01023d8:	6a 00                	push   $0x0
f01023da:	ff 35 94 be 22 f0    	pushl  0xf022be94
f01023e0:	e8 d3 f1 ff ff       	call   f01015b8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023e5:	8b 3d 94 be 22 f0    	mov    0xf022be94,%edi
f01023eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01023f0:	89 f8                	mov    %edi,%eax
f01023f2:	e8 07 eb ff ff       	call   f0100efe <check_va2pa>
f01023f7:	83 c4 10             	add    $0x10,%esp
f01023fa:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023fd:	74 19                	je     f0102418 <mem_init+0xd3f>
f01023ff:	68 5c 75 10 f0       	push   $0xf010755c
f0102404:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102409:	68 fb 03 00 00       	push   $0x3fb
f010240e:	68 58 6c 10 f0       	push   $0xf0106c58
f0102413:	e8 7c dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102418:	ba 00 10 00 00       	mov    $0x1000,%edx
f010241d:	89 f8                	mov    %edi,%eax
f010241f:	e8 da ea ff ff       	call   f0100efe <check_va2pa>
f0102424:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102427:	2b 15 98 be 22 f0    	sub    0xf022be98,%edx
f010242d:	c1 fa 03             	sar    $0x3,%edx
f0102430:	c1 e2 0c             	shl    $0xc,%edx
f0102433:	39 d0                	cmp    %edx,%eax
f0102435:	74 19                	je     f0102450 <mem_init+0xd77>
f0102437:	68 08 75 10 f0       	push   $0xf0107508
f010243c:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102441:	68 fc 03 00 00       	push   $0x3fc
f0102446:	68 58 6c 10 f0       	push   $0xf0106c58
f010244b:	e8 44 dc ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102450:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102453:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102458:	74 19                	je     f0102473 <mem_init+0xd9a>
f010245a:	68 e8 6e 10 f0       	push   $0xf0106ee8
f010245f:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102464:	68 fd 03 00 00       	push   $0x3fd
f0102469:	68 58 6c 10 f0       	push   $0xf0106c58
f010246e:	e8 21 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102473:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102478:	74 19                	je     f0102493 <mem_init+0xdba>
f010247a:	68 6e 6f 10 f0       	push   $0xf0106f6e
f010247f:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102484:	68 fe 03 00 00       	push   $0x3fe
f0102489:	68 58 6c 10 f0       	push   $0xf0106c58
f010248e:	e8 01 dc ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102493:	83 ec 08             	sub    $0x8,%esp
f0102496:	68 00 10 00 00       	push   $0x1000
f010249b:	57                   	push   %edi
f010249c:	e8 17 f1 ff ff       	call   f01015b8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024a1:	8b 3d 94 be 22 f0    	mov    0xf022be94,%edi
f01024a7:	ba 00 00 00 00       	mov    $0x0,%edx
f01024ac:	89 f8                	mov    %edi,%eax
f01024ae:	e8 4b ea ff ff       	call   f0100efe <check_va2pa>
f01024b3:	83 c4 10             	add    $0x10,%esp
f01024b6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024b9:	74 19                	je     f01024d4 <mem_init+0xdfb>
f01024bb:	68 5c 75 10 f0       	push   $0xf010755c
f01024c0:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01024c5:	68 02 04 00 00       	push   $0x402
f01024ca:	68 58 6c 10 f0       	push   $0xf0106c58
f01024cf:	e8 c0 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024d4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024d9:	89 f8                	mov    %edi,%eax
f01024db:	e8 1e ea ff ff       	call   f0100efe <check_va2pa>
f01024e0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024e3:	74 19                	je     f01024fe <mem_init+0xe25>
f01024e5:	68 80 75 10 f0       	push   $0xf0107580
f01024ea:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01024ef:	68 03 04 00 00       	push   $0x403
f01024f4:	68 58 6c 10 f0       	push   $0xf0106c58
f01024f9:	e8 96 db ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01024fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102501:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102506:	74 19                	je     f0102521 <mem_init+0xe48>
f0102508:	68 7f 6f 10 f0       	push   $0xf0106f7f
f010250d:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102512:	68 04 04 00 00       	push   $0x404
f0102517:	68 58 6c 10 f0       	push   $0xf0106c58
f010251c:	e8 73 db ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102521:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102526:	74 19                	je     f0102541 <mem_init+0xe68>
f0102528:	68 6e 6f 10 f0       	push   $0xf0106f6e
f010252d:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102532:	68 05 04 00 00       	push   $0x405
f0102537:	68 58 6c 10 f0       	push   $0xf0106c58
f010253c:	e8 53 db ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102541:	83 ec 0c             	sub    $0xc,%esp
f0102544:	6a 00                	push   $0x0
f0102546:	e8 f9 ed ff ff       	call   f0101344 <page_alloc>
f010254b:	83 c4 10             	add    $0x10,%esp
f010254e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102551:	75 04                	jne    f0102557 <mem_init+0xe7e>
f0102553:	85 c0                	test   %eax,%eax
f0102555:	75 19                	jne    f0102570 <mem_init+0xe97>
f0102557:	68 a8 75 10 f0       	push   $0xf01075a8
f010255c:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102561:	68 08 04 00 00       	push   $0x408
f0102566:	68 58 6c 10 f0       	push   $0xf0106c58
f010256b:	e8 24 db ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102570:	83 ec 0c             	sub    $0xc,%esp
f0102573:	6a 00                	push   $0x0
f0102575:	e8 ca ed ff ff       	call   f0101344 <page_alloc>
f010257a:	83 c4 10             	add    $0x10,%esp
f010257d:	85 c0                	test   %eax,%eax
f010257f:	74 19                	je     f010259a <mem_init+0xec1>
f0102581:	68 86 6e 10 f0       	push   $0xf0106e86
f0102586:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010258b:	68 0b 04 00 00       	push   $0x40b
f0102590:	68 58 6c 10 f0       	push   $0xf0106c58
f0102595:	e8 fa da ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010259a:	8b 0d 94 be 22 f0    	mov    0xf022be94,%ecx
f01025a0:	8b 11                	mov    (%ecx),%edx
f01025a2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01025a8:	89 f0                	mov    %esi,%eax
f01025aa:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f01025b0:	c1 f8 03             	sar    $0x3,%eax
f01025b3:	c1 e0 0c             	shl    $0xc,%eax
f01025b6:	39 c2                	cmp    %eax,%edx
f01025b8:	74 19                	je     f01025d3 <mem_init+0xefa>
f01025ba:	68 84 72 10 f0       	push   $0xf0107284
f01025bf:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01025c4:	68 0e 04 00 00       	push   $0x40e
f01025c9:	68 58 6c 10 f0       	push   $0xf0106c58
f01025ce:	e8 c1 da ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01025d3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01025d9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025de:	74 19                	je     f01025f9 <mem_init+0xf20>
f01025e0:	68 f9 6e 10 f0       	push   $0xf0106ef9
f01025e5:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01025ea:	68 10 04 00 00       	push   $0x410
f01025ef:	68 58 6c 10 f0       	push   $0xf0106c58
f01025f4:	e8 9b da ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01025f9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01025ff:	83 ec 0c             	sub    $0xc,%esp
f0102602:	56                   	push   %esi
f0102603:	e8 a6 ed ff ff       	call   f01013ae <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102608:	83 c4 0c             	add    $0xc,%esp
f010260b:	6a 01                	push   $0x1
f010260d:	68 00 10 40 00       	push   $0x401000
f0102612:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0102618:	e8 c7 ed ff ff       	call   f01013e4 <pgdir_walk>
f010261d:	89 c7                	mov    %eax,%edi
f010261f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102622:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f0102627:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010262a:	8b 40 04             	mov    0x4(%eax),%eax
f010262d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102632:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
f0102638:	89 c2                	mov    %eax,%edx
f010263a:	c1 ea 0c             	shr    $0xc,%edx
f010263d:	83 c4 10             	add    $0x10,%esp
f0102640:	39 ca                	cmp    %ecx,%edx
f0102642:	72 15                	jb     f0102659 <mem_init+0xf80>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102644:	50                   	push   %eax
f0102645:	68 3c 65 10 f0       	push   $0xf010653c
f010264a:	68 17 04 00 00       	push   $0x417
f010264f:	68 58 6c 10 f0       	push   $0xf0106c58
f0102654:	e8 3b da ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102659:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010265e:	39 c7                	cmp    %eax,%edi
f0102660:	74 19                	je     f010267b <mem_init+0xfa2>
f0102662:	68 90 6f 10 f0       	push   $0xf0106f90
f0102667:	68 7e 6c 10 f0       	push   $0xf0106c7e
f010266c:	68 18 04 00 00       	push   $0x418
f0102671:	68 58 6c 10 f0       	push   $0xf0106c58
f0102676:	e8 19 da ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010267b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010267e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102685:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010268b:	89 f0                	mov    %esi,%eax
f010268d:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f0102693:	c1 f8 03             	sar    $0x3,%eax
f0102696:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102699:	89 c2                	mov    %eax,%edx
f010269b:	c1 ea 0c             	shr    $0xc,%edx
f010269e:	39 d1                	cmp    %edx,%ecx
f01026a0:	77 12                	ja     f01026b4 <mem_init+0xfdb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026a2:	50                   	push   %eax
f01026a3:	68 3c 65 10 f0       	push   $0xf010653c
f01026a8:	6a 58                	push   $0x58
f01026aa:	68 64 6c 10 f0       	push   $0xf0106c64
f01026af:	e8 e0 d9 ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01026b4:	83 ec 04             	sub    $0x4,%esp
f01026b7:	68 00 10 00 00       	push   $0x1000
f01026bc:	68 ff 00 00 00       	push   $0xff
f01026c1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026c6:	50                   	push   %eax
f01026c7:	e8 71 30 00 00       	call   f010573d <memset>
	page_free(pp0);
f01026cc:	89 34 24             	mov    %esi,(%esp)
f01026cf:	e8 da ec ff ff       	call   f01013ae <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01026d4:	83 c4 0c             	add    $0xc,%esp
f01026d7:	6a 01                	push   $0x1
f01026d9:	6a 00                	push   $0x0
f01026db:	ff 35 94 be 22 f0    	pushl  0xf022be94
f01026e1:	e8 fe ec ff ff       	call   f01013e4 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026e6:	89 f2                	mov    %esi,%edx
f01026e8:	2b 15 98 be 22 f0    	sub    0xf022be98,%edx
f01026ee:	c1 fa 03             	sar    $0x3,%edx
f01026f1:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026f4:	89 d0                	mov    %edx,%eax
f01026f6:	c1 e8 0c             	shr    $0xc,%eax
f01026f9:	83 c4 10             	add    $0x10,%esp
f01026fc:	3b 05 90 be 22 f0    	cmp    0xf022be90,%eax
f0102702:	72 12                	jb     f0102716 <mem_init+0x103d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102704:	52                   	push   %edx
f0102705:	68 3c 65 10 f0       	push   $0xf010653c
f010270a:	6a 58                	push   $0x58
f010270c:	68 64 6c 10 f0       	push   $0xf0106c64
f0102711:	e8 7e d9 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102716:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010271c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010271f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102725:	f6 00 01             	testb  $0x1,(%eax)
f0102728:	74 19                	je     f0102743 <mem_init+0x106a>
f010272a:	68 a8 6f 10 f0       	push   $0xf0106fa8
f010272f:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102734:	68 22 04 00 00       	push   $0x422
f0102739:	68 58 6c 10 f0       	push   $0xf0106c58
f010273e:	e8 51 d9 ff ff       	call   f0100094 <_panic>
f0102743:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102746:	39 c2                	cmp    %eax,%edx
f0102748:	75 db                	jne    f0102725 <mem_init+0x104c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010274a:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f010274f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102755:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f010275b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010275e:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	// free the pages we took
	page_free(pp0);
f0102763:	83 ec 0c             	sub    $0xc,%esp
f0102766:	56                   	push   %esi
f0102767:	e8 42 ec ff ff       	call   f01013ae <page_free>
	page_free(pp1);
f010276c:	83 c4 04             	add    $0x4,%esp
f010276f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102772:	e8 37 ec ff ff       	call   f01013ae <page_free>
	page_free(pp2);
f0102777:	89 1c 24             	mov    %ebx,(%esp)
f010277a:	e8 2f ec ff ff       	call   f01013ae <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010277f:	83 c4 08             	add    $0x8,%esp
f0102782:	68 01 10 00 00       	push   $0x1001
f0102787:	6a 00                	push   $0x0
f0102789:	e8 de ee ff ff       	call   f010166c <mmio_map_region>
f010278e:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102790:	83 c4 08             	add    $0x8,%esp
f0102793:	68 00 10 00 00       	push   $0x1000
f0102798:	6a 00                	push   $0x0
f010279a:	e8 cd ee ff ff       	call   f010166c <mmio_map_region>
f010279f:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01027a1:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01027a7:	83 c4 10             	add    $0x10,%esp
f01027aa:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01027b0:	76 07                	jbe    f01027b9 <mem_init+0x10e0>
f01027b2:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01027b7:	76 19                	jbe    f01027d2 <mem_init+0x10f9>
f01027b9:	68 cc 75 10 f0       	push   $0xf01075cc
f01027be:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01027c3:	68 32 04 00 00       	push   $0x432
f01027c8:	68 58 6c 10 f0       	push   $0xf0106c58
f01027cd:	e8 c2 d8 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01027d2:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01027d8:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01027de:	77 08                	ja     f01027e8 <mem_init+0x110f>
f01027e0:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01027e6:	77 19                	ja     f0102801 <mem_init+0x1128>
f01027e8:	68 f4 75 10 f0       	push   $0xf01075f4
f01027ed:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01027f2:	68 33 04 00 00       	push   $0x433
f01027f7:	68 58 6c 10 f0       	push   $0xf0106c58
f01027fc:	e8 93 d8 ff ff       	call   f0100094 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102801:	89 da                	mov    %ebx,%edx
f0102803:	09 f2                	or     %esi,%edx
f0102805:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010280b:	74 19                	je     f0102826 <mem_init+0x114d>
f010280d:	68 1c 76 10 f0       	push   $0xf010761c
f0102812:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102817:	68 35 04 00 00       	push   $0x435
f010281c:	68 58 6c 10 f0       	push   $0xf0106c58
f0102821:	e8 6e d8 ff ff       	call   f0100094 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102826:	39 c6                	cmp    %eax,%esi
f0102828:	73 19                	jae    f0102843 <mem_init+0x116a>
f010282a:	68 bf 6f 10 f0       	push   $0xf0106fbf
f010282f:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102834:	68 37 04 00 00       	push   $0x437
f0102839:	68 58 6c 10 f0       	push   $0xf0106c58
f010283e:	e8 51 d8 ff ff       	call   f0100094 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102843:	8b 3d 94 be 22 f0    	mov    0xf022be94,%edi
f0102849:	89 da                	mov    %ebx,%edx
f010284b:	89 f8                	mov    %edi,%eax
f010284d:	e8 ac e6 ff ff       	call   f0100efe <check_va2pa>
f0102852:	85 c0                	test   %eax,%eax
f0102854:	74 19                	je     f010286f <mem_init+0x1196>
f0102856:	68 44 76 10 f0       	push   $0xf0107644
f010285b:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102860:	68 39 04 00 00       	push   $0x439
f0102865:	68 58 6c 10 f0       	push   $0xf0106c58
f010286a:	e8 25 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010286f:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102875:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102878:	89 c2                	mov    %eax,%edx
f010287a:	89 f8                	mov    %edi,%eax
f010287c:	e8 7d e6 ff ff       	call   f0100efe <check_va2pa>
f0102881:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102886:	74 19                	je     f01028a1 <mem_init+0x11c8>
f0102888:	68 68 76 10 f0       	push   $0xf0107668
f010288d:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102892:	68 3a 04 00 00       	push   $0x43a
f0102897:	68 58 6c 10 f0       	push   $0xf0106c58
f010289c:	e8 f3 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01028a1:	89 f2                	mov    %esi,%edx
f01028a3:	89 f8                	mov    %edi,%eax
f01028a5:	e8 54 e6 ff ff       	call   f0100efe <check_va2pa>
f01028aa:	85 c0                	test   %eax,%eax
f01028ac:	74 19                	je     f01028c7 <mem_init+0x11ee>
f01028ae:	68 98 76 10 f0       	push   $0xf0107698
f01028b3:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01028b8:	68 3b 04 00 00       	push   $0x43b
f01028bd:	68 58 6c 10 f0       	push   $0xf0106c58
f01028c2:	e8 cd d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01028c7:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01028cd:	89 f8                	mov    %edi,%eax
f01028cf:	e8 2a e6 ff ff       	call   f0100efe <check_va2pa>
f01028d4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028d7:	74 19                	je     f01028f2 <mem_init+0x1219>
f01028d9:	68 bc 76 10 f0       	push   $0xf01076bc
f01028de:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01028e3:	68 3c 04 00 00       	push   $0x43c
f01028e8:	68 58 6c 10 f0       	push   $0xf0106c58
f01028ed:	e8 a2 d7 ff ff       	call   f0100094 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01028f2:	83 ec 04             	sub    $0x4,%esp
f01028f5:	6a 00                	push   $0x0
f01028f7:	53                   	push   %ebx
f01028f8:	57                   	push   %edi
f01028f9:	e8 e6 ea ff ff       	call   f01013e4 <pgdir_walk>
f01028fe:	83 c4 10             	add    $0x10,%esp
f0102901:	f6 00 1a             	testb  $0x1a,(%eax)
f0102904:	75 19                	jne    f010291f <mem_init+0x1246>
f0102906:	68 e8 76 10 f0       	push   $0xf01076e8
f010290b:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102910:	68 3e 04 00 00       	push   $0x43e
f0102915:	68 58 6c 10 f0       	push   $0xf0106c58
f010291a:	e8 75 d7 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010291f:	83 ec 04             	sub    $0x4,%esp
f0102922:	6a 00                	push   $0x0
f0102924:	53                   	push   %ebx
f0102925:	ff 35 94 be 22 f0    	pushl  0xf022be94
f010292b:	e8 b4 ea ff ff       	call   f01013e4 <pgdir_walk>
f0102930:	8b 00                	mov    (%eax),%eax
f0102932:	83 c4 10             	add    $0x10,%esp
f0102935:	83 e0 04             	and    $0x4,%eax
f0102938:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010293b:	74 19                	je     f0102956 <mem_init+0x127d>
f010293d:	68 2c 77 10 f0       	push   $0xf010772c
f0102942:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102947:	68 3f 04 00 00       	push   $0x43f
f010294c:	68 58 6c 10 f0       	push   $0xf0106c58
f0102951:	e8 3e d7 ff ff       	call   f0100094 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102956:	83 ec 04             	sub    $0x4,%esp
f0102959:	6a 00                	push   $0x0
f010295b:	53                   	push   %ebx
f010295c:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0102962:	e8 7d ea ff ff       	call   f01013e4 <pgdir_walk>
f0102967:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010296d:	83 c4 0c             	add    $0xc,%esp
f0102970:	6a 00                	push   $0x0
f0102972:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102975:	ff 35 94 be 22 f0    	pushl  0xf022be94
f010297b:	e8 64 ea ff ff       	call   f01013e4 <pgdir_walk>
f0102980:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102986:	83 c4 0c             	add    $0xc,%esp
f0102989:	6a 00                	push   $0x0
f010298b:	56                   	push   %esi
f010298c:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0102992:	e8 4d ea ff ff       	call   f01013e4 <pgdir_walk>
f0102997:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010299d:	c7 04 24 d1 6f 10 f0 	movl   $0xf0106fd1,(%esp)
f01029a4:	e8 29 11 00 00       	call   f0103ad2 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f01029a9:	a1 98 be 22 f0       	mov    0xf022be98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029ae:	83 c4 10             	add    $0x10,%esp
f01029b1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029b6:	77 15                	ja     f01029cd <mem_init+0x12f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029b8:	50                   	push   %eax
f01029b9:	68 88 65 10 f0       	push   $0xf0106588
f01029be:	68 c3 00 00 00       	push   $0xc3
f01029c3:	68 58 6c 10 f0       	push   $0xf0106c58
f01029c8:	e8 c7 d6 ff ff       	call   f0100094 <_panic>
f01029cd:	83 ec 08             	sub    $0x8,%esp
f01029d0:	6a 04                	push   $0x4
f01029d2:	05 00 00 00 10       	add    $0x10000000,%eax
f01029d7:	50                   	push   %eax
f01029d8:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01029dd:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01029e2:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f01029e7:	e8 8b ea ff ff       	call   f0101477 <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f01029ec:	a1 98 be 22 f0       	mov    0xf022be98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029f1:	83 c4 10             	add    $0x10,%esp
f01029f4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029f9:	77 15                	ja     f0102a10 <mem_init+0x1337>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029fb:	50                   	push   %eax
f01029fc:	68 88 65 10 f0       	push   $0xf0106588
f0102a01:	68 c5 00 00 00       	push   $0xc5
f0102a06:	68 58 6c 10 f0       	push   $0xf0106c58
f0102a0b:	e8 84 d6 ff ff       	call   f0100094 <_panic>
f0102a10:	83 ec 08             	sub    $0x8,%esp
f0102a13:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a18:	50                   	push   %eax
f0102a19:	68 ea 6f 10 f0       	push   $0xf0106fea
f0102a1e:	e8 af 10 00 00       	call   f0103ad2 <cprintf>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f0102a23:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a28:	83 c4 10             	add    $0x10,%esp
f0102a2b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a30:	77 15                	ja     f0102a47 <mem_init+0x136e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a32:	50                   	push   %eax
f0102a33:	68 88 65 10 f0       	push   $0xf0106588
f0102a38:	68 d0 00 00 00       	push   $0xd0
f0102a3d:	68 58 6c 10 f0       	push   $0xf0106c58
f0102a42:	e8 4d d6 ff ff       	call   f0100094 <_panic>
f0102a47:	83 ec 08             	sub    $0x8,%esp
f0102a4a:	6a 04                	push   $0x4
f0102a4c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a51:	50                   	push   %eax
f0102a52:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102a57:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102a5c:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f0102a61:	e8 11 ea ff ff       	call   f0101477 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a66:	83 c4 10             	add    $0x10,%esp
f0102a69:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102a6e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a73:	77 15                	ja     f0102a8a <mem_init+0x13b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a75:	50                   	push   %eax
f0102a76:	68 88 65 10 f0       	push   $0xf0106588
f0102a7b:	68 e2 00 00 00       	push   $0xe2
f0102a80:	68 58 6c 10 f0       	push   $0xf0106c58
f0102a85:	e8 0a d6 ff ff       	call   f0100094 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102a8a:	83 ec 08             	sub    $0x8,%esp
f0102a8d:	6a 02                	push   $0x2
f0102a8f:	68 00 70 11 00       	push   $0x117000
f0102a94:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102a99:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102a9e:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f0102aa3:	e8 cf e9 ff ff       	call   f0101477 <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f0102aa8:	83 c4 08             	add    $0x8,%esp
f0102aab:	68 00 70 11 00       	push   $0x117000
f0102ab0:	68 fb 6f 10 f0       	push   $0xf0106ffb
f0102ab5:	e8 18 10 00 00       	call   f0103ad2 <cprintf>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102aba:	83 c4 08             	add    $0x8,%esp
f0102abd:	6a 02                	push   $0x2
f0102abf:	6a 00                	push   $0x0
f0102ac1:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102ac6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102acb:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f0102ad0:	e8 a2 e9 ff ff       	call   f0101477 <boot_map_region>
f0102ad5:	c7 45 c4 00 d0 22 f0 	movl   $0xf022d000,-0x3c(%ebp)
f0102adc:	83 c4 10             	add    $0x10,%esp
f0102adf:	bb 00 d0 22 f0       	mov    $0xf022d000,%ebx
f0102ae4:	bf 00 80 ff ef       	mov    $0xefff8000,%edi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; ++i) {
f0102ae9:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("percpu_kstacks[%d]: %x\n", i, percpu_kstacks[i]);
f0102aee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0102af1:	83 ec 04             	sub    $0x4,%esp
f0102af4:	53                   	push   %ebx
f0102af5:	56                   	push   %esi
f0102af6:	68 10 70 10 f0       	push   $0xf0107010
f0102afb:	e8 d2 0f 00 00       	call   f0103ad2 <cprintf>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b00:	83 c4 10             	add    $0x10,%esp
f0102b03:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102b09:	77 17                	ja     f0102b22 <mem_init+0x1449>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b0b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102b0e:	68 88 65 10 f0       	push   $0xf0106588
f0102b13:	68 30 01 00 00       	push   $0x130
f0102b18:	68 58 6c 10 f0       	push   $0xf0106c58
f0102b1d:	e8 72 d5 ff ff       	call   f0100094 <_panic>
		boot_map_region(kern_pgdir, 
f0102b22:	83 ec 08             	sub    $0x8,%esp
f0102b25:	6a 02                	push   $0x2
f0102b27:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102b2d:	50                   	push   %eax
f0102b2e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102b33:	89 fa                	mov    %edi,%edx
f0102b35:	a1 94 be 22 f0       	mov    0xf022be94,%eax
f0102b3a:	e8 38 e9 ff ff       	call   f0101477 <boot_map_region>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; ++i) {
f0102b3f:	83 c6 01             	add    $0x1,%esi
f0102b42:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102b48:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102b4e:	83 c4 10             	add    $0x10,%esp
f0102b51:	83 fe 08             	cmp    $0x8,%esi
f0102b54:	75 98                	jne    f0102aee <mem_init+0x1415>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102b56:	8b 3d 94 be 22 f0    	mov    0xf022be94,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b5c:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0102b61:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102b64:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102b6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102b70:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b73:	8b 35 98 be 22 f0    	mov    0xf022be98,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b79:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102b7c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b81:	eb 55                	jmp    f0102bd8 <mem_init+0x14ff>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b83:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102b89:	89 f8                	mov    %edi,%eax
f0102b8b:	e8 6e e3 ff ff       	call   f0100efe <check_va2pa>
f0102b90:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102b97:	77 15                	ja     f0102bae <mem_init+0x14d5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b99:	56                   	push   %esi
f0102b9a:	68 88 65 10 f0       	push   $0xf0106588
f0102b9f:	68 54 03 00 00       	push   $0x354
f0102ba4:	68 58 6c 10 f0       	push   $0xf0106c58
f0102ba9:	e8 e6 d4 ff ff       	call   f0100094 <_panic>
f0102bae:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102bb5:	39 c2                	cmp    %eax,%edx
f0102bb7:	74 19                	je     f0102bd2 <mem_init+0x14f9>
f0102bb9:	68 60 77 10 f0       	push   $0xf0107760
f0102bbe:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102bc3:	68 54 03 00 00       	push   $0x354
f0102bc8:	68 58 6c 10 f0       	push   $0xf0106c58
f0102bcd:	e8 c2 d4 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102bd2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102bd8:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102bdb:	77 a6                	ja     f0102b83 <mem_init+0x14aa>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102bdd:	8b 35 48 b2 22 f0    	mov    0xf022b248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102be3:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102be6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102beb:	89 da                	mov    %ebx,%edx
f0102bed:	89 f8                	mov    %edi,%eax
f0102bef:	e8 0a e3 ff ff       	call   f0100efe <check_va2pa>
f0102bf4:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102bfb:	77 15                	ja     f0102c12 <mem_init+0x1539>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bfd:	56                   	push   %esi
f0102bfe:	68 88 65 10 f0       	push   $0xf0106588
f0102c03:	68 59 03 00 00       	push   $0x359
f0102c08:	68 58 6c 10 f0       	push   $0xf0106c58
f0102c0d:	e8 82 d4 ff ff       	call   f0100094 <_panic>
f0102c12:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102c19:	39 d0                	cmp    %edx,%eax
f0102c1b:	74 19                	je     f0102c36 <mem_init+0x155d>
f0102c1d:	68 94 77 10 f0       	push   $0xf0107794
f0102c22:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102c27:	68 59 03 00 00       	push   $0x359
f0102c2c:	68 58 6c 10 f0       	push   $0xf0106c58
f0102c31:	e8 5e d4 ff ff       	call   f0100094 <_panic>
f0102c36:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102c3c:	81 fb 00 00 c2 ee    	cmp    $0xeec20000,%ebx
f0102c42:	75 a7                	jne    f0102beb <mem_init+0x1512>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c44:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102c47:	c1 e6 0c             	shl    $0xc,%esi
f0102c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102c4f:	eb 30                	jmp    f0102c81 <mem_init+0x15a8>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c51:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102c57:	89 f8                	mov    %edi,%eax
f0102c59:	e8 a0 e2 ff ff       	call   f0100efe <check_va2pa>
f0102c5e:	39 c3                	cmp    %eax,%ebx
f0102c60:	74 19                	je     f0102c7b <mem_init+0x15a2>
f0102c62:	68 c8 77 10 f0       	push   $0xf01077c8
f0102c67:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102c6c:	68 5d 03 00 00       	push   $0x35d
f0102c71:	68 58 6c 10 f0       	push   $0xf0106c58
f0102c76:	e8 19 d4 ff ff       	call   f0100094 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c7b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c81:	39 f3                	cmp    %esi,%ebx
f0102c83:	72 cc                	jb     f0102c51 <mem_init+0x1578>
f0102c85:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102c8a:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102c8d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102c90:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102c93:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102c99:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102c9c:	89 c3                	mov    %eax,%ebx
			// check_va2pa(pgdir, base + KSTKGAP + i));

		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102c9e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102ca1:	05 00 80 00 20       	add    $0x20008000,%eax
f0102ca6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102ca9:	89 da                	mov    %ebx,%edx
f0102cab:	89 f8                	mov    %edi,%eax
f0102cad:	e8 4c e2 ff ff       	call   f0100efe <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cb2:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102cb8:	77 15                	ja     f0102ccf <mem_init+0x15f6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cba:	56                   	push   %esi
f0102cbb:	68 88 65 10 f0       	push   $0xf0106588
f0102cc0:	68 6a 03 00 00       	push   $0x36a
f0102cc5:	68 58 6c 10 f0       	push   $0xf0106c58
f0102cca:	e8 c5 d3 ff ff       	call   f0100094 <_panic>
f0102ccf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102cd2:	8d 94 0b 00 d0 22 f0 	lea    -0xfdd3000(%ebx,%ecx,1),%edx
f0102cd9:	39 d0                	cmp    %edx,%eax
f0102cdb:	74 19                	je     f0102cf6 <mem_init+0x161d>
f0102cdd:	68 f0 77 10 f0       	push   $0xf01077f0
f0102ce2:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102ce7:	68 6a 03 00 00       	push   $0x36a
f0102cec:	68 58 6c 10 f0       	push   $0xf0106c58
f0102cf1:	e8 9e d3 ff ff       	call   f0100094 <_panic>
f0102cf6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		// cprintf("check_va2pa(pgdir, base + KSTKGAP + i): %x\n", 
			// check_va2pa(pgdir, base + KSTKGAP + i));

		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102cfc:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102cff:	75 a8                	jne    f0102ca9 <mem_init+0x15d0>
f0102d01:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102d04:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102d0a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102d0d:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102d0f:	89 da                	mov    %ebx,%edx
f0102d11:	89 f8                	mov    %edi,%eax
f0102d13:	e8 e6 e1 ff ff       	call   f0100efe <check_va2pa>
f0102d18:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102d1b:	74 19                	je     f0102d36 <mem_init+0x165d>
f0102d1d:	68 38 78 10 f0       	push   $0xf0107838
f0102d22:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102d27:	68 6c 03 00 00       	push   $0x36c
f0102d2c:	68 58 6c 10 f0       	push   $0xf0106c58
f0102d31:	e8 5e d3 ff ff       	call   f0100094 <_panic>
f0102d36:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102d3c:	39 de                	cmp    %ebx,%esi
f0102d3e:	75 cf                	jne    f0102d0f <mem_init+0x1636>
f0102d40:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102d43:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102d4a:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102d51:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102d57:	b8 00 d0 26 f0       	mov    $0xf026d000,%eax
f0102d5c:	39 f0                	cmp    %esi,%eax
f0102d5e:	0f 85 2c ff ff ff    	jne    f0102c90 <mem_init+0x15b7>
f0102d64:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d69:	eb 2a                	jmp    f0102d95 <mem_init+0x16bc>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102d6b:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102d71:	83 fa 04             	cmp    $0x4,%edx
f0102d74:	77 1f                	ja     f0102d95 <mem_init+0x16bc>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102d76:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102d7a:	75 7e                	jne    f0102dfa <mem_init+0x1721>
f0102d7c:	68 28 70 10 f0       	push   $0xf0107028
f0102d81:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102d86:	68 77 03 00 00       	push   $0x377
f0102d8b:	68 58 6c 10 f0       	push   $0xf0106c58
f0102d90:	e8 ff d2 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102d95:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102d9a:	76 3f                	jbe    f0102ddb <mem_init+0x1702>
				assert(pgdir[i] & PTE_P);
f0102d9c:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102d9f:	f6 c2 01             	test   $0x1,%dl
f0102da2:	75 19                	jne    f0102dbd <mem_init+0x16e4>
f0102da4:	68 28 70 10 f0       	push   $0xf0107028
f0102da9:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102dae:	68 7b 03 00 00       	push   $0x37b
f0102db3:	68 58 6c 10 f0       	push   $0xf0106c58
f0102db8:	e8 d7 d2 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102dbd:	f6 c2 02             	test   $0x2,%dl
f0102dc0:	75 38                	jne    f0102dfa <mem_init+0x1721>
f0102dc2:	68 39 70 10 f0       	push   $0xf0107039
f0102dc7:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102dcc:	68 7c 03 00 00       	push   $0x37c
f0102dd1:	68 58 6c 10 f0       	push   $0xf0106c58
f0102dd6:	e8 b9 d2 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ddb:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102ddf:	74 19                	je     f0102dfa <mem_init+0x1721>
f0102de1:	68 4a 70 10 f0       	push   $0xf010704a
f0102de6:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102deb:	68 7e 03 00 00       	push   $0x37e
f0102df0:	68 58 6c 10 f0       	push   $0xf0106c58
f0102df5:	e8 9a d2 ff ff       	call   f0100094 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102dfa:	83 c0 01             	add    $0x1,%eax
f0102dfd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102e02:	0f 86 63 ff ff ff    	jbe    f0102d6b <mem_init+0x1692>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102e08:	83 ec 0c             	sub    $0xc,%esp
f0102e0b:	68 5c 78 10 f0       	push   $0xf010785c
f0102e10:	e8 bd 0c 00 00       	call   f0103ad2 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102e15:	a1 94 be 22 f0       	mov    0xf022be94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e1a:	83 c4 10             	add    $0x10,%esp
f0102e1d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e22:	77 15                	ja     f0102e39 <mem_init+0x1760>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e24:	50                   	push   %eax
f0102e25:	68 88 65 10 f0       	push   $0xf0106588
f0102e2a:	68 05 01 00 00       	push   $0x105
f0102e2f:	68 58 6c 10 f0       	push   $0xf0106c58
f0102e34:	e8 5b d2 ff ff       	call   f0100094 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102e39:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e3e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102e41:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e46:	e8 17 e1 ff ff       	call   f0100f62 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102e4b:	0f 20 c0             	mov    %cr0,%eax
f0102e4e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102e51:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102e56:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102e59:	83 ec 0c             	sub    $0xc,%esp
f0102e5c:	6a 00                	push   $0x0
f0102e5e:	e8 e1 e4 ff ff       	call   f0101344 <page_alloc>
f0102e63:	89 c3                	mov    %eax,%ebx
f0102e65:	83 c4 10             	add    $0x10,%esp
f0102e68:	85 c0                	test   %eax,%eax
f0102e6a:	75 19                	jne    f0102e85 <mem_init+0x17ac>
f0102e6c:	68 db 6d 10 f0       	push   $0xf0106ddb
f0102e71:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102e76:	68 54 04 00 00       	push   $0x454
f0102e7b:	68 58 6c 10 f0       	push   $0xf0106c58
f0102e80:	e8 0f d2 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e85:	83 ec 0c             	sub    $0xc,%esp
f0102e88:	6a 00                	push   $0x0
f0102e8a:	e8 b5 e4 ff ff       	call   f0101344 <page_alloc>
f0102e8f:	89 c7                	mov    %eax,%edi
f0102e91:	83 c4 10             	add    $0x10,%esp
f0102e94:	85 c0                	test   %eax,%eax
f0102e96:	75 19                	jne    f0102eb1 <mem_init+0x17d8>
f0102e98:	68 f1 6d 10 f0       	push   $0xf0106df1
f0102e9d:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102ea2:	68 55 04 00 00       	push   $0x455
f0102ea7:	68 58 6c 10 f0       	push   $0xf0106c58
f0102eac:	e8 e3 d1 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102eb1:	83 ec 0c             	sub    $0xc,%esp
f0102eb4:	6a 00                	push   $0x0
f0102eb6:	e8 89 e4 ff ff       	call   f0101344 <page_alloc>
f0102ebb:	89 c6                	mov    %eax,%esi
f0102ebd:	83 c4 10             	add    $0x10,%esp
f0102ec0:	85 c0                	test   %eax,%eax
f0102ec2:	75 19                	jne    f0102edd <mem_init+0x1804>
f0102ec4:	68 07 6e 10 f0       	push   $0xf0106e07
f0102ec9:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102ece:	68 56 04 00 00       	push   $0x456
f0102ed3:	68 58 6c 10 f0       	push   $0xf0106c58
f0102ed8:	e8 b7 d1 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102edd:	83 ec 0c             	sub    $0xc,%esp
f0102ee0:	53                   	push   %ebx
f0102ee1:	e8 c8 e4 ff ff       	call   f01013ae <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ee6:	89 f8                	mov    %edi,%eax
f0102ee8:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f0102eee:	c1 f8 03             	sar    $0x3,%eax
f0102ef1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ef4:	89 c2                	mov    %eax,%edx
f0102ef6:	c1 ea 0c             	shr    $0xc,%edx
f0102ef9:	83 c4 10             	add    $0x10,%esp
f0102efc:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f0102f02:	72 12                	jb     f0102f16 <mem_init+0x183d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f04:	50                   	push   %eax
f0102f05:	68 3c 65 10 f0       	push   $0xf010653c
f0102f0a:	6a 58                	push   $0x58
f0102f0c:	68 64 6c 10 f0       	push   $0xf0106c64
f0102f11:	e8 7e d1 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102f16:	83 ec 04             	sub    $0x4,%esp
f0102f19:	68 00 10 00 00       	push   $0x1000
f0102f1e:	6a 01                	push   $0x1
f0102f20:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f25:	50                   	push   %eax
f0102f26:	e8 12 28 00 00       	call   f010573d <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f2b:	89 f0                	mov    %esi,%eax
f0102f2d:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f0102f33:	c1 f8 03             	sar    $0x3,%eax
f0102f36:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f39:	89 c2                	mov    %eax,%edx
f0102f3b:	c1 ea 0c             	shr    $0xc,%edx
f0102f3e:	83 c4 10             	add    $0x10,%esp
f0102f41:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f0102f47:	72 12                	jb     f0102f5b <mem_init+0x1882>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f49:	50                   	push   %eax
f0102f4a:	68 3c 65 10 f0       	push   $0xf010653c
f0102f4f:	6a 58                	push   $0x58
f0102f51:	68 64 6c 10 f0       	push   $0xf0106c64
f0102f56:	e8 39 d1 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102f5b:	83 ec 04             	sub    $0x4,%esp
f0102f5e:	68 00 10 00 00       	push   $0x1000
f0102f63:	6a 02                	push   $0x2
f0102f65:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f6a:	50                   	push   %eax
f0102f6b:	e8 cd 27 00 00       	call   f010573d <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102f70:	6a 02                	push   $0x2
f0102f72:	68 00 10 00 00       	push   $0x1000
f0102f77:	57                   	push   %edi
f0102f78:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0102f7e:	e8 83 e6 ff ff       	call   f0101606 <page_insert>
	assert(pp1->pp_ref == 1);
f0102f83:	83 c4 20             	add    $0x20,%esp
f0102f86:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102f8b:	74 19                	je     f0102fa6 <mem_init+0x18cd>
f0102f8d:	68 e8 6e 10 f0       	push   $0xf0106ee8
f0102f92:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102f97:	68 5b 04 00 00       	push   $0x45b
f0102f9c:	68 58 6c 10 f0       	push   $0xf0106c58
f0102fa1:	e8 ee d0 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102fa6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102fad:	01 01 01 
f0102fb0:	74 19                	je     f0102fcb <mem_init+0x18f2>
f0102fb2:	68 7c 78 10 f0       	push   $0xf010787c
f0102fb7:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102fbc:	68 5c 04 00 00       	push   $0x45c
f0102fc1:	68 58 6c 10 f0       	push   $0xf0106c58
f0102fc6:	e8 c9 d0 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102fcb:	6a 02                	push   $0x2
f0102fcd:	68 00 10 00 00       	push   $0x1000
f0102fd2:	56                   	push   %esi
f0102fd3:	ff 35 94 be 22 f0    	pushl  0xf022be94
f0102fd9:	e8 28 e6 ff ff       	call   f0101606 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102fde:	83 c4 10             	add    $0x10,%esp
f0102fe1:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102fe8:	02 02 02 
f0102feb:	74 19                	je     f0103006 <mem_init+0x192d>
f0102fed:	68 a0 78 10 f0       	push   $0xf01078a0
f0102ff2:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0102ff7:	68 5e 04 00 00       	push   $0x45e
f0102ffc:	68 58 6c 10 f0       	push   $0xf0106c58
f0103001:	e8 8e d0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0103006:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010300b:	74 19                	je     f0103026 <mem_init+0x194d>
f010300d:	68 0a 6f 10 f0       	push   $0xf0106f0a
f0103012:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0103017:	68 5f 04 00 00       	push   $0x45f
f010301c:	68 58 6c 10 f0       	push   $0xf0106c58
f0103021:	e8 6e d0 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0103026:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010302b:	74 19                	je     f0103046 <mem_init+0x196d>
f010302d:	68 7f 6f 10 f0       	push   $0xf0106f7f
f0103032:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0103037:	68 60 04 00 00       	push   $0x460
f010303c:	68 58 6c 10 f0       	push   $0xf0106c58
f0103041:	e8 4e d0 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103046:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010304d:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103050:	89 f0                	mov    %esi,%eax
f0103052:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f0103058:	c1 f8 03             	sar    $0x3,%eax
f010305b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010305e:	89 c2                	mov    %eax,%edx
f0103060:	c1 ea 0c             	shr    $0xc,%edx
f0103063:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f0103069:	72 12                	jb     f010307d <mem_init+0x19a4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010306b:	50                   	push   %eax
f010306c:	68 3c 65 10 f0       	push   $0xf010653c
f0103071:	6a 58                	push   $0x58
f0103073:	68 64 6c 10 f0       	push   $0xf0106c64
f0103078:	e8 17 d0 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010307d:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103084:	03 03 03 
f0103087:	74 19                	je     f01030a2 <mem_init+0x19c9>
f0103089:	68 c4 78 10 f0       	push   $0xf01078c4
f010308e:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0103093:	68 62 04 00 00       	push   $0x462
f0103098:	68 58 6c 10 f0       	push   $0xf0106c58
f010309d:	e8 f2 cf ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01030a2:	83 ec 08             	sub    $0x8,%esp
f01030a5:	68 00 10 00 00       	push   $0x1000
f01030aa:	ff 35 94 be 22 f0    	pushl  0xf022be94
f01030b0:	e8 03 e5 ff ff       	call   f01015b8 <page_remove>
	assert(pp2->pp_ref == 0);
f01030b5:	83 c4 10             	add    $0x10,%esp
f01030b8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01030bd:	74 19                	je     f01030d8 <mem_init+0x19ff>
f01030bf:	68 6e 6f 10 f0       	push   $0xf0106f6e
f01030c4:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01030c9:	68 64 04 00 00       	push   $0x464
f01030ce:	68 58 6c 10 f0       	push   $0xf0106c58
f01030d3:	e8 bc cf ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01030d8:	8b 0d 94 be 22 f0    	mov    0xf022be94,%ecx
f01030de:	8b 11                	mov    (%ecx),%edx
f01030e0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01030e6:	89 d8                	mov    %ebx,%eax
f01030e8:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f01030ee:	c1 f8 03             	sar    $0x3,%eax
f01030f1:	c1 e0 0c             	shl    $0xc,%eax
f01030f4:	39 c2                	cmp    %eax,%edx
f01030f6:	74 19                	je     f0103111 <mem_init+0x1a38>
f01030f8:	68 84 72 10 f0       	push   $0xf0107284
f01030fd:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0103102:	68 67 04 00 00       	push   $0x467
f0103107:	68 58 6c 10 f0       	push   $0xf0106c58
f010310c:	e8 83 cf ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0103111:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0103117:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010311c:	74 19                	je     f0103137 <mem_init+0x1a5e>
f010311e:	68 f9 6e 10 f0       	push   $0xf0106ef9
f0103123:	68 7e 6c 10 f0       	push   $0xf0106c7e
f0103128:	68 69 04 00 00       	push   $0x469
f010312d:	68 58 6c 10 f0       	push   $0xf0106c58
f0103132:	e8 5d cf ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0103137:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010313d:	83 ec 0c             	sub    $0xc,%esp
f0103140:	53                   	push   %ebx
f0103141:	e8 68 e2 ff ff       	call   f01013ae <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103146:	c7 04 24 f0 78 10 f0 	movl   $0xf01078f0,(%esp)
f010314d:	e8 80 09 00 00       	call   f0103ad2 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103152:	83 c4 10             	add    $0x10,%esp
f0103155:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103158:	5b                   	pop    %ebx
f0103159:	5e                   	pop    %esi
f010315a:	5f                   	pop    %edi
f010315b:	5d                   	pop    %ebp
f010315c:	c3                   	ret    

f010315d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010315d:	55                   	push   %ebp
f010315e:	89 e5                	mov    %esp,%ebp
f0103160:	57                   	push   %edi
f0103161:	56                   	push   %esi
f0103162:	53                   	push   %ebx
f0103163:	83 ec 1c             	sub    $0x1c,%esp
f0103166:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103169:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	// cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f010316c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010316f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0103175:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103178:	03 45 10             	add    0x10(%ebp),%eax
f010317b:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103180:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103185:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0103188:	eb 43                	jmp    f01031cd <user_mem_check+0x70>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f010318a:	83 ec 04             	sub    $0x4,%esp
f010318d:	6a 00                	push   $0x0
f010318f:	53                   	push   %ebx
f0103190:	ff 77 60             	pushl  0x60(%edi)
f0103193:	e8 4c e2 ff ff       	call   f01013e4 <pgdir_walk>
		// pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0103198:	83 c4 10             	add    $0x10,%esp
f010319b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01031a1:	77 10                	ja     f01031b3 <user_mem_check+0x56>
f01031a3:	85 c0                	test   %eax,%eax
f01031a5:	74 0c                	je     f01031b3 <user_mem_check+0x56>
f01031a7:	8b 00                	mov    (%eax),%eax
f01031a9:	a8 01                	test   $0x1,%al
f01031ab:	74 06                	je     f01031b3 <user_mem_check+0x56>
f01031ad:	21 f0                	and    %esi,%eax
f01031af:	39 c6                	cmp    %eax,%esi
f01031b1:	74 14                	je     f01031c7 <user_mem_check+0x6a>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f01031b3:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01031b6:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f01031ba:	89 1d 3c b2 22 f0    	mov    %ebx,0xf022b23c
			return -E_FAULT;
f01031c0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01031c5:	eb 10                	jmp    f01031d7 <user_mem_check+0x7a>
	// LAB 3: Your code here.
	// cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f01031c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031cd:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01031d0:	72 b8                	jb     f010318a <user_mem_check+0x2d>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
			return -E_FAULT;
		}
	}
	// cprintf("user_mem_check success va: %x, len: %x\n", va, len);
	return 0;
f01031d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031da:	5b                   	pop    %ebx
f01031db:	5e                   	pop    %esi
f01031dc:	5f                   	pop    %edi
f01031dd:	5d                   	pop    %ebp
f01031de:	c3                   	ret    

f01031df <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01031df:	55                   	push   %ebp
f01031e0:	89 e5                	mov    %esp,%ebp
f01031e2:	53                   	push   %ebx
f01031e3:	83 ec 04             	sub    $0x4,%esp
f01031e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01031e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01031ec:	83 c8 04             	or     $0x4,%eax
f01031ef:	50                   	push   %eax
f01031f0:	ff 75 10             	pushl  0x10(%ebp)
f01031f3:	ff 75 0c             	pushl  0xc(%ebp)
f01031f6:	53                   	push   %ebx
f01031f7:	e8 61 ff ff ff       	call   f010315d <user_mem_check>
f01031fc:	83 c4 10             	add    $0x10,%esp
f01031ff:	85 c0                	test   %eax,%eax
f0103201:	79 21                	jns    f0103224 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103203:	83 ec 04             	sub    $0x4,%esp
f0103206:	ff 35 3c b2 22 f0    	pushl  0xf022b23c
f010320c:	ff 73 48             	pushl  0x48(%ebx)
f010320f:	68 1c 79 10 f0       	push   $0xf010791c
f0103214:	e8 b9 08 00 00       	call   f0103ad2 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103219:	89 1c 24             	mov    %ebx,(%esp)
f010321c:	e8 e7 05 00 00       	call   f0103808 <env_destroy>
f0103221:	83 c4 10             	add    $0x10,%esp
	}
}
f0103224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103227:	c9                   	leave  
f0103228:	c3                   	ret    

f0103229 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103229:	55                   	push   %ebp
f010322a:	89 e5                	mov    %esp,%ebp
f010322c:	57                   	push   %edi
f010322d:	56                   	push   %esi
f010322e:	53                   	push   %ebx
f010322f:	83 ec 0c             	sub    $0xc,%esp
f0103232:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f0103234:	89 d3                	mov    %edx,%ebx
f0103236:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010323c:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103243:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	// cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin < end; begin += PGSIZE) {
f0103249:	eb 3d                	jmp    f0103288 <region_alloc+0x5f>
		struct PageInfo *pg = page_alloc(0);
f010324b:	83 ec 0c             	sub    $0xc,%esp
f010324e:	6a 00                	push   $0x0
f0103250:	e8 ef e0 ff ff       	call   f0101344 <page_alloc>
		if (!pg) panic("region_alloc failed!");
f0103255:	83 c4 10             	add    $0x10,%esp
f0103258:	85 c0                	test   %eax,%eax
f010325a:	75 17                	jne    f0103273 <region_alloc+0x4a>
f010325c:	83 ec 04             	sub    $0x4,%esp
f010325f:	68 51 79 10 f0       	push   $0xf0107951
f0103264:	68 23 01 00 00       	push   $0x123
f0103269:	68 66 79 10 f0       	push   $0xf0107966
f010326e:	e8 21 ce ff ff       	call   f0100094 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0103273:	6a 06                	push   $0x6
f0103275:	53                   	push   %ebx
f0103276:	50                   	push   %eax
f0103277:	ff 77 60             	pushl  0x60(%edi)
f010327a:	e8 87 e3 ff ff       	call   f0101606 <page_insert>
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	// cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin < end; begin += PGSIZE) {
f010327f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103285:	83 c4 10             	add    $0x10,%esp
f0103288:	39 f3                	cmp    %esi,%ebx
f010328a:	72 bf                	jb     f010324b <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f010328c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010328f:	5b                   	pop    %ebx
f0103290:	5e                   	pop    %esi
f0103291:	5f                   	pop    %edi
f0103292:	5d                   	pop    %ebp
f0103293:	c3                   	ret    

f0103294 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103294:	55                   	push   %ebp
f0103295:	89 e5                	mov    %esp,%ebp
f0103297:	56                   	push   %esi
f0103298:	53                   	push   %ebx
f0103299:	8b 45 08             	mov    0x8(%ebp),%eax
f010329c:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010329f:	85 c0                	test   %eax,%eax
f01032a1:	75 1a                	jne    f01032bd <envid2env+0x29>
		*env_store = curenv;
f01032a3:	e8 b4 2a 00 00       	call   f0105d5c <cpunum>
f01032a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01032ab:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01032b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01032b4:	89 01                	mov    %eax,(%ecx)
		return 0;
f01032b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01032bb:	eb 70                	jmp    f010332d <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01032bd:	89 c3                	mov    %eax,%ebx
f01032bf:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01032c5:	c1 e3 07             	shl    $0x7,%ebx
f01032c8:	03 1d 48 b2 22 f0    	add    0xf022b248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01032ce:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01032d2:	74 05                	je     f01032d9 <envid2env+0x45>
f01032d4:	3b 43 48             	cmp    0x48(%ebx),%eax
f01032d7:	74 10                	je     f01032e9 <envid2env+0x55>
		*env_store = 0;
f01032d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01032e2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01032e7:	eb 44                	jmp    f010332d <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01032e9:	84 d2                	test   %dl,%dl
f01032eb:	74 36                	je     f0103323 <envid2env+0x8f>
f01032ed:	e8 6a 2a 00 00       	call   f0105d5c <cpunum>
f01032f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01032f5:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f01032fb:	74 26                	je     f0103323 <envid2env+0x8f>
f01032fd:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103300:	e8 57 2a 00 00       	call   f0105d5c <cpunum>
f0103305:	6b c0 74             	imul   $0x74,%eax,%eax
f0103308:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010330e:	3b 70 48             	cmp    0x48(%eax),%esi
f0103311:	74 10                	je     f0103323 <envid2env+0x8f>
		*env_store = 0;
f0103313:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103316:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010331c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103321:	eb 0a                	jmp    f010332d <envid2env+0x99>
	}

	*env_store = e;
f0103323:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103326:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103328:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010332d:	5b                   	pop    %ebx
f010332e:	5e                   	pop    %esi
f010332f:	5d                   	pop    %ebp
f0103330:	c3                   	ret    

f0103331 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103331:	55                   	push   %ebp
f0103332:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103334:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0103339:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010333c:	b8 23 00 00 00       	mov    $0x23,%eax
f0103341:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103343:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103345:	b8 10 00 00 00       	mov    $0x10,%eax
f010334a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010334c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010334e:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103350:	ea 57 33 10 f0 08 00 	ljmp   $0x8,$0xf0103357
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103357:	b8 00 00 00 00       	mov    $0x0,%eax
f010335c:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010335f:	5d                   	pop    %ebp
f0103360:	c3                   	ret    

f0103361 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103361:	55                   	push   %ebp
f0103362:	89 e5                	mov    %esp,%ebp
f0103364:	56                   	push   %esi
f0103365:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
		envs[i].env_id = 0;
f0103366:	8b 35 48 b2 22 f0    	mov    0xf022b248,%esi
f010336c:	8b 15 4c b2 22 f0    	mov    0xf022b24c,%edx
f0103372:	8d 86 80 ff 01 00    	lea    0x1ff80(%esi),%eax
f0103378:	8d 5e 80             	lea    -0x80(%esi),%ebx
f010337b:	89 c1                	mov    %eax,%ecx
f010337d:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103384:	89 50 44             	mov    %edx,0x44(%eax)
f0103387:	83 c0 80             	add    $0xffffff80,%eax
		env_free_list = envs+i;
f010338a:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
f010338c:	39 d8                	cmp    %ebx,%eax
f010338e:	75 eb                	jne    f010337b <env_init+0x1a>
f0103390:	89 35 4c b2 22 f0    	mov    %esi,0xf022b24c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103396:	e8 96 ff ff ff       	call   f0103331 <env_init_percpu>
}
f010339b:	5b                   	pop    %ebx
f010339c:	5e                   	pop    %esi
f010339d:	5d                   	pop    %ebp
f010339e:	c3                   	ret    

f010339f <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010339f:	55                   	push   %ebp
f01033a0:	89 e5                	mov    %esp,%ebp
f01033a2:	53                   	push   %ebx
f01033a3:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01033a6:	8b 1d 4c b2 22 f0    	mov    0xf022b24c,%ebx
f01033ac:	85 db                	test   %ebx,%ebx
f01033ae:	0f 84 63 01 00 00    	je     f0103517 <env_alloc+0x178>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01033b4:	83 ec 0c             	sub    $0xc,%esp
f01033b7:	6a 01                	push   $0x1
f01033b9:	e8 86 df ff ff       	call   f0101344 <page_alloc>
f01033be:	83 c4 10             	add    $0x10,%esp
f01033c1:	85 c0                	test   %eax,%eax
f01033c3:	0f 84 55 01 00 00    	je     f010351e <env_alloc+0x17f>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f01033c9:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033ce:	2b 05 98 be 22 f0    	sub    0xf022be98,%eax
f01033d4:	c1 f8 03             	sar    $0x3,%eax
f01033d7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033da:	89 c2                	mov    %eax,%edx
f01033dc:	c1 ea 0c             	shr    $0xc,%edx
f01033df:	3b 15 90 be 22 f0    	cmp    0xf022be90,%edx
f01033e5:	72 12                	jb     f01033f9 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033e7:	50                   	push   %eax
f01033e8:	68 3c 65 10 f0       	push   $0xf010653c
f01033ed:	6a 58                	push   $0x58
f01033ef:	68 64 6c 10 f0       	push   $0xf0106c64
f01033f4:	e8 9b cc ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01033f9:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f01033fe:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103401:	83 ec 04             	sub    $0x4,%esp
f0103404:	68 00 10 00 00       	push   $0x1000
f0103409:	ff 35 94 be 22 f0    	pushl  0xf022be94
f010340f:	50                   	push   %eax
f0103410:	e8 dd 23 00 00       	call   f01057f2 <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103415:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103418:	83 c4 10             	add    $0x10,%esp
f010341b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103420:	77 15                	ja     f0103437 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103422:	50                   	push   %eax
f0103423:	68 88 65 10 f0       	push   $0xf0106588
f0103428:	68 c4 00 00 00       	push   $0xc4
f010342d:	68 66 79 10 f0       	push   $0xf0107966
f0103432:	e8 5d cc ff ff       	call   f0100094 <_panic>
f0103437:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010343d:	83 ca 05             	or     $0x5,%edx
f0103440:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103446:	8b 43 48             	mov    0x48(%ebx),%eax
f0103449:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010344e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103453:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103458:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010345b:	89 da                	mov    %ebx,%edx
f010345d:	2b 15 48 b2 22 f0    	sub    0xf022b248,%edx
f0103463:	c1 fa 07             	sar    $0x7,%edx
f0103466:	09 d0                	or     %edx,%eax
f0103468:	89 43 48             	mov    %eax,0x48(%ebx)
	// cprintf("envs: %x, e: %x, e->env_id: %x\n", envs, e, e->env_id);

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010346b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010346e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103471:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103478:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010347f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103486:	83 ec 04             	sub    $0x4,%esp
f0103489:	6a 44                	push   $0x44
f010348b:	6a 00                	push   $0x0
f010348d:	53                   	push   %ebx
f010348e:	e8 aa 22 00 00       	call   f010573d <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103493:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103499:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010349f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01034a5:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01034ac:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01034b2:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01034b9:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01034c0:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01034c4:	8b 43 44             	mov    0x44(%ebx),%eax
f01034c7:	a3 4c b2 22 f0       	mov    %eax,0xf022b24c
	*newenv_store = e;
f01034cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01034cf:	89 18                	mov    %ebx,(%eax)

	// cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01034d1:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01034d4:	e8 83 28 00 00       	call   f0105d5c <cpunum>
f01034d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01034dc:	83 c4 10             	add    $0x10,%esp
f01034df:	ba 00 00 00 00       	mov    $0x0,%edx
f01034e4:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01034eb:	74 11                	je     f01034fe <env_alloc+0x15f>
f01034ed:	e8 6a 28 00 00       	call   f0105d5c <cpunum>
f01034f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01034f5:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01034fb:	8b 50 48             	mov    0x48(%eax),%edx
f01034fe:	83 ec 04             	sub    $0x4,%esp
f0103501:	53                   	push   %ebx
f0103502:	52                   	push   %edx
f0103503:	68 71 79 10 f0       	push   $0xf0107971
f0103508:	e8 c5 05 00 00       	call   f0103ad2 <cprintf>
	return 0;
f010350d:	83 c4 10             	add    $0x10,%esp
f0103510:	b8 00 00 00 00       	mov    $0x0,%eax
f0103515:	eb 0c                	jmp    f0103523 <env_alloc+0x184>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103517:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010351c:	eb 05                	jmp    f0103523 <env_alloc+0x184>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010351e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	*newenv_store = e;

	// cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103526:	c9                   	leave  
f0103527:	c3                   	ret    

f0103528 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103528:	55                   	push   %ebp
f0103529:	89 e5                	mov    %esp,%ebp
f010352b:	57                   	push   %edi
f010352c:	56                   	push   %esi
f010352d:	53                   	push   %ebx
f010352e:	83 ec 34             	sub    $0x34,%esp
f0103531:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
f0103534:	6a 00                	push   $0x0
f0103536:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103539:	50                   	push   %eax
f010353a:	e8 60 fe ff ff       	call   f010339f <env_alloc>
	load_icode(penv, binary, size);
f010353f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103542:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
f0103545:	83 c4 10             	add    $0x10,%esp
f0103548:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010354e:	74 17                	je     f0103567 <env_create+0x3f>
		panic("Not executable!");
f0103550:	83 ec 04             	sub    $0x4,%esp
f0103553:	68 86 79 10 f0       	push   $0xf0107986
f0103558:	68 60 01 00 00       	push   $0x160
f010355d:	68 66 79 10 f0       	push   $0xf0107966
f0103562:	e8 2d cb ff ff       	call   f0100094 <_panic>
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103567:	89 fb                	mov    %edi,%ebx
f0103569:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f010356c:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103570:	c1 e6 05             	shl    $0x5,%esi
f0103573:	01 de                	add    %ebx,%esi
	//  The ph->p_filesz bytes from the ELF binary, starting at
	//  'binary + ph->p_offset', should be copied to virtual address
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
f0103575:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103578:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010357b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103580:	77 15                	ja     f0103597 <env_create+0x6f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103582:	50                   	push   %eax
f0103583:	68 88 65 10 f0       	push   $0xf0106588
f0103588:	68 6c 01 00 00       	push   $0x16c
f010358d:	68 66 79 10 f0       	push   $0xf0107966
f0103592:	e8 fd ca ff ff       	call   f0100094 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103597:	05 00 00 00 10       	add    $0x10000000,%eax
f010359c:	0f 22 d8             	mov    %eax,%cr3
f010359f:	eb 3d                	jmp    f01035de <env_create+0xb6>
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f01035a1:	83 3b 01             	cmpl   $0x1,(%ebx)
f01035a4:	75 35                	jne    f01035db <env_create+0xb3>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01035a6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01035a9:	8b 53 08             	mov    0x8(%ebx),%edx
f01035ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035af:	e8 75 fc ff ff       	call   f0103229 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f01035b4:	83 ec 04             	sub    $0x4,%esp
f01035b7:	ff 73 14             	pushl  0x14(%ebx)
f01035ba:	6a 00                	push   $0x0
f01035bc:	ff 73 08             	pushl  0x8(%ebx)
f01035bf:	e8 79 21 00 00       	call   f010573d <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f01035c4:	83 c4 0c             	add    $0xc,%esp
f01035c7:	ff 73 10             	pushl  0x10(%ebx)
f01035ca:	89 f8                	mov    %edi,%eax
f01035cc:	03 43 04             	add    0x4(%ebx),%eax
f01035cf:	50                   	push   %eax
f01035d0:	ff 73 08             	pushl  0x8(%ebx)
f01035d3:	e8 1a 22 00 00       	call   f01057f2 <memcpy>
f01035d8:	83 c4 10             	add    $0x10,%esp
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f01035db:	83 c3 20             	add    $0x20,%ebx
f01035de:	39 de                	cmp    %ebx,%esi
f01035e0:	77 bf                	ja     f01035a1 <env_create+0x79>
			// 	cprintf("region_alloc %x %x %x\n", ph->p_va, ph->p_memsz, *(int*)0x802008);
			//but I'm curious about how exactly p_memsz and p_filesz differs
			// cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
		}
	//we can use this because kern_pgdir is a subset of e->env_pgdir
	lcr3(PADDR(kern_pgdir));
f01035e2:	a1 94 be 22 f0       	mov    0xf022be94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035ec:	77 15                	ja     f0103603 <env_create+0xdb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035ee:	50                   	push   %eax
f01035ef:	68 88 65 10 f0       	push   $0xf0106588
f01035f4:	68 79 01 00 00       	push   $0x179
f01035f9:	68 66 79 10 f0       	push   $0xf0107966
f01035fe:	e8 91 ca ff ff       	call   f0100094 <_panic>
f0103603:	05 00 00 00 10       	add    $0x10000000,%eax
f0103608:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	e->env_tf.tf_eip = ELFHDR->e_entry;
f010360b:	8b 47 18             	mov    0x18(%edi),%eax
f010360e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103611:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103614:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103619:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010361e:	89 f8                	mov    %edi,%eax
f0103620:	e8 04 fc ff ff       	call   f0103229 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
	load_icode(penv, binary, size);
}
f0103625:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103628:	5b                   	pop    %ebx
f0103629:	5e                   	pop    %esi
f010362a:	5f                   	pop    %edi
f010362b:	5d                   	pop    %ebp
f010362c:	c3                   	ret    

f010362d <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010362d:	55                   	push   %ebp
f010362e:	89 e5                	mov    %esp,%ebp
f0103630:	57                   	push   %edi
f0103631:	56                   	push   %esi
f0103632:	53                   	push   %ebx
f0103633:	83 ec 1c             	sub    $0x1c,%esp
f0103636:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103639:	e8 1e 27 00 00       	call   f0105d5c <cpunum>
f010363e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103641:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f0103647:	75 29                	jne    f0103672 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f0103649:	a1 94 be 22 f0       	mov    0xf022be94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010364e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103653:	77 15                	ja     f010366a <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103655:	50                   	push   %eax
f0103656:	68 88 65 10 f0       	push   $0xf0106588
f010365b:	68 9f 01 00 00       	push   $0x19f
f0103660:	68 66 79 10 f0       	push   $0xf0107966
f0103665:	e8 2a ca ff ff       	call   f0100094 <_panic>
f010366a:	05 00 00 00 10       	add    $0x10000000,%eax
f010366f:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103672:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103675:	e8 e2 26 00 00       	call   f0105d5c <cpunum>
f010367a:	6b c0 74             	imul   $0x74,%eax,%eax
f010367d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103682:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103689:	74 11                	je     f010369c <env_free+0x6f>
f010368b:	e8 cc 26 00 00       	call   f0105d5c <cpunum>
f0103690:	6b c0 74             	imul   $0x74,%eax,%eax
f0103693:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103699:	8b 50 48             	mov    0x48(%eax),%edx
f010369c:	83 ec 04             	sub    $0x4,%esp
f010369f:	53                   	push   %ebx
f01036a0:	52                   	push   %edx
f01036a1:	68 96 79 10 f0       	push   $0xf0107996
f01036a6:	e8 27 04 00 00       	call   f0103ad2 <cprintf>
f01036ab:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01036ae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01036b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01036b8:	89 d0                	mov    %edx,%eax
f01036ba:	c1 e0 02             	shl    $0x2,%eax
f01036bd:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01036c0:	8b 47 60             	mov    0x60(%edi),%eax
f01036c3:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01036c6:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01036cc:	0f 84 a8 00 00 00    	je     f010377a <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01036d2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01036d8:	89 f0                	mov    %esi,%eax
f01036da:	c1 e8 0c             	shr    $0xc,%eax
f01036dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01036e0:	39 05 90 be 22 f0    	cmp    %eax,0xf022be90
f01036e6:	77 15                	ja     f01036fd <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036e8:	56                   	push   %esi
f01036e9:	68 3c 65 10 f0       	push   $0xf010653c
f01036ee:	68 ae 01 00 00       	push   $0x1ae
f01036f3:	68 66 79 10 f0       	push   $0xf0107966
f01036f8:	e8 97 c9 ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01036fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103700:	c1 e0 16             	shl    $0x16,%eax
f0103703:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103706:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010370b:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103712:	01 
f0103713:	74 17                	je     f010372c <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103715:	83 ec 08             	sub    $0x8,%esp
f0103718:	89 d8                	mov    %ebx,%eax
f010371a:	c1 e0 0c             	shl    $0xc,%eax
f010371d:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103720:	50                   	push   %eax
f0103721:	ff 77 60             	pushl  0x60(%edi)
f0103724:	e8 8f de ff ff       	call   f01015b8 <page_remove>
f0103729:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010372c:	83 c3 01             	add    $0x1,%ebx
f010372f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103735:	75 d4                	jne    f010370b <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103737:	8b 47 60             	mov    0x60(%edi),%eax
f010373a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010373d:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103744:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103747:	3b 05 90 be 22 f0    	cmp    0xf022be90,%eax
f010374d:	72 14                	jb     f0103763 <env_free+0x136>
		panic("pa2page called with invalid pa");
f010374f:	83 ec 04             	sub    $0x4,%esp
f0103752:	68 50 71 10 f0       	push   $0xf0107150
f0103757:	6a 51                	push   $0x51
f0103759:	68 64 6c 10 f0       	push   $0xf0106c64
f010375e:	e8 31 c9 ff ff       	call   f0100094 <_panic>
		page_decref(pa2page(pa));
f0103763:	83 ec 0c             	sub    $0xc,%esp
f0103766:	a1 98 be 22 f0       	mov    0xf022be98,%eax
f010376b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010376e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103771:	50                   	push   %eax
f0103772:	e8 4c dc ff ff       	call   f01013c3 <page_decref>
f0103777:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010377a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010377e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103781:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103786:	0f 85 29 ff ff ff    	jne    f01036b5 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010378c:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010378f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103794:	77 15                	ja     f01037ab <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103796:	50                   	push   %eax
f0103797:	68 88 65 10 f0       	push   $0xf0106588
f010379c:	68 bc 01 00 00       	push   $0x1bc
f01037a1:	68 66 79 10 f0       	push   $0xf0107966
f01037a6:	e8 e9 c8 ff ff       	call   f0100094 <_panic>
	e->env_pgdir = 0;
f01037ab:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037b2:	05 00 00 00 10       	add    $0x10000000,%eax
f01037b7:	c1 e8 0c             	shr    $0xc,%eax
f01037ba:	3b 05 90 be 22 f0    	cmp    0xf022be90,%eax
f01037c0:	72 14                	jb     f01037d6 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01037c2:	83 ec 04             	sub    $0x4,%esp
f01037c5:	68 50 71 10 f0       	push   $0xf0107150
f01037ca:	6a 51                	push   $0x51
f01037cc:	68 64 6c 10 f0       	push   $0xf0106c64
f01037d1:	e8 be c8 ff ff       	call   f0100094 <_panic>
	page_decref(pa2page(pa));
f01037d6:	83 ec 0c             	sub    $0xc,%esp
f01037d9:	8b 15 98 be 22 f0    	mov    0xf022be98,%edx
f01037df:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01037e2:	50                   	push   %eax
f01037e3:	e8 db db ff ff       	call   f01013c3 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01037e8:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01037ef:	a1 4c b2 22 f0       	mov    0xf022b24c,%eax
f01037f4:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01037f7:	89 3d 4c b2 22 f0    	mov    %edi,0xf022b24c
}
f01037fd:	83 c4 10             	add    $0x10,%esp
f0103800:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103803:	5b                   	pop    %ebx
f0103804:	5e                   	pop    %esi
f0103805:	5f                   	pop    %edi
f0103806:	5d                   	pop    %ebp
f0103807:	c3                   	ret    

f0103808 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103808:	55                   	push   %ebp
f0103809:	89 e5                	mov    %esp,%ebp
f010380b:	53                   	push   %ebx
f010380c:	83 ec 04             	sub    $0x4,%esp
f010380f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103812:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103816:	75 19                	jne    f0103831 <env_destroy+0x29>
f0103818:	e8 3f 25 00 00       	call   f0105d5c <cpunum>
f010381d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103820:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f0103826:	74 09                	je     f0103831 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103828:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010382f:	eb 33                	jmp    f0103864 <env_destroy+0x5c>
	}

	env_free(e);
f0103831:	83 ec 0c             	sub    $0xc,%esp
f0103834:	53                   	push   %ebx
f0103835:	e8 f3 fd ff ff       	call   f010362d <env_free>

	if (curenv == e) {
f010383a:	e8 1d 25 00 00       	call   f0105d5c <cpunum>
f010383f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103842:	83 c4 10             	add    $0x10,%esp
f0103845:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f010384b:	75 17                	jne    f0103864 <env_destroy+0x5c>
		curenv = NULL;
f010384d:	e8 0a 25 00 00       	call   f0105d5c <cpunum>
f0103852:	6b c0 74             	imul   $0x74,%eax,%eax
f0103855:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f010385c:	00 00 00 
		sched_yield();
f010385f:	e8 01 0d 00 00       	call   f0104565 <sched_yield>
	}
}
f0103864:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103867:	c9                   	leave  
f0103868:	c3                   	ret    

f0103869 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103869:	55                   	push   %ebp
f010386a:	89 e5                	mov    %esp,%ebp
f010386c:	53                   	push   %ebx
f010386d:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103870:	e8 e7 24 00 00       	call   f0105d5c <cpunum>
f0103875:	6b c0 74             	imul   $0x74,%eax,%eax
f0103878:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f010387e:	e8 d9 24 00 00       	call   f0105d5c <cpunum>
f0103883:	89 43 5c             	mov    %eax,0x5c(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103886:	83 ec 0c             	sub    $0xc,%esp
f0103889:	68 80 14 12 f0       	push   $0xf0121480
f010388e:	e8 d4 27 00 00       	call   f0106067 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103893:	f3 90                	pause  
	unlock_kernel();
	__asm __volatile("movl %0,%%esp\n"
f0103895:	8b 65 08             	mov    0x8(%ebp),%esp
f0103898:	61                   	popa   
f0103899:	07                   	pop    %es
f010389a:	1f                   	pop    %ds
f010389b:	83 c4 08             	add    $0x8,%esp
f010389e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010389f:	83 c4 0c             	add    $0xc,%esp
f01038a2:	68 ac 79 10 f0       	push   $0xf01079ac
f01038a7:	68 f2 01 00 00       	push   $0x1f2
f01038ac:	68 66 79 10 f0       	push   $0xf0107966
f01038b1:	e8 de c7 ff ff       	call   f0100094 <_panic>

f01038b6 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01038b6:	55                   	push   %ebp
f01038b7:	89 e5                	mov    %esp,%ebp
f01038b9:	53                   	push   %ebx
f01038ba:	83 ec 04             	sub    $0x4,%esp
f01038bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("curenv: %x, e: %x\n", curenv, e);
	// cprintf("\n");
	if (curenv != e) {
f01038c0:	e8 97 24 00 00       	call   f0105d5c <cpunum>
f01038c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c8:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f01038ce:	74 7a                	je     f010394a <env_run+0x94>
		if (curenv && curenv->env_status == ENV_RUNNING)
f01038d0:	e8 87 24 00 00       	call   f0105d5c <cpunum>
f01038d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d8:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01038df:	74 29                	je     f010390a <env_run+0x54>
f01038e1:	e8 76 24 00 00       	call   f0105d5c <cpunum>
f01038e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e9:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01038ef:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01038f3:	75 15                	jne    f010390a <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f01038f5:	e8 62 24 00 00       	call   f0105d5c <cpunum>
f01038fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01038fd:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103903:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f010390a:	e8 4d 24 00 00       	call   f0105d5c <cpunum>
f010390f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103912:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
		e->env_status = ENV_RUNNING;
f0103918:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f010391f:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f0103923:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103926:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010392b:	77 15                	ja     f0103942 <env_run+0x8c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010392d:	50                   	push   %eax
f010392e:	68 88 65 10 f0       	push   $0xf0106588
f0103933:	68 18 02 00 00       	push   $0x218
f0103938:	68 66 79 10 f0       	push   $0xf0107966
f010393d:	e8 52 c7 ff ff       	call   f0100094 <_panic>
f0103942:	05 00 00 00 10       	add    $0x10000000,%eax
f0103947:	0f 22 d8             	mov    %eax,%cr3
	}
	
	env_pop_tf(&e->env_tf);
f010394a:	83 ec 0c             	sub    $0xc,%esp
f010394d:	53                   	push   %ebx
f010394e:	e8 16 ff ff ff       	call   f0103869 <env_pop_tf>

f0103953 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103953:	55                   	push   %ebp
f0103954:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103956:	ba 70 00 00 00       	mov    $0x70,%edx
f010395b:	8b 45 08             	mov    0x8(%ebp),%eax
f010395e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010395f:	ba 71 00 00 00       	mov    $0x71,%edx
f0103964:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103965:	0f b6 c0             	movzbl %al,%eax
}
f0103968:	5d                   	pop    %ebp
f0103969:	c3                   	ret    

f010396a <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010396a:	55                   	push   %ebp
f010396b:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010396d:	ba 70 00 00 00       	mov    $0x70,%edx
f0103972:	8b 45 08             	mov    0x8(%ebp),%eax
f0103975:	ee                   	out    %al,(%dx)
f0103976:	ba 71 00 00 00       	mov    $0x71,%edx
f010397b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010397e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010397f:	5d                   	pop    %ebp
f0103980:	c3                   	ret    

f0103981 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103981:	55                   	push   %ebp
f0103982:	89 e5                	mov    %esp,%ebp
f0103984:	56                   	push   %esi
f0103985:	53                   	push   %ebx
f0103986:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103989:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f010398f:	80 3d 50 b2 22 f0 00 	cmpb   $0x0,0xf022b250
f0103996:	74 5a                	je     f01039f2 <irq_setmask_8259A+0x71>
f0103998:	89 c6                	mov    %eax,%esi
f010399a:	ba 21 00 00 00       	mov    $0x21,%edx
f010399f:	ee                   	out    %al,(%dx)
f01039a0:	66 c1 e8 08          	shr    $0x8,%ax
f01039a4:	ba a1 00 00 00       	mov    $0xa1,%edx
f01039a9:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01039aa:	83 ec 0c             	sub    $0xc,%esp
f01039ad:	68 b8 79 10 f0       	push   $0xf01079b8
f01039b2:	e8 1b 01 00 00       	call   f0103ad2 <cprintf>
f01039b7:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01039ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01039bf:	0f b7 f6             	movzwl %si,%esi
f01039c2:	f7 d6                	not    %esi
f01039c4:	0f a3 de             	bt     %ebx,%esi
f01039c7:	73 11                	jae    f01039da <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f01039c9:	83 ec 08             	sub    $0x8,%esp
f01039cc:	53                   	push   %ebx
f01039cd:	68 9b 7e 10 f0       	push   $0xf0107e9b
f01039d2:	e8 fb 00 00 00       	call   f0103ad2 <cprintf>
f01039d7:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01039da:	83 c3 01             	add    $0x1,%ebx
f01039dd:	83 fb 10             	cmp    $0x10,%ebx
f01039e0:	75 e2                	jne    f01039c4 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01039e2:	83 ec 0c             	sub    $0xc,%esp
f01039e5:	68 a2 64 10 f0       	push   $0xf01064a2
f01039ea:	e8 e3 00 00 00       	call   f0103ad2 <cprintf>
f01039ef:	83 c4 10             	add    $0x10,%esp
}
f01039f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01039f5:	5b                   	pop    %ebx
f01039f6:	5e                   	pop    %esi
f01039f7:	5d                   	pop    %ebp
f01039f8:	c3                   	ret    

f01039f9 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01039f9:	c6 05 50 b2 22 f0 01 	movb   $0x1,0xf022b250
f0103a00:	ba 21 00 00 00       	mov    $0x21,%edx
f0103a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a0a:	ee                   	out    %al,(%dx)
f0103a0b:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103a10:	ee                   	out    %al,(%dx)
f0103a11:	ba 20 00 00 00       	mov    $0x20,%edx
f0103a16:	b8 11 00 00 00       	mov    $0x11,%eax
f0103a1b:	ee                   	out    %al,(%dx)
f0103a1c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103a21:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a26:	ee                   	out    %al,(%dx)
f0103a27:	b8 04 00 00 00       	mov    $0x4,%eax
f0103a2c:	ee                   	out    %al,(%dx)
f0103a2d:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a32:	ee                   	out    %al,(%dx)
f0103a33:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103a38:	b8 11 00 00 00       	mov    $0x11,%eax
f0103a3d:	ee                   	out    %al,(%dx)
f0103a3e:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103a43:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a48:	ee                   	out    %al,(%dx)
f0103a49:	b8 02 00 00 00       	mov    $0x2,%eax
f0103a4e:	ee                   	out    %al,(%dx)
f0103a4f:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a54:	ee                   	out    %al,(%dx)
f0103a55:	ba 20 00 00 00       	mov    $0x20,%edx
f0103a5a:	b8 68 00 00 00       	mov    $0x68,%eax
f0103a5f:	ee                   	out    %al,(%dx)
f0103a60:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103a65:	ee                   	out    %al,(%dx)
f0103a66:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103a6b:	b8 68 00 00 00       	mov    $0x68,%eax
f0103a70:	ee                   	out    %al,(%dx)
f0103a71:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103a76:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103a77:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103a7e:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103a82:	74 13                	je     f0103a97 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103a84:	55                   	push   %ebp
f0103a85:	89 e5                	mov    %esp,%ebp
f0103a87:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103a8a:	0f b7 c0             	movzwl %ax,%eax
f0103a8d:	50                   	push   %eax
f0103a8e:	e8 ee fe ff ff       	call   f0103981 <irq_setmask_8259A>
f0103a93:	83 c4 10             	add    $0x10,%esp
}
f0103a96:	c9                   	leave  
f0103a97:	f3 c3                	repz ret 

f0103a99 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a99:	55                   	push   %ebp
f0103a9a:	89 e5                	mov    %esp,%ebp
f0103a9c:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103a9f:	ff 75 08             	pushl  0x8(%ebp)
f0103aa2:	e8 f4 cd ff ff       	call   f010089b <cputchar>
	*cnt++;
}
f0103aa7:	83 c4 10             	add    $0x10,%esp
f0103aaa:	c9                   	leave  
f0103aab:	c3                   	ret    

f0103aac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103aac:	55                   	push   %ebp
f0103aad:	89 e5                	mov    %esp,%ebp
f0103aaf:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103ab2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103ab9:	ff 75 0c             	pushl  0xc(%ebp)
f0103abc:	ff 75 08             	pushl  0x8(%ebp)
f0103abf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103ac2:	50                   	push   %eax
f0103ac3:	68 99 3a 10 f0       	push   $0xf0103a99
f0103ac8:	e8 be 15 00 00       	call   f010508b <vprintfmt>
	return cnt;
}
f0103acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ad0:	c9                   	leave  
f0103ad1:	c3                   	ret    

f0103ad2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103ad2:	55                   	push   %ebp
f0103ad3:	89 e5                	mov    %esp,%ebp
f0103ad5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103ad8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103adb:	50                   	push   %eax
f0103adc:	ff 75 08             	pushl  0x8(%ebp)
f0103adf:	e8 c8 ff ff ff       	call   f0103aac <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ae4:	c9                   	leave  
f0103ae5:	c3                   	ret    

f0103ae6 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103ae6:	55                   	push   %ebp
f0103ae7:	89 e5                	mov    %esp,%ebp
f0103ae9:	57                   	push   %edi
f0103aea:	56                   	push   %esi
f0103aeb:	53                   	push   %ebx
f0103aec:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f0103aef:	e8 68 22 00 00       	call   f0105d5c <cpunum>
f0103af4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103af7:	0f b6 98 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f0103afe:	e8 59 22 00 00       	call   f0105d5c <cpunum>
f0103b03:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b06:	89 d9                	mov    %ebx,%ecx
f0103b08:	c1 e1 10             	shl    $0x10,%ecx
f0103b0b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103b10:	29 ca                	sub    %ecx,%edx
f0103b12:	89 90 30 c0 22 f0    	mov    %edx,-0xfdd3fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103b18:	e8 3f 22 00 00       	call   f0105d5c <cpunum>
f0103b1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b20:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f0103b27:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103b29:	83 c3 05             	add    $0x5,%ebx
f0103b2c:	e8 2b 22 00 00       	call   f0105d5c <cpunum>
f0103b31:	89 c7                	mov    %eax,%edi
f0103b33:	e8 24 22 00 00       	call   f0105d5c <cpunum>
f0103b38:	89 c6                	mov    %eax,%esi
f0103b3a:	e8 1d 22 00 00       	call   f0105d5c <cpunum>
f0103b3f:	66 c7 04 dd 40 13 12 	movw   $0x68,-0xfedecc0(,%ebx,8)
f0103b46:	f0 68 00 
f0103b49:	6b ff 74             	imul   $0x74,%edi,%edi
f0103b4c:	81 c7 2c c0 22 f0    	add    $0xf022c02c,%edi
f0103b52:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0103b59:	f0 
f0103b5a:	6b d6 74             	imul   $0x74,%esi,%edx
f0103b5d:	81 c2 2c c0 22 f0    	add    $0xf022c02c,%edx
f0103b63:	c1 ea 10             	shr    $0x10,%edx
f0103b66:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0103b6d:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0103b74:	40 
f0103b75:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b78:	05 2c c0 22 f0       	add    $0xf022c02c,%eax
f0103b7d:	c1 e8 18             	shr    $0x18,%eax
f0103b80:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3)+cid].sd_s = 0;
f0103b87:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0103b8e:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103b8f:	c1 e3 03             	shl    $0x3,%ebx
f0103b92:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103b95:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103b9a:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+8*cid);

	// Load the IDT
	lidt(&idt_pd);
}
f0103b9d:	83 c4 0c             	add    $0xc,%esp
f0103ba0:	5b                   	pop    %ebx
f0103ba1:	5e                   	pop    %esi
f0103ba2:	5f                   	pop    %edi
f0103ba3:	5d                   	pop    %ebp
f0103ba4:	c3                   	ret    

f0103ba5 <trap_init>:



void
trap_init(void)
{
f0103ba5:	55                   	push   %ebp
f0103ba6:	89 e5                	mov    %esp,%ebp
f0103ba8:	57                   	push   %edi
f0103ba9:	56                   	push   %esi
f0103baa:	53                   	push   %ebx
f0103bab:	83 ec 1c             	sub    $0x1c,%esp
	extern void (*funs[])();
	// cprintf("funs %x\n", funs);
	// cprintf("funs[0] %x\n", funs[0]);
	// cprintf("funs[47] %x\n", funs[47]);
	int i;
	for (i = 0; i <= 16; ++i)
f0103bae:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bb3:	e9 bb 00 00 00       	jmp    f0103c73 <trap_init+0xce>
		if (i==T_BRKPT)
f0103bb8:	83 f8 03             	cmp    $0x3,%eax
f0103bbb:	75 35                	jne    f0103bf2 <trap_init+0x4d>
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
f0103bbd:	8b 35 c0 13 12 f0    	mov    0xf01213c0,%esi
f0103bc3:	89 f7                	mov    %esi,%edi
f0103bc5:	bb 01 00 00 00       	mov    $0x1,%ebx
f0103bca:	66 c7 45 e6 08 00    	movw   $0x8,-0x1a(%ebp)
f0103bd0:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
f0103bd4:	c6 45 e4 00          	movb   $0x0,-0x1c(%ebp)
f0103bd8:	c6 45 e3 0e          	movb   $0xe,-0x1d(%ebp)
f0103bdc:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103be1:	ba 03 00 00 00       	mov    $0x3,%edx
f0103be6:	c6 45 e2 01          	movb   $0x1,-0x1e(%ebp)
f0103bea:	c1 ee 10             	shr    $0x10,%esi
f0103bed:	e9 17 01 00 00       	jmp    f0103d09 <trap_init+0x164>
f0103bf2:	84 db                	test   %bl,%bl
f0103bf4:	74 14                	je     f0103c0a <trap_init+0x65>
f0103bf6:	66 89 3d 78 b2 22 f0 	mov    %di,0xf022b278
f0103bfd:	0f b7 7d e6          	movzwl -0x1a(%ebp),%edi
f0103c01:	66 89 3d 7a b2 22 f0 	mov    %di,0xf022b27a
f0103c08:	eb 04                	jmp    f0103c0e <trap_init+0x69>
f0103c0a:	84 db                	test   %bl,%bl
f0103c0c:	74 12                	je     f0103c20 <trap_init+0x7b>
f0103c0e:	0f b6 5d e4          	movzbl -0x1c(%ebp),%ebx
f0103c12:	c1 e3 05             	shl    $0x5,%ebx
f0103c15:	0a 5d e5             	or     -0x1b(%ebp),%bl
f0103c18:	88 1d 7c b2 22 f0    	mov    %bl,0xf022b27c
f0103c1e:	eb 04                	jmp    f0103c24 <trap_init+0x7f>
f0103c20:	84 db                	test   %bl,%bl
f0103c22:	74 1d                	je     f0103c41 <trap_init+0x9c>
f0103c24:	0f b6 1d 7d b2 22 f0 	movzbl 0xf022b27d,%ebx
f0103c2b:	83 e3 e0             	and    $0xffffffe0,%ebx
f0103c2e:	83 e1 01             	and    $0x1,%ecx
f0103c31:	c1 e1 04             	shl    $0x4,%ecx
f0103c34:	0a 5d e3             	or     -0x1d(%ebp),%bl
f0103c37:	09 d9                	or     %ebx,%ecx
f0103c39:	88 0d 7d b2 22 f0    	mov    %cl,0xf022b27d
f0103c3f:	eb 04                	jmp    f0103c45 <trap_init+0xa0>
f0103c41:	84 db                	test   %bl,%bl
f0103c43:	74 23                	je     f0103c68 <trap_init+0xc3>
f0103c45:	83 e2 03             	and    $0x3,%edx
f0103c48:	c1 e2 05             	shl    $0x5,%edx
f0103c4b:	0f b6 1d 7d b2 22 f0 	movzbl 0xf022b27d,%ebx
f0103c52:	83 e3 1f             	and    $0x1f,%ebx
f0103c55:	0f b6 4d e2          	movzbl -0x1e(%ebp),%ecx
f0103c59:	c1 e1 07             	shl    $0x7,%ecx
f0103c5c:	09 da                	or     %ebx,%edx
f0103c5e:	09 ca                	or     %ecx,%edx
f0103c60:	88 15 7d b2 22 f0    	mov    %dl,0xf022b27d
f0103c66:	eb 04                	jmp    f0103c6c <trap_init+0xc7>
f0103c68:	84 db                	test   %bl,%bl
f0103c6a:	74 07                	je     f0103c73 <trap_init+0xce>
f0103c6c:	66 89 35 7e b2 22 f0 	mov    %si,0xf022b27e
		else if (i!=2 && i!=15) {
f0103c73:	83 f8 02             	cmp    $0x2,%eax
f0103c76:	74 39                	je     f0103cb1 <trap_init+0x10c>
f0103c78:	83 f8 0f             	cmp    $0xf,%eax
f0103c7b:	74 34                	je     f0103cb1 <trap_init+0x10c>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f0103c7d:	8b 14 85 b4 13 12 f0 	mov    -0xfedec4c(,%eax,4),%edx
f0103c84:	66 89 14 c5 60 b2 22 	mov    %dx,-0xfdd4da0(,%eax,8)
f0103c8b:	f0 
f0103c8c:	66 c7 04 c5 62 b2 22 	movw   $0x8,-0xfdd4d9e(,%eax,8)
f0103c93:	f0 08 00 
f0103c96:	c6 04 c5 64 b2 22 f0 	movb   $0x0,-0xfdd4d9c(,%eax,8)
f0103c9d:	00 
f0103c9e:	c6 04 c5 65 b2 22 f0 	movb   $0x8e,-0xfdd4d9b(,%eax,8)
f0103ca5:	8e 
f0103ca6:	c1 ea 10             	shr    $0x10,%edx
f0103ca9:	66 89 14 c5 66 b2 22 	mov    %dx,-0xfdd4d9a(,%eax,8)
f0103cb0:	f0 
f0103cb1:	0f b7 3d 78 b2 22 f0 	movzwl 0xf022b278,%edi
f0103cb8:	0f b7 35 7a b2 22 f0 	movzwl 0xf022b27a,%esi
f0103cbf:	66 89 75 e6          	mov    %si,-0x1a(%ebp)
f0103cc3:	0f b6 15 7c b2 22 f0 	movzbl 0xf022b27c,%edx
f0103cca:	89 d1                	mov    %edx,%ecx
f0103ccc:	83 e1 1f             	and    $0x1f,%ecx
f0103ccf:	88 4d e5             	mov    %cl,-0x1b(%ebp)
f0103cd2:	c0 ea 05             	shr    $0x5,%dl
f0103cd5:	88 55 e4             	mov    %dl,-0x1c(%ebp)
f0103cd8:	0f b6 1d 7d b2 22 f0 	movzbl 0xf022b27d,%ebx
f0103cdf:	89 d9                	mov    %ebx,%ecx
f0103ce1:	83 e1 0f             	and    $0xf,%ecx
f0103ce4:	88 4d e3             	mov    %cl,-0x1d(%ebp)
f0103ce7:	89 d9                	mov    %ebx,%ecx
f0103ce9:	c0 e9 04             	shr    $0x4,%cl
f0103cec:	83 e1 01             	and    $0x1,%ecx
f0103cef:	89 da                	mov    %ebx,%edx
f0103cf1:	c0 ea 05             	shr    $0x5,%dl
f0103cf4:	83 e2 03             	and    $0x3,%edx
f0103cf7:	c0 eb 07             	shr    $0x7,%bl
f0103cfa:	88 5d e2             	mov    %bl,-0x1e(%ebp)
f0103cfd:	0f b7 35 7e b2 22 f0 	movzwl 0xf022b27e,%esi
	extern void (*funs[])();
	// cprintf("funs %x\n", funs);
	// cprintf("funs[0] %x\n", funs[0]);
	// cprintf("funs[47] %x\n", funs[47]);
	int i;
	for (i = 0; i <= 16; ++i)
f0103d04:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103d09:	83 c0 01             	add    $0x1,%eax
f0103d0c:	83 f8 10             	cmp    $0x10,%eax
f0103d0f:	0f 8e a3 fe ff ff    	jle    f0103bb8 <trap_init+0x13>
f0103d15:	84 db                	test   %bl,%bl
f0103d17:	74 13                	je     f0103d2c <trap_init+0x187>
f0103d19:	66 89 3d 78 b2 22 f0 	mov    %di,0xf022b278
f0103d20:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
f0103d24:	66 a3 7a b2 22 f0    	mov    %ax,0xf022b27a
f0103d2a:	eb 04                	jmp    f0103d30 <trap_init+0x18b>
f0103d2c:	84 db                	test   %bl,%bl
f0103d2e:	74 11                	je     f0103d41 <trap_init+0x19c>
f0103d30:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0103d34:	c1 e0 05             	shl    $0x5,%eax
f0103d37:	0a 45 e5             	or     -0x1b(%ebp),%al
f0103d3a:	a2 7c b2 22 f0       	mov    %al,0xf022b27c
f0103d3f:	eb 04                	jmp    f0103d45 <trap_init+0x1a0>
f0103d41:	84 db                	test   %bl,%bl
f0103d43:	74 1c                	je     f0103d61 <trap_init+0x1bc>
f0103d45:	0f b6 05 7d b2 22 f0 	movzbl 0xf022b27d,%eax
f0103d4c:	83 e0 e0             	and    $0xffffffe0,%eax
f0103d4f:	83 e1 01             	and    $0x1,%ecx
f0103d52:	c1 e1 04             	shl    $0x4,%ecx
f0103d55:	0a 45 e3             	or     -0x1d(%ebp),%al
f0103d58:	09 c8                	or     %ecx,%eax
f0103d5a:	a2 7d b2 22 f0       	mov    %al,0xf022b27d
f0103d5f:	eb 04                	jmp    f0103d65 <trap_init+0x1c0>
f0103d61:	84 db                	test   %bl,%bl
f0103d63:	74 24                	je     f0103d89 <trap_init+0x1e4>
f0103d65:	89 d0                	mov    %edx,%eax
f0103d67:	83 e0 03             	and    $0x3,%eax
f0103d6a:	c1 e0 05             	shl    $0x5,%eax
f0103d6d:	0f b6 0d 7d b2 22 f0 	movzbl 0xf022b27d,%ecx
f0103d74:	83 e1 1f             	and    $0x1f,%ecx
f0103d77:	0f b6 55 e2          	movzbl -0x1e(%ebp),%edx
f0103d7b:	c1 e2 07             	shl    $0x7,%edx
f0103d7e:	09 c8                	or     %ecx,%eax
f0103d80:	09 d0                	or     %edx,%eax
f0103d82:	a2 7d b2 22 f0       	mov    %al,0xf022b27d
f0103d87:	eb 04                	jmp    f0103d8d <trap_init+0x1e8>
f0103d89:	84 db                	test   %bl,%bl
f0103d8b:	74 07                	je     f0103d94 <trap_init+0x1ef>
f0103d8d:	66 89 35 7e b2 22 f0 	mov    %si,0xf022b27e
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
f0103d94:	a1 74 14 12 f0       	mov    0xf0121474,%eax
f0103d99:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f0103d9f:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f0103da6:	08 00 
f0103da8:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f0103daf:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f0103db6:	c1 e8 10             	shr    $0x10,%eax
f0103db9:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6
f0103dbf:	b8 20 00 00 00       	mov    $0x20,%eax

	for (i = 0; i < 16; ++i)
		SETGATE(idt[IRQ_OFFSET+i], 0, GD_KT, funs[IRQ_OFFSET+i], 0);
f0103dc4:	8b 14 85 b4 13 12 f0 	mov    -0xfedec4c(,%eax,4),%edx
f0103dcb:	66 89 14 c5 60 b2 22 	mov    %dx,-0xfdd4da0(,%eax,8)
f0103dd2:	f0 
f0103dd3:	66 c7 04 c5 62 b2 22 	movw   $0x8,-0xfdd4d9e(,%eax,8)
f0103dda:	f0 08 00 
f0103ddd:	c6 04 c5 64 b2 22 f0 	movb   $0x0,-0xfdd4d9c(,%eax,8)
f0103de4:	00 
f0103de5:	c6 04 c5 65 b2 22 f0 	movb   $0x8e,-0xfdd4d9b(,%eax,8)
f0103dec:	8e 
f0103ded:	c1 ea 10             	shr    $0x10,%edx
f0103df0:	66 89 14 c5 66 b2 22 	mov    %dx,-0xfdd4d9a(,%eax,8)
f0103df7:	f0 
f0103df8:	83 c0 01             	add    $0x1,%eax
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);

	for (i = 0; i < 16; ++i)
f0103dfb:	83 f8 30             	cmp    $0x30,%eax
f0103dfe:	75 c4                	jne    f0103dc4 <trap_init+0x21f>
		SETGATE(idt[IRQ_OFFSET+i], 0, GD_KT, funs[IRQ_OFFSET+i], 0);

	// Per-CPU setup 
	trap_init_percpu();
f0103e00:	e8 e1 fc ff ff       	call   f0103ae6 <trap_init_percpu>
}
f0103e05:	83 c4 1c             	add    $0x1c,%esp
f0103e08:	5b                   	pop    %ebx
f0103e09:	5e                   	pop    %esi
f0103e0a:	5f                   	pop    %edi
f0103e0b:	5d                   	pop    %ebp
f0103e0c:	c3                   	ret    

f0103e0d <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e0d:	55                   	push   %ebp
f0103e0e:	89 e5                	mov    %esp,%ebp
f0103e10:	53                   	push   %ebx
f0103e11:	83 ec 0c             	sub    $0xc,%esp
f0103e14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e17:	ff 33                	pushl  (%ebx)
f0103e19:	68 cc 79 10 f0       	push   $0xf01079cc
f0103e1e:	e8 af fc ff ff       	call   f0103ad2 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e23:	83 c4 08             	add    $0x8,%esp
f0103e26:	ff 73 04             	pushl  0x4(%ebx)
f0103e29:	68 db 79 10 f0       	push   $0xf01079db
f0103e2e:	e8 9f fc ff ff       	call   f0103ad2 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e33:	83 c4 08             	add    $0x8,%esp
f0103e36:	ff 73 08             	pushl  0x8(%ebx)
f0103e39:	68 ea 79 10 f0       	push   $0xf01079ea
f0103e3e:	e8 8f fc ff ff       	call   f0103ad2 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e43:	83 c4 08             	add    $0x8,%esp
f0103e46:	ff 73 0c             	pushl  0xc(%ebx)
f0103e49:	68 f9 79 10 f0       	push   $0xf01079f9
f0103e4e:	e8 7f fc ff ff       	call   f0103ad2 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e53:	83 c4 08             	add    $0x8,%esp
f0103e56:	ff 73 10             	pushl  0x10(%ebx)
f0103e59:	68 08 7a 10 f0       	push   $0xf0107a08
f0103e5e:	e8 6f fc ff ff       	call   f0103ad2 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e63:	83 c4 08             	add    $0x8,%esp
f0103e66:	ff 73 14             	pushl  0x14(%ebx)
f0103e69:	68 17 7a 10 f0       	push   $0xf0107a17
f0103e6e:	e8 5f fc ff ff       	call   f0103ad2 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e73:	83 c4 08             	add    $0x8,%esp
f0103e76:	ff 73 18             	pushl  0x18(%ebx)
f0103e79:	68 26 7a 10 f0       	push   $0xf0107a26
f0103e7e:	e8 4f fc ff ff       	call   f0103ad2 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e83:	83 c4 08             	add    $0x8,%esp
f0103e86:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e89:	68 35 7a 10 f0       	push   $0xf0107a35
f0103e8e:	e8 3f fc ff ff       	call   f0103ad2 <cprintf>
}
f0103e93:	83 c4 10             	add    $0x10,%esp
f0103e96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e99:	c9                   	leave  
f0103e9a:	c3                   	ret    

f0103e9b <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e9b:	55                   	push   %ebp
f0103e9c:	89 e5                	mov    %esp,%ebp
f0103e9e:	56                   	push   %esi
f0103e9f:	53                   	push   %ebx
f0103ea0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103ea3:	e8 b4 1e 00 00       	call   f0105d5c <cpunum>
f0103ea8:	83 ec 04             	sub    $0x4,%esp
f0103eab:	50                   	push   %eax
f0103eac:	53                   	push   %ebx
f0103ead:	68 99 7a 10 f0       	push   $0xf0107a99
f0103eb2:	e8 1b fc ff ff       	call   f0103ad2 <cprintf>
	print_regs(&tf->tf_regs);
f0103eb7:	89 1c 24             	mov    %ebx,(%esp)
f0103eba:	e8 4e ff ff ff       	call   f0103e0d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ebf:	83 c4 08             	add    $0x8,%esp
f0103ec2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103ec6:	50                   	push   %eax
f0103ec7:	68 b7 7a 10 f0       	push   $0xf0107ab7
f0103ecc:	e8 01 fc ff ff       	call   f0103ad2 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ed1:	83 c4 08             	add    $0x8,%esp
f0103ed4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ed8:	50                   	push   %eax
f0103ed9:	68 ca 7a 10 f0       	push   $0xf0107aca
f0103ede:	e8 ef fb ff ff       	call   f0103ad2 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ee3:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103ee6:	83 c4 10             	add    $0x10,%esp
f0103ee9:	83 f8 13             	cmp    $0x13,%eax
f0103eec:	77 09                	ja     f0103ef7 <print_trapframe+0x5c>
		return excnames[trapno];
f0103eee:	8b 14 85 60 7d 10 f0 	mov    -0xfef82a0(,%eax,4),%edx
f0103ef5:	eb 1f                	jmp    f0103f16 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103ef7:	83 f8 30             	cmp    $0x30,%eax
f0103efa:	74 15                	je     f0103f11 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103efc:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103eff:	83 fa 10             	cmp    $0x10,%edx
f0103f02:	b9 63 7a 10 f0       	mov    $0xf0107a63,%ecx
f0103f07:	ba 50 7a 10 f0       	mov    $0xf0107a50,%edx
f0103f0c:	0f 43 d1             	cmovae %ecx,%edx
f0103f0f:	eb 05                	jmp    f0103f16 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103f11:	ba 44 7a 10 f0       	mov    $0xf0107a44,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f16:	83 ec 04             	sub    $0x4,%esp
f0103f19:	52                   	push   %edx
f0103f1a:	50                   	push   %eax
f0103f1b:	68 dd 7a 10 f0       	push   $0xf0107add
f0103f20:	e8 ad fb ff ff       	call   f0103ad2 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f25:	83 c4 10             	add    $0x10,%esp
f0103f28:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f0103f2e:	75 1a                	jne    f0103f4a <print_trapframe+0xaf>
f0103f30:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f34:	75 14                	jne    f0103f4a <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103f36:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f39:	83 ec 08             	sub    $0x8,%esp
f0103f3c:	50                   	push   %eax
f0103f3d:	68 ef 7a 10 f0       	push   $0xf0107aef
f0103f42:	e8 8b fb ff ff       	call   f0103ad2 <cprintf>
f0103f47:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103f4a:	83 ec 08             	sub    $0x8,%esp
f0103f4d:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f50:	68 fe 7a 10 f0       	push   $0xf0107afe
f0103f55:	e8 78 fb ff ff       	call   f0103ad2 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f5a:	83 c4 10             	add    $0x10,%esp
f0103f5d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f61:	75 49                	jne    f0103fac <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f63:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f66:	89 c2                	mov    %eax,%edx
f0103f68:	83 e2 01             	and    $0x1,%edx
f0103f6b:	ba 7d 7a 10 f0       	mov    $0xf0107a7d,%edx
f0103f70:	b9 72 7a 10 f0       	mov    $0xf0107a72,%ecx
f0103f75:	0f 44 ca             	cmove  %edx,%ecx
f0103f78:	89 c2                	mov    %eax,%edx
f0103f7a:	83 e2 02             	and    $0x2,%edx
f0103f7d:	ba 8f 7a 10 f0       	mov    $0xf0107a8f,%edx
f0103f82:	be 89 7a 10 f0       	mov    $0xf0107a89,%esi
f0103f87:	0f 45 d6             	cmovne %esi,%edx
f0103f8a:	83 e0 04             	and    $0x4,%eax
f0103f8d:	be dc 7b 10 f0       	mov    $0xf0107bdc,%esi
f0103f92:	b8 94 7a 10 f0       	mov    $0xf0107a94,%eax
f0103f97:	0f 44 c6             	cmove  %esi,%eax
f0103f9a:	51                   	push   %ecx
f0103f9b:	52                   	push   %edx
f0103f9c:	50                   	push   %eax
f0103f9d:	68 0c 7b 10 f0       	push   $0xf0107b0c
f0103fa2:	e8 2b fb ff ff       	call   f0103ad2 <cprintf>
f0103fa7:	83 c4 10             	add    $0x10,%esp
f0103faa:	eb 10                	jmp    f0103fbc <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103fac:	83 ec 0c             	sub    $0xc,%esp
f0103faf:	68 a2 64 10 f0       	push   $0xf01064a2
f0103fb4:	e8 19 fb ff ff       	call   f0103ad2 <cprintf>
f0103fb9:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fbc:	83 ec 08             	sub    $0x8,%esp
f0103fbf:	ff 73 30             	pushl  0x30(%ebx)
f0103fc2:	68 1b 7b 10 f0       	push   $0xf0107b1b
f0103fc7:	e8 06 fb ff ff       	call   f0103ad2 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fcc:	83 c4 08             	add    $0x8,%esp
f0103fcf:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103fd3:	50                   	push   %eax
f0103fd4:	68 2a 7b 10 f0       	push   $0xf0107b2a
f0103fd9:	e8 f4 fa ff ff       	call   f0103ad2 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103fde:	83 c4 08             	add    $0x8,%esp
f0103fe1:	ff 73 38             	pushl  0x38(%ebx)
f0103fe4:	68 3d 7b 10 f0       	push   $0xf0107b3d
f0103fe9:	e8 e4 fa ff ff       	call   f0103ad2 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103fee:	83 c4 10             	add    $0x10,%esp
f0103ff1:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ff5:	74 25                	je     f010401c <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103ff7:	83 ec 08             	sub    $0x8,%esp
f0103ffa:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ffd:	68 4c 7b 10 f0       	push   $0xf0107b4c
f0104002:	e8 cb fa ff ff       	call   f0103ad2 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104007:	83 c4 08             	add    $0x8,%esp
f010400a:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010400e:	50                   	push   %eax
f010400f:	68 5b 7b 10 f0       	push   $0xf0107b5b
f0104014:	e8 b9 fa ff ff       	call   f0103ad2 <cprintf>
f0104019:	83 c4 10             	add    $0x10,%esp
	}
}
f010401c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010401f:	5b                   	pop    %ebx
f0104020:	5e                   	pop    %esi
f0104021:	5d                   	pop    %ebp
f0104022:	c3                   	ret    

f0104023 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104023:	55                   	push   %ebp
f0104024:	89 e5                	mov    %esp,%ebp
f0104026:	57                   	push   %edi
f0104027:	56                   	push   %esi
f0104028:	53                   	push   %ebx
f0104029:	83 ec 0c             	sub    $0xc,%esp
f010402c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010402f:	0f 20 d6             	mov    %cr2,%esi
	// cprintf("fault_va: %x\n", fault_va);

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs&3) == 0) {
f0104032:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104036:	75 20                	jne    f0104058 <page_fault_handler+0x35>
		print_trapframe(tf);
f0104038:	83 ec 0c             	sub    $0xc,%esp
f010403b:	53                   	push   %ebx
f010403c:	e8 5a fe ff ff       	call   f0103e9b <print_trapframe>
		panic("Kernel page fault!");
f0104041:	83 c4 0c             	add    $0xc,%esp
f0104044:	68 6e 7b 10 f0       	push   $0xf0107b6e
f0104049:	68 5e 01 00 00       	push   $0x15e
f010404e:	68 81 7b 10 f0       	push   $0xf0107b81
f0104053:	e8 3c c0 ff ff       	call   f0100094 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0104058:	e8 ff 1c 00 00       	call   f0105d5c <cpunum>
f010405d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104060:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104066:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010406a:	0f 84 a7 00 00 00    	je     f0104117 <page_fault_handler+0xf4>
		struct UTrapframe *utf;
		uintptr_t utf_addr;
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0104070:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104073:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0104079:	83 e8 38             	sub    $0x38,%eax
f010407c:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104082:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104087:	0f 46 d0             	cmovbe %eax,%edx
f010408a:	89 d7                	mov    %edx,%edi
		else 
			utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void*)utf_addr, sizeof(struct UTrapframe), PTE_W);//1 is enough
f010408c:	e8 cb 1c 00 00       	call   f0105d5c <cpunum>
f0104091:	6a 02                	push   $0x2
f0104093:	6a 34                	push   $0x34
f0104095:	57                   	push   %edi
f0104096:	6b c0 74             	imul   $0x74,%eax,%eax
f0104099:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f010409f:	e8 3b f1 ff ff       	call   f01031df <user_mem_assert>
		utf = (struct UTrapframe *) utf_addr;

		utf->utf_fault_va = fault_va;
f01040a4:	89 fa                	mov    %edi,%edx
f01040a6:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f01040a8:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01040ab:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f01040ae:	8d 7f 08             	lea    0x8(%edi),%edi
f01040b1:	b9 08 00 00 00       	mov    $0x8,%ecx
f01040b6:	89 de                	mov    %ebx,%esi
f01040b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01040ba:	8b 43 30             	mov    0x30(%ebx),%eax
f01040bd:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01040c0:	8b 43 38             	mov    0x38(%ebx),%eax
f01040c3:	89 d7                	mov    %edx,%edi
f01040c5:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01040c8:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040cb:	89 42 30             	mov    %eax,0x30(%edx)

//		curenv->env_tf.env_tf
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01040ce:	e8 89 1c 00 00       	call   f0105d5c <cpunum>
f01040d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d6:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f01040dc:	e8 7b 1c 00 00       	call   f0105d5c <cpunum>
f01040e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e4:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01040ea:	8b 40 64             	mov    0x64(%eax),%eax
f01040ed:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = utf_addr;
f01040f0:	e8 67 1c 00 00       	call   f0105d5c <cpunum>
f01040f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01040f8:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01040fe:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f0104101:	e8 56 1c 00 00       	call   f0105d5c <cpunum>
f0104106:	83 c4 04             	add    $0x4,%esp
f0104109:	6b c0 74             	imul   $0x74,%eax,%eax
f010410c:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104112:	e8 9f f7 ff ff       	call   f01038b6 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104117:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010411a:	e8 3d 1c 00 00       	call   f0105d5c <cpunum>
		curenv->env_tf.tf_esp = utf_addr;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010411f:	57                   	push   %edi
f0104120:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104121:	6b c0 74             	imul   $0x74,%eax,%eax
		curenv->env_tf.tf_esp = utf_addr;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104124:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010412a:	ff 70 48             	pushl  0x48(%eax)
f010412d:	68 28 7d 10 f0       	push   $0xf0107d28
f0104132:	e8 9b f9 ff ff       	call   f0103ad2 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104137:	89 1c 24             	mov    %ebx,(%esp)
f010413a:	e8 5c fd ff ff       	call   f0103e9b <print_trapframe>
	env_destroy(curenv);
f010413f:	e8 18 1c 00 00       	call   f0105d5c <cpunum>
f0104144:	83 c4 04             	add    $0x4,%esp
f0104147:	6b c0 74             	imul   $0x74,%eax,%eax
f010414a:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104150:	e8 b3 f6 ff ff       	call   f0103808 <env_destroy>
}
f0104155:	83 c4 10             	add    $0x10,%esp
f0104158:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010415b:	5b                   	pop    %ebx
f010415c:	5e                   	pop    %esi
f010415d:	5f                   	pop    %edi
f010415e:	5d                   	pop    %ebp
f010415f:	c3                   	ret    

f0104160 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104160:	55                   	push   %ebp
f0104161:	89 e5                	mov    %esp,%ebp
f0104163:	57                   	push   %edi
f0104164:	56                   	push   %esi
f0104165:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104168:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104169:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0104170:	74 01                	je     f0104173 <trap+0x13>
		asm volatile("hlt");
f0104172:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104173:	e8 e4 1b 00 00       	call   f0105d5c <cpunum>
f0104178:	6b d0 74             	imul   $0x74,%eax,%edx
f010417b:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104181:	b8 01 00 00 00       	mov    $0x1,%eax
f0104186:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010418a:	83 f8 02             	cmp    $0x2,%eax
f010418d:	75 10                	jne    f010419f <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010418f:	83 ec 0c             	sub    $0xc,%esp
f0104192:	68 80 14 12 f0       	push   $0xf0121480
f0104197:	e8 2e 1e 00 00       	call   f0105fca <spin_lock>
f010419c:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010419f:	9c                   	pushf  
f01041a0:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01041a1:	f6 c4 02             	test   $0x2,%ah
f01041a4:	74 19                	je     f01041bf <trap+0x5f>
f01041a6:	68 8d 7b 10 f0       	push   $0xf0107b8d
f01041ab:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01041b0:	68 25 01 00 00       	push   $0x125
f01041b5:	68 81 7b 10 f0       	push   $0xf0107b81
f01041ba:	e8 d5 be ff ff       	call   f0100094 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01041bf:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041c3:	83 e0 03             	and    $0x3,%eax
f01041c6:	66 83 f8 03          	cmp    $0x3,%ax
f01041ca:	0f 85 a0 00 00 00    	jne    f0104270 <trap+0x110>
f01041d0:	83 ec 0c             	sub    $0xc,%esp
f01041d3:	68 80 14 12 f0       	push   $0xf0121480
f01041d8:	e8 ed 1d 00 00       	call   f0105fca <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);
f01041dd:	e8 7a 1b 00 00       	call   f0105d5c <cpunum>
f01041e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e5:	83 c4 10             	add    $0x10,%esp
f01041e8:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01041ef:	75 19                	jne    f010420a <trap+0xaa>
f01041f1:	68 a6 7b 10 f0       	push   $0xf0107ba6
f01041f6:	68 7e 6c 10 f0       	push   $0xf0106c7e
f01041fb:	68 2e 01 00 00       	push   $0x12e
f0104200:	68 81 7b 10 f0       	push   $0xf0107b81
f0104205:	e8 8a be ff ff       	call   f0100094 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010420a:	e8 4d 1b 00 00       	call   f0105d5c <cpunum>
f010420f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104212:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104218:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010421c:	75 2d                	jne    f010424b <trap+0xeb>
			env_free(curenv);
f010421e:	e8 39 1b 00 00       	call   f0105d5c <cpunum>
f0104223:	83 ec 0c             	sub    $0xc,%esp
f0104226:	6b c0 74             	imul   $0x74,%eax,%eax
f0104229:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f010422f:	e8 f9 f3 ff ff       	call   f010362d <env_free>
			curenv = NULL;
f0104234:	e8 23 1b 00 00       	call   f0105d5c <cpunum>
f0104239:	6b c0 74             	imul   $0x74,%eax,%eax
f010423c:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104243:	00 00 00 
			sched_yield();
f0104246:	e8 1a 03 00 00       	call   f0104565 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010424b:	e8 0c 1b 00 00       	call   f0105d5c <cpunum>
f0104250:	6b c0 74             	imul   $0x74,%eax,%eax
f0104253:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104259:	b9 11 00 00 00       	mov    $0x11,%ecx
f010425e:	89 c7                	mov    %eax,%edi
f0104260:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104262:	e8 f5 1a 00 00       	call   f0105d5c <cpunum>
f0104267:	6b c0 74             	imul   $0x74,%eax,%eax
f010426a:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104270:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	if (tf->tf_trapno == T_PGFLT) {
f0104276:	8b 46 28             	mov    0x28(%esi),%eax
f0104279:	83 f8 0e             	cmp    $0xe,%eax
f010427c:	75 11                	jne    f010428f <trap+0x12f>
		// cprintf("PAGE FAULT\n");
		page_fault_handler(tf);
f010427e:	83 ec 0c             	sub    $0xc,%esp
f0104281:	56                   	push   %esi
f0104282:	e8 9c fd ff ff       	call   f0104023 <page_fault_handler>
f0104287:	83 c4 10             	add    $0x10,%esp
f010428a:	e9 ad 00 00 00       	jmp    f010433c <trap+0x1dc>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f010428f:	83 f8 03             	cmp    $0x3,%eax
f0104292:	75 11                	jne    f01042a5 <trap+0x145>
		// cprintf("BREAK POINT\n");
		monitor(tf);
f0104294:	83 ec 0c             	sub    $0xc,%esp
f0104297:	56                   	push   %esi
f0104298:	e8 23 c8 ff ff       	call   f0100ac0 <monitor>
f010429d:	83 c4 10             	add    $0x10,%esp
f01042a0:	e9 97 00 00 00       	jmp    f010433c <trap+0x1dc>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f01042a5:	83 f8 30             	cmp    $0x30,%eax
f01042a8:	75 21                	jne    f01042cb <trap+0x16b>
		// cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f01042aa:	83 ec 08             	sub    $0x8,%esp
f01042ad:	ff 76 04             	pushl  0x4(%esi)
f01042b0:	ff 36                	pushl  (%esi)
f01042b2:	ff 76 10             	pushl  0x10(%esi)
f01042b5:	ff 76 18             	pushl  0x18(%esi)
f01042b8:	ff 76 14             	pushl  0x14(%esi)
f01042bb:	ff 76 1c             	pushl  0x1c(%esi)
f01042be:	e8 8f 03 00 00       	call   f0104652 <syscall>
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		// cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
f01042c3:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042c6:	83 c4 20             	add    $0x20,%esp
f01042c9:	eb 71                	jmp    f010433c <trap+0x1dc>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01042cb:	83 f8 27             	cmp    $0x27,%eax
f01042ce:	75 1a                	jne    f01042ea <trap+0x18a>
		cprintf("Spurious interrupt on irq 7\n");
f01042d0:	83 ec 0c             	sub    $0xc,%esp
f01042d3:	68 ad 7b 10 f0       	push   $0xf0107bad
f01042d8:	e8 f5 f7 ff ff       	call   f0103ad2 <cprintf>
		print_trapframe(tf);
f01042dd:	89 34 24             	mov    %esi,(%esp)
f01042e0:	e8 b6 fb ff ff       	call   f0103e9b <print_trapframe>
f01042e5:	83 c4 10             	add    $0x10,%esp
f01042e8:	eb 52                	jmp    f010433c <trap+0x1dc>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01042ea:	83 f8 20             	cmp    $0x20,%eax
f01042ed:	75 0a                	jne    f01042f9 <trap+0x199>
		// cprintf("Timer\n");
		lapic_eoi();
f01042ef:	e8 b3 1b 00 00       	call   f0105ea7 <lapic_eoi>
		sched_yield();
f01042f4:	e8 6c 02 00 00       	call   f0104565 <sched_yield>
		return;
	}


	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01042f9:	83 ec 0c             	sub    $0xc,%esp
f01042fc:	56                   	push   %esi
f01042fd:	e8 99 fb ff ff       	call   f0103e9b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104302:	83 c4 10             	add    $0x10,%esp
f0104305:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010430a:	75 17                	jne    f0104323 <trap+0x1c3>
		panic("unhandled trap in kernel");
f010430c:	83 ec 04             	sub    $0x4,%esp
f010430f:	68 ca 7b 10 f0       	push   $0xf0107bca
f0104314:	68 0b 01 00 00       	push   $0x10b
f0104319:	68 81 7b 10 f0       	push   $0xf0107b81
f010431e:	e8 71 bd ff ff       	call   f0100094 <_panic>
	else {
		env_destroy(curenv);
f0104323:	e8 34 1a 00 00       	call   f0105d5c <cpunum>
f0104328:	83 ec 0c             	sub    $0xc,%esp
f010432b:	6b c0 74             	imul   $0x74,%eax,%eax
f010432e:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104334:	e8 cf f4 ff ff       	call   f0103808 <env_destroy>
f0104339:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010433c:	e8 1b 1a 00 00       	call   f0105d5c <cpunum>
f0104341:	6b c0 74             	imul   $0x74,%eax,%eax
f0104344:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010434b:	74 2a                	je     f0104377 <trap+0x217>
f010434d:	e8 0a 1a 00 00       	call   f0105d5c <cpunum>
f0104352:	6b c0 74             	imul   $0x74,%eax,%eax
f0104355:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010435b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010435f:	75 16                	jne    f0104377 <trap+0x217>
		env_run(curenv);
f0104361:	e8 f6 19 00 00       	call   f0105d5c <cpunum>
f0104366:	83 ec 0c             	sub    $0xc,%esp
f0104369:	6b c0 74             	imul   $0x74,%eax,%eax
f010436c:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104372:	e8 3f f5 ff ff       	call   f01038b6 <env_run>
	else
		sched_yield();
f0104377:	e8 e9 01 00 00       	call   f0104565 <sched_yield>

f010437c <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec(th0, 0)
f010437c:	6a 00                	push   $0x0
f010437e:	6a 00                	push   $0x0
f0104380:	e9 cf 00 00 00       	jmp    f0104454 <_alltraps>
f0104385:	90                   	nop

f0104386 <th1>:
	noec(th1, 1)
f0104386:	6a 00                	push   $0x0
f0104388:	6a 01                	push   $0x1
f010438a:	e9 c5 00 00 00       	jmp    f0104454 <_alltraps>
f010438f:	90                   	nop

f0104390 <th3>:
	zhanwei()
	noec(th3, 3)
f0104390:	6a 00                	push   $0x0
f0104392:	6a 03                	push   $0x3
f0104394:	e9 bb 00 00 00       	jmp    f0104454 <_alltraps>
f0104399:	90                   	nop

f010439a <th4>:
	noec(th4, 4)
f010439a:	6a 00                	push   $0x0
f010439c:	6a 04                	push   $0x4
f010439e:	e9 b1 00 00 00       	jmp    f0104454 <_alltraps>
f01043a3:	90                   	nop

f01043a4 <th5>:
	noec(th5, 5)
f01043a4:	6a 00                	push   $0x0
f01043a6:	6a 05                	push   $0x5
f01043a8:	e9 a7 00 00 00       	jmp    f0104454 <_alltraps>
f01043ad:	90                   	nop

f01043ae <th6>:
	noec(th6, 6)
f01043ae:	6a 00                	push   $0x0
f01043b0:	6a 06                	push   $0x6
f01043b2:	e9 9d 00 00 00       	jmp    f0104454 <_alltraps>
f01043b7:	90                   	nop

f01043b8 <th7>:
	noec(th7, 7)
f01043b8:	6a 00                	push   $0x0
f01043ba:	6a 07                	push   $0x7
f01043bc:	e9 93 00 00 00       	jmp    f0104454 <_alltraps>
f01043c1:	90                   	nop

f01043c2 <th8>:
	ec(th8, 8)
f01043c2:	6a 08                	push   $0x8
f01043c4:	e9 8b 00 00 00       	jmp    f0104454 <_alltraps>
f01043c9:	90                   	nop

f01043ca <th9>:
	noec(th9, 9)
f01043ca:	6a 00                	push   $0x0
f01043cc:	6a 09                	push   $0x9
f01043ce:	e9 81 00 00 00       	jmp    f0104454 <_alltraps>
f01043d3:	90                   	nop

f01043d4 <th10>:
	ec(th10, 10)
f01043d4:	6a 0a                	push   $0xa
f01043d6:	eb 7c                	jmp    f0104454 <_alltraps>

f01043d8 <th11>:
	ec(th11, 11)
f01043d8:	6a 0b                	push   $0xb
f01043da:	eb 78                	jmp    f0104454 <_alltraps>

f01043dc <th12>:
	ec(th12, 12)
f01043dc:	6a 0c                	push   $0xc
f01043de:	eb 74                	jmp    f0104454 <_alltraps>

f01043e0 <th13>:
	ec(th13, 13)
f01043e0:	6a 0d                	push   $0xd
f01043e2:	eb 70                	jmp    f0104454 <_alltraps>

f01043e4 <th14>:
	ec(th14, 14)
f01043e4:	6a 0e                	push   $0xe
f01043e6:	eb 6c                	jmp    f0104454 <_alltraps>

f01043e8 <th16>:
	zhanwei()
	noec(th16, 16)
f01043e8:	6a 00                	push   $0x0
f01043ea:	6a 10                	push   $0x10
f01043ec:	eb 66                	jmp    f0104454 <_alltraps>

f01043ee <th32>:
.data
	.space 60
.text
	noec(th32, 32)
f01043ee:	6a 00                	push   $0x0
f01043f0:	6a 20                	push   $0x20
f01043f2:	eb 60                	jmp    f0104454 <_alltraps>

f01043f4 <th33>:
	noec(th33, 33)
f01043f4:	6a 00                	push   $0x0
f01043f6:	6a 21                	push   $0x21
f01043f8:	eb 5a                	jmp    f0104454 <_alltraps>

f01043fa <th34>:
	noec(th34, 34)
f01043fa:	6a 00                	push   $0x0
f01043fc:	6a 22                	push   $0x22
f01043fe:	eb 54                	jmp    f0104454 <_alltraps>

f0104400 <th35>:
	noec(th35, 35)
f0104400:	6a 00                	push   $0x0
f0104402:	6a 23                	push   $0x23
f0104404:	eb 4e                	jmp    f0104454 <_alltraps>

f0104406 <th36>:
	noec(th36, 36)
f0104406:	6a 00                	push   $0x0
f0104408:	6a 24                	push   $0x24
f010440a:	eb 48                	jmp    f0104454 <_alltraps>

f010440c <th37>:
	noec(th37, 37)
f010440c:	6a 00                	push   $0x0
f010440e:	6a 25                	push   $0x25
f0104410:	eb 42                	jmp    f0104454 <_alltraps>

f0104412 <th38>:
	noec(th38, 38)
f0104412:	6a 00                	push   $0x0
f0104414:	6a 26                	push   $0x26
f0104416:	eb 3c                	jmp    f0104454 <_alltraps>

f0104418 <th39>:
	noec(th39, 39)
f0104418:	6a 00                	push   $0x0
f010441a:	6a 27                	push   $0x27
f010441c:	eb 36                	jmp    f0104454 <_alltraps>

f010441e <th40>:
	noec(th40, 40)
f010441e:	6a 00                	push   $0x0
f0104420:	6a 28                	push   $0x28
f0104422:	eb 30                	jmp    f0104454 <_alltraps>

f0104424 <th41>:
	noec(th41, 41)
f0104424:	6a 00                	push   $0x0
f0104426:	6a 29                	push   $0x29
f0104428:	eb 2a                	jmp    f0104454 <_alltraps>

f010442a <th42>:
	noec(th42, 42)
f010442a:	6a 00                	push   $0x0
f010442c:	6a 2a                	push   $0x2a
f010442e:	eb 24                	jmp    f0104454 <_alltraps>

f0104430 <th43>:
	noec(th43, 43)
f0104430:	6a 00                	push   $0x0
f0104432:	6a 2b                	push   $0x2b
f0104434:	eb 1e                	jmp    f0104454 <_alltraps>

f0104436 <th44>:
	noec(th44, 44)
f0104436:	6a 00                	push   $0x0
f0104438:	6a 2c                	push   $0x2c
f010443a:	eb 18                	jmp    f0104454 <_alltraps>

f010443c <th45>:
	noec(th45, 45)
f010443c:	6a 00                	push   $0x0
f010443e:	6a 2d                	push   $0x2d
f0104440:	eb 12                	jmp    f0104454 <_alltraps>

f0104442 <th46>:
	noec(th46, 46)
f0104442:	6a 00                	push   $0x0
f0104444:	6a 2e                	push   $0x2e
f0104446:	eb 0c                	jmp    f0104454 <_alltraps>

f0104448 <th47>:
	noec(th47, 47)
f0104448:	6a 00                	push   $0x0
f010444a:	6a 2f                	push   $0x2f
f010444c:	eb 06                	jmp    f0104454 <_alltraps>

f010444e <th48>:
	noec(th48, 48)
f010444e:	6a 00                	push   $0x0
f0104450:	6a 30                	push   $0x30
f0104452:	eb 00                	jmp    f0104454 <_alltraps>

f0104454 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104454:	1e                   	push   %ds
	pushl %es
f0104455:	06                   	push   %es
	pushal
f0104456:	60                   	pusha  
	pushl $GD_KD
f0104457:	6a 10                	push   $0x10
	popl %ds
f0104459:	1f                   	pop    %ds
	pushl $GD_KD
f010445a:	6a 10                	push   $0x10
	popl %es
f010445c:	07                   	pop    %es
	pushl %esp
f010445d:	54                   	push   %esp
	call trap
f010445e:	e8 fd fc ff ff       	call   f0104160 <trap>

f0104463 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104463:	55                   	push   %ebp
f0104464:	89 e5                	mov    %esp,%ebp
f0104466:	53                   	push   %ebx
f0104467:	83 ec 04             	sub    $0x4,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010446a:	8b 1d 48 b2 22 f0    	mov    0xf022b248,%ebx
f0104470:	8d 4b 54             	lea    0x54(%ebx),%ecx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104473:	ba 00 00 00 00       	mov    $0x0,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104478:	8b 01                	mov    (%ecx),%eax
f010447a:	83 e8 02             	sub    $0x2,%eax
f010447d:	83 f8 01             	cmp    $0x1,%eax
f0104480:	76 10                	jbe    f0104492 <sched_halt+0x2f>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104482:	83 c2 01             	add    $0x1,%edx
f0104485:	83 e9 80             	sub    $0xffffff80,%ecx
f0104488:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f010448e:	75 e8                	jne    f0104478 <sched_halt+0x15>
f0104490:	eb 08                	jmp    f010449a <sched_halt+0x37>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104492:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104498:	75 4a                	jne    f01044e4 <sched_halt+0x81>
		for (i = 0; i < 2; ++i)
			cprintf("envs[%x].env_status: %x\n", i, envs[i].env_status);
f010449a:	83 ec 04             	sub    $0x4,%esp
f010449d:	ff 73 54             	pushl  0x54(%ebx)
f01044a0:	6a 00                	push   $0x0
f01044a2:	68 b0 7d 10 f0       	push   $0xf0107db0
f01044a7:	e8 26 f6 ff ff       	call   f0103ad2 <cprintf>
f01044ac:	83 c4 0c             	add    $0xc,%esp
f01044af:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
f01044b4:	ff b0 d4 00 00 00    	pushl  0xd4(%eax)
f01044ba:	6a 01                	push   $0x1
f01044bc:	68 b0 7d 10 f0       	push   $0xf0107db0
f01044c1:	e8 0c f6 ff ff       	call   f0103ad2 <cprintf>
		cprintf("No runnable environments in the system!\n");
f01044c6:	c7 04 24 d8 7d 10 f0 	movl   $0xf0107dd8,(%esp)
f01044cd:	e8 00 f6 ff ff       	call   f0103ad2 <cprintf>
f01044d2:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044d5:	83 ec 0c             	sub    $0xc,%esp
f01044d8:	6a 00                	push   $0x0
f01044da:	e8 e1 c5 ff ff       	call   f0100ac0 <monitor>
f01044df:	83 c4 10             	add    $0x10,%esp
f01044e2:	eb f1                	jmp    f01044d5 <sched_halt+0x72>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044e4:	e8 73 18 00 00       	call   f0105d5c <cpunum>
f01044e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ec:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f01044f3:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044f6:	a1 94 be 22 f0       	mov    0xf022be94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01044fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104500:	77 12                	ja     f0104514 <sched_halt+0xb1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104502:	50                   	push   %eax
f0104503:	68 88 65 10 f0       	push   $0xf0106588
f0104508:	6a 57                	push   $0x57
f010450a:	68 c9 7d 10 f0       	push   $0xf0107dc9
f010450f:	e8 80 bb ff ff       	call   f0100094 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104514:	05 00 00 00 10       	add    $0x10000000,%eax
f0104519:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010451c:	e8 3b 18 00 00       	call   f0105d5c <cpunum>
f0104521:	6b d0 74             	imul   $0x74,%eax,%edx
f0104524:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010452a:	b8 02 00 00 00       	mov    $0x2,%eax
f010452f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104533:	83 ec 0c             	sub    $0xc,%esp
f0104536:	68 80 14 12 f0       	push   $0xf0121480
f010453b:	e8 27 1b 00 00       	call   f0106067 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104540:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104542:	e8 15 18 00 00       	call   f0105d5c <cpunum>
f0104547:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010454a:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0104550:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104555:	89 c4                	mov    %eax,%esp
f0104557:	6a 00                	push   $0x0
f0104559:	6a 00                	push   $0x0
f010455b:	fb                   	sti    
f010455c:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010455d:	83 c4 10             	add    $0x10,%esp
f0104560:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104563:	c9                   	leave  
f0104564:	c3                   	ret    

f0104565 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104565:	55                   	push   %ebp
f0104566:	89 e5                	mov    %esp,%ebp
f0104568:	57                   	push   %edi
f0104569:	56                   	push   %esi
f010456a:	53                   	push   %ebx
f010456b:	83 ec 0c             	sub    $0xc,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *e, *runenv = NULL;
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
f010456e:	e8 e9 17 00 00       	call   f0105d5c <cpunum>
f0104573:	6b c0 74             	imul   $0x74,%eax,%eax
	else cur = 0;
f0104576:	b9 00 00 00 00       	mov    $0x0,%ecx
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *e, *runenv = NULL;
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
f010457b:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104582:	74 17                	je     f010459b <sched_yield+0x36>
f0104584:	e8 d3 17 00 00       	call   f0105d5c <cpunum>
f0104589:	6b c0 74             	imul   $0x74,%eax,%eax
f010458c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104592:	8b 48 48             	mov    0x48(%eax),%ecx
f0104595:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
	else cur = 0;
	// cprintf("runenv: %x\n", runenv);
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE) {
f010459b:	8b 35 48 b2 22 f0    	mov    0xf022b248,%esi
f01045a1:	89 ca                	mov    %ecx,%edx
f01045a3:	81 c1 00 04 00 00    	add    $0x400,%ecx
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *e, *runenv = NULL;
f01045a9:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (curenv) cur=ENVX(curenv->env_id);
	else cur = 0;
	// cprintf("runenv: %x\n", runenv);
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE) {
f01045ae:	89 d7                	mov    %edx,%edi
f01045b0:	c1 ff 1f             	sar    $0x1f,%edi
f01045b3:	c1 ef 16             	shr    $0x16,%edi
f01045b6:	8d 04 3a             	lea    (%edx,%edi,1),%eax
f01045b9:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045be:	29 f8                	sub    %edi,%eax
f01045c0:	c1 e0 07             	shl    $0x7,%eax
f01045c3:	01 f0                	add    %esi,%eax
f01045c5:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01045c9:	75 11                	jne    f01045dc <sched_yield+0x77>
			// cprintf("envs[%x].pr: %x\n", j, envs[j].pr);
			if (runenv==NULL || envs[j].pr < runenv->pr) 
f01045cb:	85 db                	test   %ebx,%ebx
f01045cd:	74 0b                	je     f01045da <sched_yield+0x75>
f01045cf:	8b 78 7c             	mov    0x7c(%eax),%edi
				runenv = envs+j; 
f01045d2:	3b 7b 7c             	cmp    0x7c(%ebx),%edi
f01045d5:	0f 4c d8             	cmovl  %eax,%ebx
f01045d8:	eb 02                	jmp    f01045dc <sched_yield+0x77>
f01045da:	89 c3                	mov    %eax,%ebx
f01045dc:	83 c2 01             	add    $0x1,%edx
	struct Env *e, *runenv = NULL;
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
	else cur = 0;
	// cprintf("runenv: %x\n", runenv);
	for (i = 0; i < NENV; ++i) {
f01045df:	39 ca                	cmp    %ecx,%edx
f01045e1:	75 cb                	jne    f01045ae <sched_yield+0x49>
			if (runenv==NULL || envs[j].pr < runenv->pr) 
				runenv = envs+j; 
		}
	}
// cprintf("runenv: %x\n", runenv);
	if (curenv && (curenv->env_status == ENV_RUNNING) && ((runenv==NULL) || (curenv->pr < runenv->pr))) {
f01045e3:	e8 74 17 00 00       	call   f0105d5c <cpunum>
f01045e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01045eb:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01045f2:	74 44                	je     f0104638 <sched_yield+0xd3>
f01045f4:	e8 63 17 00 00       	call   f0105d5c <cpunum>
f01045f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01045fc:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104602:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104606:	75 30                	jne    f0104638 <sched_yield+0xd3>
f0104608:	85 db                	test   %ebx,%ebx
f010460a:	74 16                	je     f0104622 <sched_yield+0xbd>
f010460c:	e8 4b 17 00 00       	call   f0105d5c <cpunum>
f0104611:	6b c0 74             	imul   $0x74,%eax,%eax
f0104614:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010461a:	8b 73 7c             	mov    0x7c(%ebx),%esi
f010461d:	39 70 7c             	cmp    %esi,0x7c(%eax)
f0104620:	7d 1a                	jge    f010463c <sched_yield+0xd7>
		// cprintf("envs[%x].pr: %x\n", ENVX(curenv->env_id), curenv->pr);
		env_run(curenv);
f0104622:	e8 35 17 00 00       	call   f0105d5c <cpunum>
f0104627:	83 ec 0c             	sub    $0xc,%esp
f010462a:	6b c0 74             	imul   $0x74,%eax,%eax
f010462d:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104633:	e8 7e f2 ff ff       	call   f01038b6 <env_run>
	}
// cprintf("runenv: %x\n", runenv);
	if (runenv) {
f0104638:	85 db                	test   %ebx,%ebx
f010463a:	74 09                	je     f0104645 <sched_yield+0xe0>
		// cprintf("envs[%x].pr: %x\n", ENVX(runenv->env_id), runenv->pr);
		env_run(runenv);
f010463c:	83 ec 0c             	sub    $0xc,%esp
f010463f:	53                   	push   %ebx
f0104640:	e8 71 f2 ff ff       	call   f01038b6 <env_run>
	}

// cprintf("runenv: %x\n", runenv);
	// sched_halt never returns
	// cprintf("Nothing runnable\n");
	sched_halt();
f0104645:	e8 19 fe ff ff       	call   f0104463 <sched_halt>
}
f010464a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010464d:	5b                   	pop    %ebx
f010464e:	5e                   	pop    %esi
f010464f:	5f                   	pop    %edi
f0104650:	5d                   	pop    %ebp
f0104651:	c3                   	ret    

f0104652 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104652:	55                   	push   %ebp
f0104653:	89 e5                	mov    %esp,%ebp
f0104655:	57                   	push   %edi
f0104656:	56                   	push   %esi
f0104657:	53                   	push   %ebx
f0104658:	83 ec 1c             	sub    $0x1c,%esp
f010465b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
	// cprintf("SYS_change_pr: %x\n", SYS_change_pr);
	switch (syscallno) {
f010465e:	83 f8 0d             	cmp    $0xd,%eax
f0104661:	0f 87 31 05 00 00    	ja     f0104b98 <syscall+0x546>
f0104667:	ff 24 85 3c 7e 10 f0 	jmp    *-0xfef81c4(,%eax,4)
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f010466e:	e8 e9 16 00 00       	call   f0105d5c <cpunum>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0104673:	83 ec 04             	sub    $0x4,%esp
f0104676:	6a 01                	push   $0x1
f0104678:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010467b:	52                   	push   %edx
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f010467c:	6b c0 74             	imul   $0x74,%eax,%eax
f010467f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0104685:	ff 70 48             	pushl  0x48(%eax)
f0104688:	e8 07 ec ff ff       	call   f0103294 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f010468d:	6a 04                	push   $0x4
f010468f:	ff 75 10             	pushl  0x10(%ebp)
f0104692:	ff 75 0c             	pushl  0xc(%ebp)
f0104695:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104698:	e8 42 eb ff ff       	call   f01031df <user_mem_assert>
	//user_mem_check(struct Env *env, const void *va, size_t len, int perm)

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010469d:	83 c4 1c             	add    $0x1c,%esp
f01046a0:	ff 75 0c             	pushl  0xc(%ebp)
f01046a3:	ff 75 10             	pushl  0x10(%ebp)
f01046a6:	68 01 7e 10 f0       	push   $0xf0107e01
f01046ab:	e8 22 f4 ff ff       	call   f0103ad2 <cprintf>
f01046b0:	83 c4 10             	add    $0x10,%esp
	int ret = 0;
	// cprintf("SYS_change_pr: %x\n", SYS_change_pr);
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f01046b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01046b8:	e9 e7 04 00 00       	jmp    f0104ba4 <syscall+0x552>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01046bd:	e8 6a c0 ff ff       	call   f010072c <cons_getc>
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f01046c2:	e9 dd 04 00 00       	jmp    f0104ba4 <syscall+0x552>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f01046c7:	e8 90 16 00 00       	call   f0105d5c <cpunum>
f01046cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01046cf:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01046d5:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
f01046d8:	e9 c7 04 00 00       	jmp    f0104ba4 <syscall+0x552>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046dd:	83 ec 04             	sub    $0x4,%esp
f01046e0:	6a 01                	push   $0x1
f01046e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046e5:	50                   	push   %eax
f01046e6:	ff 75 0c             	pushl  0xc(%ebp)
f01046e9:	e8 a6 eb ff ff       	call   f0103294 <envid2env>
f01046ee:	83 c4 10             	add    $0x10,%esp
f01046f1:	85 c0                	test   %eax,%eax
f01046f3:	78 69                	js     f010475e <syscall+0x10c>
		return r;
	if (e == curenv)
f01046f5:	e8 62 16 00 00       	call   f0105d5c <cpunum>
f01046fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104700:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f0104706:	75 23                	jne    f010472b <syscall+0xd9>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104708:	e8 4f 16 00 00       	call   f0105d5c <cpunum>
f010470d:	83 ec 08             	sub    $0x8,%esp
f0104710:	6b c0 74             	imul   $0x74,%eax,%eax
f0104713:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104719:	ff 70 48             	pushl  0x48(%eax)
f010471c:	68 06 7e 10 f0       	push   $0xf0107e06
f0104721:	e8 ac f3 ff ff       	call   f0103ad2 <cprintf>
f0104726:	83 c4 10             	add    $0x10,%esp
f0104729:	eb 25                	jmp    f0104750 <syscall+0xfe>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010472b:	8b 5a 48             	mov    0x48(%edx),%ebx
f010472e:	e8 29 16 00 00       	call   f0105d5c <cpunum>
f0104733:	83 ec 04             	sub    $0x4,%esp
f0104736:	53                   	push   %ebx
f0104737:	6b c0 74             	imul   $0x74,%eax,%eax
f010473a:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104740:	ff 70 48             	pushl  0x48(%eax)
f0104743:	68 21 7e 10 f0       	push   $0xf0107e21
f0104748:	e8 85 f3 ff ff       	call   f0103ad2 <cprintf>
f010474d:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104750:	83 ec 0c             	sub    $0xc,%esp
f0104753:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104756:	e8 ad f0 ff ff       	call   f0103808 <env_destroy>
f010475b:	83 c4 10             	add    $0x10,%esp
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f010475e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104763:	e9 3c 04 00 00       	jmp    f0104ba4 <syscall+0x552>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104768:	e8 f8 fd ff ff       	call   f0104565 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.

	struct Env *e;
	int ret = env_alloc(&e, curenv->env_id);
f010476d:	e8 ea 15 00 00       	call   f0105d5c <cpunum>
f0104772:	83 ec 08             	sub    $0x8,%esp
f0104775:	6b c0 74             	imul   $0x74,%eax,%eax
f0104778:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010477e:	ff 70 48             	pushl  0x48(%eax)
f0104781:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104784:	50                   	push   %eax
f0104785:	e8 15 ec ff ff       	call   f010339f <env_alloc>
	if (ret) return ret;
f010478a:	83 c4 10             	add    $0x10,%esp
f010478d:	85 c0                	test   %eax,%eax
f010478f:	0f 85 0f 04 00 00    	jne    f0104ba4 <syscall+0x552>
	e->env_tf = curenv->env_tf;
f0104795:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104798:	e8 bf 15 00 00       	call   f0105d5c <cpunum>
f010479d:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a0:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
f01047a6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01047ab:	89 df                	mov    %ebx,%edi
f01047ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_status = ENV_NOT_RUNNABLE;
f01047af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047b2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f01047b9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	// cprintf("e pgdir: %x\n", e, e->env_pgdir);

	return e->env_id;
f01047c0:	8b 40 48             	mov    0x48(%eax),%eax
f01047c3:	e9 dc 03 00 00       	jmp    f0104ba4 <syscall+0x552>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f01047c8:	83 ec 04             	sub    $0x4,%esp
f01047cb:	6a 01                	push   $0x1
f01047cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047d0:	50                   	push   %eax
f01047d1:	ff 75 0c             	pushl  0xc(%ebp)
f01047d4:	e8 bb ea ff ff       	call   f0103294 <envid2env>
	if (ret) return ret;	//bad_env
f01047d9:	83 c4 10             	add    $0x10,%esp
f01047dc:	85 c0                	test   %eax,%eax
f01047de:	0f 85 c0 03 00 00    	jne    f0104ba4 <syscall+0x552>
	// cprintf("good\n");
	if (va >= (void*)UTOP) return -E_INVAL;
f01047e4:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047eb:	77 55                	ja     f0104842 <syscall+0x1f0>
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f01047ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01047f0:	83 e0 05             	and    $0x5,%eax
f01047f3:	83 f8 05             	cmp    $0x5,%eax
f01047f6:	75 54                	jne    f010484c <syscall+0x1fa>
	// cprintf("good\n");
	struct PageInfo *pg = page_alloc(1);//init to zero
f01047f8:	83 ec 0c             	sub    $0xc,%esp
f01047fb:	6a 01                	push   $0x1
f01047fd:	e8 42 cb ff ff       	call   f0101344 <page_alloc>
f0104802:	89 c3                	mov    %eax,%ebx
	if (!pg) return -E_NO_MEM;
f0104804:	83 c4 10             	add    $0x10,%esp
f0104807:	85 c0                	test   %eax,%eax
f0104809:	74 4b                	je     f0104856 <syscall+0x204>
	// cprintf("good\n");
	pg->pp_ref++;
f010480b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	ret = page_insert(e->env_pgdir, pg, va, perm);
f0104810:	ff 75 14             	pushl  0x14(%ebp)
f0104813:	ff 75 10             	pushl  0x10(%ebp)
f0104816:	50                   	push   %eax
f0104817:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010481a:	ff 70 60             	pushl  0x60(%eax)
f010481d:	e8 e4 cd ff ff       	call   f0101606 <page_insert>
f0104822:	89 c6                	mov    %eax,%esi
	if (ret) {
f0104824:	83 c4 10             	add    $0x10,%esp
f0104827:	85 c0                	test   %eax,%eax
f0104829:	0f 84 75 03 00 00    	je     f0104ba4 <syscall+0x552>
		page_free(pg);
f010482f:	83 ec 0c             	sub    $0xc,%esp
f0104832:	53                   	push   %ebx
f0104833:	e8 76 cb ff ff       	call   f01013ae <page_free>
f0104838:	83 c4 10             	add    $0x10,%esp
		return ret;
f010483b:	89 f0                	mov    %esi,%eax
f010483d:	e9 62 03 00 00       	jmp    f0104ba4 <syscall+0x552>
	//   allocated!
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
	if (ret) return ret;	//bad_env
	// cprintf("good\n");
	if (va >= (void*)UTOP) return -E_INVAL;
f0104842:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104847:	e9 58 03 00 00       	jmp    f0104ba4 <syscall+0x552>
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f010484c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104851:	e9 4e 03 00 00       	jmp    f0104ba4 <syscall+0x552>
	// cprintf("good\n");
	struct PageInfo *pg = page_alloc(1);//init to zero
	if (!pg) return -E_NO_MEM;
f0104856:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010485b:	e9 44 03 00 00       	jmp    f0104ba4 <syscall+0x552>

	// LAB 4: Your code here.
	//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	//		or the caller doesn't have permission to change one of them.
	struct Env *se, *de;
	int ret = envid2env(srcenvid, &se, 1);
f0104860:	83 ec 04             	sub    $0x4,%esp
f0104863:	6a 01                	push   $0x1
f0104865:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104868:	50                   	push   %eax
f0104869:	ff 75 0c             	pushl  0xc(%ebp)
f010486c:	e8 23 ea ff ff       	call   f0103294 <envid2env>
	if (ret) return ret;	//bad_env
f0104871:	83 c4 10             	add    $0x10,%esp
f0104874:	85 c0                	test   %eax,%eax
f0104876:	0f 85 28 03 00 00    	jne    f0104ba4 <syscall+0x552>
	ret = envid2env(dstenvid, &de, 1);
f010487c:	83 ec 04             	sub    $0x4,%esp
f010487f:	6a 01                	push   $0x1
f0104881:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104884:	50                   	push   %eax
f0104885:	ff 75 14             	pushl  0x14(%ebp)
f0104888:	e8 07 ea ff ff       	call   f0103294 <envid2env>
	if (ret) return ret;	//bad_env
f010488d:	83 c4 10             	add    $0x10,%esp
f0104890:	85 c0                	test   %eax,%eax
f0104892:	0f 85 0c 03 00 00    	jne    f0104ba4 <syscall+0x552>
	// cprintf("src env: %x, dst env: %x, src va: %x, dst va: %x\n", 
		// se->env_id, de->env_id, srcva, dstva);

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
f0104898:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010489f:	77 73                	ja     f0104914 <syscall+0x2c2>
f01048a1:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01048a8:	77 6a                	ja     f0104914 <syscall+0x2c2>
f01048aa:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048b1:	75 6b                	jne    f010491e <syscall+0x2cc>
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL;
f01048b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		// se->env_id, de->env_id, srcva, dstva);

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
f01048b8:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01048bf:	0f 85 df 02 00 00    	jne    f0104ba4 <syscall+0x552>
		return -E_INVAL;

	//	-E_INVAL is srcva is not mapped in srcenvid's address space.
	pte_t *pte;
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
f01048c5:	83 ec 04             	sub    $0x4,%esp
f01048c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048cb:	50                   	push   %eax
f01048cc:	ff 75 10             	pushl  0x10(%ebp)
f01048cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048d2:	ff 70 60             	pushl  0x60(%eax)
f01048d5:	e8 43 cc ff ff       	call   f010151d <page_lookup>
	if (!pg) return -E_INVAL;
f01048da:	83 c4 10             	add    $0x10,%esp
f01048dd:	85 c0                	test   %eax,%eax
f01048df:	74 47                	je     f0104928 <syscall+0x2d6>

	//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f01048e1:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01048e4:	83 e2 05             	and    $0x5,%edx
f01048e7:	83 fa 05             	cmp    $0x5,%edx
f01048ea:	75 46                	jne    f0104932 <syscall+0x2e0>

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
	//		address space.
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f01048ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048ef:	f6 02 02             	testb  $0x2,(%edx)
f01048f2:	75 06                	jne    f01048fa <syscall+0x2a8>
f01048f4:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01048f8:	75 42                	jne    f010493c <syscall+0x2ea>

	//	-E_NO_MEM if there's no memory to allocate any necessary page tables.

	ret = page_insert(de->env_pgdir, pg, dstva, perm);
f01048fa:	ff 75 1c             	pushl  0x1c(%ebp)
f01048fd:	ff 75 18             	pushl  0x18(%ebp)
f0104900:	50                   	push   %eax
f0104901:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104904:	ff 70 60             	pushl  0x60(%eax)
f0104907:	e8 fa cc ff ff       	call   f0101606 <page_insert>
f010490c:	83 c4 10             	add    $0x10,%esp
f010490f:	e9 90 02 00 00       	jmp    f0104ba4 <syscall+0x552>

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL;
f0104914:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104919:	e9 86 02 00 00       	jmp    f0104ba4 <syscall+0x552>
f010491e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104923:	e9 7c 02 00 00       	jmp    f0104ba4 <syscall+0x552>

	//	-E_INVAL is srcva is not mapped in srcenvid's address space.
	pte_t *pte;
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
	if (!pg) return -E_INVAL;
f0104928:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010492d:	e9 72 02 00 00       	jmp    f0104ba4 <syscall+0x552>

	//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f0104932:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104937:	e9 68 02 00 00       	jmp    f0104ba4 <syscall+0x552>

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
	//		address space.
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f010493c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_exofork:
			return sys_exofork();
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3);
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0104941:	e9 5e 02 00 00       	jmp    f0104ba4 <syscall+0x552>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
f0104946:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010494d:	77 4b                	ja     f010499a <syscall+0x348>
		return -E_INVAL;
f010494f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
f0104954:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010495b:	0f 85 43 02 00 00    	jne    f0104ba4 <syscall+0x552>
		return -E_INVAL;
	struct Env *e;
	int ret = envid2env(envid, &e, 1);
f0104961:	83 ec 04             	sub    $0x4,%esp
f0104964:	6a 01                	push   $0x1
f0104966:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104969:	50                   	push   %eax
f010496a:	ff 75 0c             	pushl  0xc(%ebp)
f010496d:	e8 22 e9 ff ff       	call   f0103294 <envid2env>
f0104972:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	//bad_env
f0104974:	83 c4 10             	add    $0x10,%esp
f0104977:	85 c0                	test   %eax,%eax
f0104979:	0f 85 25 02 00 00    	jne    f0104ba4 <syscall+0x552>
	page_remove(e->env_pgdir, va);
f010497f:	83 ec 08             	sub    $0x8,%esp
f0104982:	ff 75 10             	pushl  0x10(%ebp)
f0104985:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104988:	ff 70 60             	pushl  0x60(%eax)
f010498b:	e8 28 cc ff ff       	call   f01015b8 <page_remove>
f0104990:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104993:	89 d8                	mov    %ebx,%eax
f0104995:	e9 0a 02 00 00       	jmp    f0104ba4 <syscall+0x552>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
		return -E_INVAL;
f010499a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010499f:	e9 00 02 00 00       	jmp    f0104ba4 <syscall+0x552>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f01049a4:	8b 45 10             	mov    0x10(%ebp),%eax
f01049a7:	83 e8 02             	sub    $0x2,%eax
f01049aa:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01049af:	75 2e                	jne    f01049df <syscall+0x38d>
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f01049b1:	83 ec 04             	sub    $0x4,%esp
f01049b4:	6a 01                	push   $0x1
f01049b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049b9:	50                   	push   %eax
f01049ba:	ff 75 0c             	pushl  0xc(%ebp)
f01049bd:	e8 d2 e8 ff ff       	call   f0103294 <envid2env>
f01049c2:	89 c2                	mov    %eax,%edx
	if (ret) return ret;	//bad_env
f01049c4:	83 c4 10             	add    $0x10,%esp
f01049c7:	85 c0                	test   %eax,%eax
f01049c9:	0f 85 d5 01 00 00    	jne    f0104ba4 <syscall+0x552>
	e->env_status = status;
f01049cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049d2:	8b 7d 10             	mov    0x10(%ebp),%edi
f01049d5:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f01049d8:	89 d0                	mov    %edx,%eax
f01049da:	e9 c5 01 00 00       	jmp    f0104ba4 <syscall+0x552>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f01049df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049e4:	e9 bb 01 00 00       	jmp    f0104ba4 <syscall+0x552>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f01049e9:	83 ec 04             	sub    $0x4,%esp
f01049ec:	6a 01                	push   $0x1
f01049ee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049f1:	50                   	push   %eax
f01049f2:	ff 75 0c             	pushl  0xc(%ebp)
f01049f5:	e8 9a e8 ff ff       	call   f0103294 <envid2env>
	if (ret) return ret;	//bad_env
f01049fa:	83 c4 10             	add    $0x10,%esp
f01049fd:	85 c0                	test   %eax,%eax
f01049ff:	0f 85 9f 01 00 00    	jne    f0104ba4 <syscall+0x552>
	e->env_pgfault_upcall = func;
f0104a05:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a08:	8b 75 10             	mov    0x10(%ebp),%esi
f0104a0b:	89 72 64             	mov    %esi,0x64(%edx)
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0104a0e:	e9 91 01 00 00       	jmp    f0104ba4 <syscall+0x552>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// cprintf("sys_ipc_try_send envid: %x, value: %x, srcva: %x, perm: %x\n", envid, value, srcva, perm);
	struct Env *e;
	int ret = envid2env(envid, &e, 0);
f0104a13:	83 ec 04             	sub    $0x4,%esp
f0104a16:	6a 00                	push   $0x0
f0104a18:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a1b:	50                   	push   %eax
f0104a1c:	ff 75 0c             	pushl  0xc(%ebp)
f0104a1f:	e8 70 e8 ff ff       	call   f0103294 <envid2env>
	if (ret) return ret;//bad env
f0104a24:	83 c4 10             	add    $0x10,%esp
f0104a27:	85 c0                	test   %eax,%eax
f0104a29:	0f 85 75 01 00 00    	jne    f0104ba4 <syscall+0x552>
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104a2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a32:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a36:	0f 84 e6 00 00 00    	je     f0104b22 <syscall+0x4d0>
	if (srcva < (void*)UTOP) {
f0104a3c:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a43:	0f 87 9d 00 00 00    	ja     f0104ae6 <syscall+0x494>
		pte_t *pte;
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104a49:	e8 0e 13 00 00       	call   f0105d5c <cpunum>
f0104a4e:	83 ec 04             	sub    $0x4,%esp
f0104a51:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104a54:	52                   	push   %edx
f0104a55:	ff 75 14             	pushl  0x14(%ebp)
f0104a58:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a5b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104a61:	ff 70 60             	pushl  0x60(%eax)
f0104a64:	e8 b4 ca ff ff       	call   f010151d <page_lookup>
f0104a69:	89 c2                	mov    %eax,%edx
		if (!pg) return -E_INVAL;
f0104a6b:	83 c4 10             	add    $0x10,%esp
f0104a6e:	85 c0                	test   %eax,%eax
f0104a70:	74 6a                	je     f0104adc <syscall+0x48a>
		if ((*pte & perm) != perm) return -E_INVAL;
f0104a72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a75:	8b 08                	mov    (%eax),%ecx
f0104a77:	89 cb                	mov    %ecx,%ebx
f0104a79:	23 5d 18             	and    0x18(%ebp),%ebx
f0104a7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a81:	39 5d 18             	cmp    %ebx,0x18(%ebp)
f0104a84:	0f 85 1a 01 00 00    	jne    f0104ba4 <syscall+0x552>
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0104a8a:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104a8e:	74 09                	je     f0104a99 <syscall+0x447>
f0104a90:	f6 c1 02             	test   $0x2,%cl
f0104a93:	0f 84 0b 01 00 00    	je     f0104ba4 <syscall+0x552>
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;
f0104a99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a9e:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104aa5:	0f 85 f9 00 00 00    	jne    f0104ba4 <syscall+0x552>
		if (e->env_ipc_dstva < (void*)UTOP) {
f0104aab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104aae:	8b 48 6c             	mov    0x6c(%eax),%ecx
f0104ab1:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104ab7:	77 2d                	ja     f0104ae6 <syscall+0x494>
			ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
f0104ab9:	ff 75 18             	pushl  0x18(%ebp)
f0104abc:	51                   	push   %ecx
f0104abd:	52                   	push   %edx
f0104abe:	ff 70 60             	pushl  0x60(%eax)
f0104ac1:	e8 40 cb ff ff       	call   f0101606 <page_insert>
			if (ret) return ret;
f0104ac6:	83 c4 10             	add    $0x10,%esp
f0104ac9:	85 c0                	test   %eax,%eax
f0104acb:	0f 85 d3 00 00 00    	jne    f0104ba4 <syscall+0x552>
			e->env_ipc_perm = perm;
f0104ad1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ad4:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104ad7:	89 48 78             	mov    %ecx,0x78(%eax)
f0104ada:	eb 0a                	jmp    f0104ae6 <syscall+0x494>
	if (ret) return ret;//bad env
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
	if (srcva < (void*)UTOP) {
		pte_t *pte;
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pg) return -E_INVAL;
f0104adc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ae1:	e9 be 00 00 00       	jmp    f0104ba4 <syscall+0x552>
			ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
			if (ret) return ret;
			e->env_ipc_perm = perm;
		}
	}
	e->env_ipc_recving = 0;
f0104ae6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104ae9:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f0104aed:	e8 6a 12 00 00       	call   f0105d5c <cpunum>
f0104af2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af5:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104afb:	8b 40 48             	mov    0x48(%eax),%eax
f0104afe:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value; 
f0104b01:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b04:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b07:	89 48 70             	mov    %ecx,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f0104b0a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104b11:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104b18:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b1d:	e9 82 00 00 00       	jmp    f0104ba4 <syscall+0x552>
	// LAB 4: Your code here.
	// cprintf("sys_ipc_try_send envid: %x, value: %x, srcva: %x, perm: %x\n", envid, value, srcva, perm);
	struct Env *e;
	int ret = envid2env(envid, &e, 0);
	if (ret) return ret;//bad env
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104b22:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0104b27:	eb 7b                	jmp    f0104ba4 <syscall+0x552>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// cprintf("sys_ipc_recv dstva: %x\n", dstva);
	if (dstva < (void*)UTOP) 
f0104b29:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104b30:	77 09                	ja     f0104b3b <syscall+0x4e9>
		if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
f0104b32:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104b39:	75 64                	jne    f0104b9f <syscall+0x54d>
			return -E_INVAL;
	curenv->env_ipc_recving = 1;
f0104b3b:	e8 1c 12 00 00       	call   f0105d5c <cpunum>
f0104b40:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b43:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b49:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104b4d:	e8 0a 12 00 00       	call   f0105d5c <cpunum>
f0104b52:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b55:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b5b:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0104b62:	e8 f5 11 00 00       	call   f0105d5c <cpunum>
f0104b67:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6a:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104b73:	89 48 6c             	mov    %ecx,0x6c(%eax)
	return 0;
f0104b76:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b7b:	eb 27                	jmp    f0104ba4 <syscall+0x552>
}

static int sys_change_pr(int pr) {
	curenv->pr = pr;
f0104b7d:	e8 da 11 00 00       	call   f0105d5c <cpunum>
f0104b82:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b85:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104b8e:	89 78 7c             	mov    %edi,0x7c(%eax)
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
		case SYS_change_pr:
			return sys_change_pr(a1);
f0104b91:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b96:	eb 0c                	jmp    f0104ba4 <syscall+0x552>
		default:
			ret = -E_INVAL;
f0104b98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b9d:	eb 05                	jmp    f0104ba4 <syscall+0x552>
{
	// LAB 4: Your code here.
	// cprintf("sys_ipc_recv dstva: %x\n", dstva);
	if (dstva < (void*)UTOP) 
		if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
			return -E_INVAL;
f0104b9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			ret = -E_INVAL;
	}
	// cprintf("ret: %x\n", ret);
	return ret;
	panic("syscall not implemented");
}
f0104ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ba7:	5b                   	pop    %ebx
f0104ba8:	5e                   	pop    %esi
f0104ba9:	5f                   	pop    %edi
f0104baa:	5d                   	pop    %ebp
f0104bab:	c3                   	ret    

f0104bac <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104bac:	55                   	push   %ebp
f0104bad:	89 e5                	mov    %esp,%ebp
f0104baf:	57                   	push   %edi
f0104bb0:	56                   	push   %esi
f0104bb1:	53                   	push   %ebx
f0104bb2:	83 ec 14             	sub    $0x14,%esp
f0104bb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104bb8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104bbb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104bbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104bc1:	8b 1a                	mov    (%edx),%ebx
f0104bc3:	8b 01                	mov    (%ecx),%eax
f0104bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104bc8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104bcf:	eb 7f                	jmp    f0104c50 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104bd4:	01 d8                	add    %ebx,%eax
f0104bd6:	89 c6                	mov    %eax,%esi
f0104bd8:	c1 ee 1f             	shr    $0x1f,%esi
f0104bdb:	01 c6                	add    %eax,%esi
f0104bdd:	d1 fe                	sar    %esi
f0104bdf:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104be2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104be5:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104be8:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104bea:	eb 03                	jmp    f0104bef <stab_binsearch+0x43>
			m--;
f0104bec:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104bef:	39 c3                	cmp    %eax,%ebx
f0104bf1:	7f 0d                	jg     f0104c00 <stab_binsearch+0x54>
f0104bf3:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104bf7:	83 ea 0c             	sub    $0xc,%edx
f0104bfa:	39 f9                	cmp    %edi,%ecx
f0104bfc:	75 ee                	jne    f0104bec <stab_binsearch+0x40>
f0104bfe:	eb 05                	jmp    f0104c05 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c00:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104c03:	eb 4b                	jmp    f0104c50 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c05:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c08:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c0b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c0f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c12:	76 11                	jbe    f0104c25 <stab_binsearch+0x79>
			*region_left = m;
f0104c14:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c17:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c19:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c1c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c23:	eb 2b                	jmp    f0104c50 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104c25:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c28:	73 14                	jae    f0104c3e <stab_binsearch+0x92>
			*region_right = m - 1;
f0104c2a:	83 e8 01             	sub    $0x1,%eax
f0104c2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c30:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c33:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c35:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c3c:	eb 12                	jmp    f0104c50 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104c3e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c41:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104c43:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104c47:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c49:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104c50:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c53:	0f 8e 78 ff ff ff    	jle    f0104bd1 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104c59:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104c5d:	75 0f                	jne    f0104c6e <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104c5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c62:	8b 00                	mov    (%eax),%eax
f0104c64:	83 e8 01             	sub    $0x1,%eax
f0104c67:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c6a:	89 06                	mov    %eax,(%esi)
f0104c6c:	eb 2c                	jmp    f0104c9a <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c71:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104c73:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c76:	8b 0e                	mov    (%esi),%ecx
f0104c78:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c7b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104c7e:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c81:	eb 03                	jmp    f0104c86 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104c83:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c86:	39 c8                	cmp    %ecx,%eax
f0104c88:	7e 0b                	jle    f0104c95 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104c8a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104c8e:	83 ea 0c             	sub    $0xc,%edx
f0104c91:	39 df                	cmp    %ebx,%edi
f0104c93:	75 ee                	jne    f0104c83 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104c95:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c98:	89 06                	mov    %eax,(%esi)
	}
}
f0104c9a:	83 c4 14             	add    $0x14,%esp
f0104c9d:	5b                   	pop    %ebx
f0104c9e:	5e                   	pop    %esi
f0104c9f:	5f                   	pop    %edi
f0104ca0:	5d                   	pop    %ebp
f0104ca1:	c3                   	ret    

f0104ca2 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104ca2:	55                   	push   %ebp
f0104ca3:	89 e5                	mov    %esp,%ebp
f0104ca5:	57                   	push   %edi
f0104ca6:	56                   	push   %esi
f0104ca7:	53                   	push   %ebx
f0104ca8:	83 ec 3c             	sub    $0x3c,%esp
f0104cab:	8b 75 08             	mov    0x8(%ebp),%esi
f0104cae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104cb1:	c7 03 74 7e 10 f0    	movl   $0xf0107e74,(%ebx)
	info->eip_line = 0;
f0104cb7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104cbe:	c7 43 08 74 7e 10 f0 	movl   $0xf0107e74,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104cc5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104ccc:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104ccf:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104cd6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104cdc:	0f 87 96 00 00 00    	ja     f0104d78 <debuginfo_eip+0xd6>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104ce2:	e8 75 10 00 00       	call   f0105d5c <cpunum>
f0104ce7:	6a 04                	push   $0x4
f0104ce9:	6a 10                	push   $0x10
f0104ceb:	68 00 00 20 00       	push   $0x200000
f0104cf0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cf3:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104cf9:	e8 5f e4 ff ff       	call   f010315d <user_mem_check>
f0104cfe:	83 c4 10             	add    $0x10,%esp
f0104d01:	85 c0                	test   %eax,%eax
f0104d03:	0f 85 28 02 00 00    	jne    f0104f31 <debuginfo_eip+0x28f>
			return -1;

		stabs = usd->stabs;
f0104d09:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d0e:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104d11:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0104d17:	a1 08 00 20 00       	mov    0x200008,%eax
f0104d1c:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d1f:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104d25:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0104d28:	e8 2f 10 00 00       	call   f0105d5c <cpunum>
f0104d2d:	6a 04                	push   $0x4
f0104d2f:	6a 0c                	push   $0xc
f0104d31:	ff 75 c0             	pushl  -0x40(%ebp)
f0104d34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d37:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104d3d:	e8 1b e4 ff ff       	call   f010315d <user_mem_check>
f0104d42:	83 c4 10             	add    $0x10,%esp
f0104d45:	85 c0                	test   %eax,%eax
f0104d47:	0f 85 eb 01 00 00    	jne    f0104f38 <debuginfo_eip+0x296>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0104d4d:	e8 0a 10 00 00       	call   f0105d5c <cpunum>
f0104d52:	6a 04                	push   $0x4
f0104d54:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104d57:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104d5a:	29 ca                	sub    %ecx,%edx
f0104d5c:	52                   	push   %edx
f0104d5d:	51                   	push   %ecx
f0104d5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d61:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104d67:	e8 f1 e3 ff ff       	call   f010315d <user_mem_check>
f0104d6c:	83 c4 10             	add    $0x10,%esp
f0104d6f:	85 c0                	test   %eax,%eax
f0104d71:	74 1f                	je     f0104d92 <debuginfo_eip+0xf0>
f0104d73:	e9 c7 01 00 00       	jmp    f0104f3f <debuginfo_eip+0x29d>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104d78:	c7 45 bc c1 62 11 f0 	movl   $0xf01162c1,-0x44(%ebp)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104d7f:	c7 45 b8 49 2b 11 f0 	movl   $0xf0112b49,-0x48(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104d86:	bf 48 2b 11 f0       	mov    $0xf0112b48,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104d8b:	c7 45 c0 54 83 10 f0 	movl   $0xf0108354,-0x40(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d92:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104d95:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104d98:	0f 83 a8 01 00 00    	jae    f0104f46 <debuginfo_eip+0x2a4>
f0104d9e:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104da2:	0f 85 a5 01 00 00    	jne    f0104f4d <debuginfo_eip+0x2ab>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104da8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104daf:	2b 7d c0             	sub    -0x40(%ebp),%edi
f0104db2:	c1 ff 02             	sar    $0x2,%edi
f0104db5:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0104dbb:	83 e8 01             	sub    $0x1,%eax
f0104dbe:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104dc1:	83 ec 08             	sub    $0x8,%esp
f0104dc4:	56                   	push   %esi
f0104dc5:	6a 64                	push   $0x64
f0104dc7:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104dca:	89 d1                	mov    %edx,%ecx
f0104dcc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104dcf:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104dd2:	89 f8                	mov    %edi,%eax
f0104dd4:	e8 d3 fd ff ff       	call   f0104bac <stab_binsearch>
	if (lfile == 0)
f0104dd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ddc:	83 c4 10             	add    $0x10,%esp
f0104ddf:	85 c0                	test   %eax,%eax
f0104de1:	0f 84 6d 01 00 00    	je     f0104f54 <debuginfo_eip+0x2b2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104de7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104dea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ded:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104df0:	83 ec 08             	sub    $0x8,%esp
f0104df3:	56                   	push   %esi
f0104df4:	6a 24                	push   $0x24
f0104df6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104df9:	89 d1                	mov    %edx,%ecx
f0104dfb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104dfe:	89 f8                	mov    %edi,%eax
f0104e00:	e8 a7 fd ff ff       	call   f0104bac <stab_binsearch>

	if (lfun <= rfun) {
f0104e05:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e08:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e0b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104e0e:	83 c4 10             	add    $0x10,%esp
f0104e11:	39 d0                	cmp    %edx,%eax
f0104e13:	7f 2b                	jg     f0104e40 <debuginfo_eip+0x19e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e15:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e18:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104e1b:	8b 11                	mov    (%ecx),%edx
f0104e1d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104e20:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0104e23:	39 fa                	cmp    %edi,%edx
f0104e25:	73 06                	jae    f0104e2d <debuginfo_eip+0x18b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e27:	03 55 b8             	add    -0x48(%ebp),%edx
f0104e2a:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e2d:	8b 51 08             	mov    0x8(%ecx),%edx
f0104e30:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e33:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104e35:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104e38:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104e3b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104e3e:	eb 0f                	jmp    f0104e4f <debuginfo_eip+0x1ad>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e40:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104e43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e46:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104e49:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e4f:	83 ec 08             	sub    $0x8,%esp
f0104e52:	6a 3a                	push   $0x3a
f0104e54:	ff 73 08             	pushl  0x8(%ebx)
f0104e57:	e8 c5 08 00 00       	call   f0105721 <strfind>
f0104e5c:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e5f:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e62:	83 c4 08             	add    $0x8,%esp
f0104e65:	56                   	push   %esi
f0104e66:	6a 44                	push   $0x44
f0104e68:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e6b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104e6e:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104e71:	89 f8                	mov    %edi,%eax
f0104e73:	e8 34 fd ff ff       	call   f0104bac <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0104e78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e7b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e7e:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104e81:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104e85:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e8b:	83 c4 10             	add    $0x10,%esp
f0104e8e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104e92:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e95:	eb 0a                	jmp    f0104ea1 <debuginfo_eip+0x1ff>
f0104e97:	83 e8 01             	sub    $0x1,%eax
f0104e9a:	83 ea 0c             	sub    $0xc,%edx
f0104e9d:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104ea1:	39 c7                	cmp    %eax,%edi
f0104ea3:	7e 05                	jle    f0104eaa <debuginfo_eip+0x208>
f0104ea5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ea8:	eb 47                	jmp    f0104ef1 <debuginfo_eip+0x24f>
	       && stabs[lline].n_type != N_SOL
f0104eaa:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104eae:	80 f9 84             	cmp    $0x84,%cl
f0104eb1:	75 0e                	jne    f0104ec1 <debuginfo_eip+0x21f>
f0104eb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104eb6:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104eba:	74 1c                	je     f0104ed8 <debuginfo_eip+0x236>
f0104ebc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104ebf:	eb 17                	jmp    f0104ed8 <debuginfo_eip+0x236>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ec1:	80 f9 64             	cmp    $0x64,%cl
f0104ec4:	75 d1                	jne    f0104e97 <debuginfo_eip+0x1f5>
f0104ec6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104eca:	74 cb                	je     f0104e97 <debuginfo_eip+0x1f5>
f0104ecc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ecf:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ed3:	74 03                	je     f0104ed8 <debuginfo_eip+0x236>
f0104ed5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ed8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104edb:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104ede:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104ee1:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104ee4:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104ee7:	29 f0                	sub    %esi,%eax
f0104ee9:	39 c2                	cmp    %eax,%edx
f0104eeb:	73 04                	jae    f0104ef1 <debuginfo_eip+0x24f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104eed:	01 f2                	add    %esi,%edx
f0104eef:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ef1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104ef4:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ef7:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104efc:	39 f2                	cmp    %esi,%edx
f0104efe:	7d 60                	jge    f0104f60 <debuginfo_eip+0x2be>
		for (lline = lfun + 1;
f0104f00:	83 c2 01             	add    $0x1,%edx
f0104f03:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104f06:	89 d0                	mov    %edx,%eax
f0104f08:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104f0b:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104f0e:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104f11:	eb 04                	jmp    f0104f17 <debuginfo_eip+0x275>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f13:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f17:	39 c6                	cmp    %eax,%esi
f0104f19:	7e 40                	jle    f0104f5b <debuginfo_eip+0x2b9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f1b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f1f:	83 c0 01             	add    $0x1,%eax
f0104f22:	83 c2 0c             	add    $0xc,%edx
f0104f25:	80 f9 a0             	cmp    $0xa0,%cl
f0104f28:	74 e9                	je     f0104f13 <debuginfo_eip+0x271>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f2a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f2f:	eb 2f                	jmp    f0104f60 <debuginfo_eip+0x2be>
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0104f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f36:	eb 28                	jmp    f0104f60 <debuginfo_eip+0x2be>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0104f38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f3d:	eb 21                	jmp    f0104f60 <debuginfo_eip+0x2be>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f0104f3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f44:	eb 1a                	jmp    f0104f60 <debuginfo_eip+0x2be>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f4b:	eb 13                	jmp    f0104f60 <debuginfo_eip+0x2be>
f0104f4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f52:	eb 0c                	jmp    f0104f60 <debuginfo_eip+0x2be>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104f54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f59:	eb 05                	jmp    f0104f60 <debuginfo_eip+0x2be>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f63:	5b                   	pop    %ebx
f0104f64:	5e                   	pop    %esi
f0104f65:	5f                   	pop    %edi
f0104f66:	5d                   	pop    %ebp
f0104f67:	c3                   	ret    

f0104f68 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f68:	55                   	push   %ebp
f0104f69:	89 e5                	mov    %esp,%ebp
f0104f6b:	57                   	push   %edi
f0104f6c:	56                   	push   %esi
f0104f6d:	53                   	push   %ebx
f0104f6e:	83 ec 1c             	sub    $0x1c,%esp
f0104f71:	89 c7                	mov    %eax,%edi
f0104f73:	89 d6                	mov    %edx,%esi
f0104f75:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f78:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f7b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f7e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f81:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f84:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f89:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f8c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104f8f:	39 d3                	cmp    %edx,%ebx
f0104f91:	72 05                	jb     f0104f98 <printnum+0x30>
f0104f93:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104f96:	77 45                	ja     f0104fdd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104f98:	83 ec 0c             	sub    $0xc,%esp
f0104f9b:	ff 75 18             	pushl  0x18(%ebp)
f0104f9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fa1:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104fa4:	53                   	push   %ebx
f0104fa5:	ff 75 10             	pushl  0x10(%ebp)
f0104fa8:	83 ec 08             	sub    $0x8,%esp
f0104fab:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fae:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fb1:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fb4:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fb7:	e8 a4 11 00 00       	call   f0106160 <__udivdi3>
f0104fbc:	83 c4 18             	add    $0x18,%esp
f0104fbf:	52                   	push   %edx
f0104fc0:	50                   	push   %eax
f0104fc1:	89 f2                	mov    %esi,%edx
f0104fc3:	89 f8                	mov    %edi,%eax
f0104fc5:	e8 9e ff ff ff       	call   f0104f68 <printnum>
f0104fca:	83 c4 20             	add    $0x20,%esp
f0104fcd:	eb 18                	jmp    f0104fe7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104fcf:	83 ec 08             	sub    $0x8,%esp
f0104fd2:	56                   	push   %esi
f0104fd3:	ff 75 18             	pushl  0x18(%ebp)
f0104fd6:	ff d7                	call   *%edi
f0104fd8:	83 c4 10             	add    $0x10,%esp
f0104fdb:	eb 03                	jmp    f0104fe0 <printnum+0x78>
f0104fdd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104fe0:	83 eb 01             	sub    $0x1,%ebx
f0104fe3:	85 db                	test   %ebx,%ebx
f0104fe5:	7f e8                	jg     f0104fcf <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104fe7:	83 ec 08             	sub    $0x8,%esp
f0104fea:	56                   	push   %esi
f0104feb:	83 ec 04             	sub    $0x4,%esp
f0104fee:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ff1:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ff4:	ff 75 dc             	pushl  -0x24(%ebp)
f0104ff7:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ffa:	e8 91 12 00 00       	call   f0106290 <__umoddi3>
f0104fff:	83 c4 14             	add    $0x14,%esp
f0105002:	0f be 80 7e 7e 10 f0 	movsbl -0xfef8182(%eax),%eax
f0105009:	50                   	push   %eax
f010500a:	ff d7                	call   *%edi
}
f010500c:	83 c4 10             	add    $0x10,%esp
f010500f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105012:	5b                   	pop    %ebx
f0105013:	5e                   	pop    %esi
f0105014:	5f                   	pop    %edi
f0105015:	5d                   	pop    %ebp
f0105016:	c3                   	ret    

f0105017 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105017:	55                   	push   %ebp
f0105018:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010501a:	83 fa 01             	cmp    $0x1,%edx
f010501d:	7e 0e                	jle    f010502d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010501f:	8b 10                	mov    (%eax),%edx
f0105021:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105024:	89 08                	mov    %ecx,(%eax)
f0105026:	8b 02                	mov    (%edx),%eax
f0105028:	8b 52 04             	mov    0x4(%edx),%edx
f010502b:	eb 22                	jmp    f010504f <getuint+0x38>
	else if (lflag)
f010502d:	85 d2                	test   %edx,%edx
f010502f:	74 10                	je     f0105041 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105031:	8b 10                	mov    (%eax),%edx
f0105033:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105036:	89 08                	mov    %ecx,(%eax)
f0105038:	8b 02                	mov    (%edx),%eax
f010503a:	ba 00 00 00 00       	mov    $0x0,%edx
f010503f:	eb 0e                	jmp    f010504f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105041:	8b 10                	mov    (%eax),%edx
f0105043:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105046:	89 08                	mov    %ecx,(%eax)
f0105048:	8b 02                	mov    (%edx),%eax
f010504a:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010504f:	5d                   	pop    %ebp
f0105050:	c3                   	ret    

f0105051 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105051:	55                   	push   %ebp
f0105052:	89 e5                	mov    %esp,%ebp
f0105054:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105057:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010505b:	8b 10                	mov    (%eax),%edx
f010505d:	3b 50 04             	cmp    0x4(%eax),%edx
f0105060:	73 0a                	jae    f010506c <sprintputch+0x1b>
		*b->buf++ = ch;
f0105062:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105065:	89 08                	mov    %ecx,(%eax)
f0105067:	8b 45 08             	mov    0x8(%ebp),%eax
f010506a:	88 02                	mov    %al,(%edx)
}
f010506c:	5d                   	pop    %ebp
f010506d:	c3                   	ret    

f010506e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010506e:	55                   	push   %ebp
f010506f:	89 e5                	mov    %esp,%ebp
f0105071:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105074:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105077:	50                   	push   %eax
f0105078:	ff 75 10             	pushl  0x10(%ebp)
f010507b:	ff 75 0c             	pushl  0xc(%ebp)
f010507e:	ff 75 08             	pushl  0x8(%ebp)
f0105081:	e8 05 00 00 00       	call   f010508b <vprintfmt>
	va_end(ap);
}
f0105086:	83 c4 10             	add    $0x10,%esp
f0105089:	c9                   	leave  
f010508a:	c3                   	ret    

f010508b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010508b:	55                   	push   %ebp
f010508c:	89 e5                	mov    %esp,%ebp
f010508e:	57                   	push   %edi
f010508f:	56                   	push   %esi
f0105090:	53                   	push   %ebx
f0105091:	83 ec 2c             	sub    $0x2c,%esp
f0105094:	8b 75 08             	mov    0x8(%ebp),%esi
f0105097:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010509a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010509d:	eb 1d                	jmp    f01050bc <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
f010509f:	85 c0                	test   %eax,%eax
f01050a1:	75 0f                	jne    f01050b2 <vprintfmt+0x27>
				csa = 0x0700;
f01050a3:	c7 05 88 be 22 f0 00 	movl   $0x700,0xf022be88
f01050aa:	07 00 00 
				return;
f01050ad:	e9 c4 03 00 00       	jmp    f0105476 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
f01050b2:	83 ec 08             	sub    $0x8,%esp
f01050b5:	53                   	push   %ebx
f01050b6:	50                   	push   %eax
f01050b7:	ff d6                	call   *%esi
f01050b9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01050bc:	83 c7 01             	add    $0x1,%edi
f01050bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01050c3:	83 f8 25             	cmp    $0x25,%eax
f01050c6:	75 d7                	jne    f010509f <vprintfmt+0x14>
f01050c8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01050cc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01050d3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01050da:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01050e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01050e6:	eb 07                	jmp    f01050ef <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01050eb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050ef:	8d 47 01             	lea    0x1(%edi),%eax
f01050f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01050f5:	0f b6 07             	movzbl (%edi),%eax
f01050f8:	0f b6 c8             	movzbl %al,%ecx
f01050fb:	83 e8 23             	sub    $0x23,%eax
f01050fe:	3c 55                	cmp    $0x55,%al
f0105100:	0f 87 55 03 00 00    	ja     f010545b <vprintfmt+0x3d0>
f0105106:	0f b6 c0             	movzbl %al,%eax
f0105109:	ff 24 85 40 7f 10 f0 	jmp    *-0xfef80c0(,%eax,4)
f0105110:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105113:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105117:	eb d6                	jmp    f01050ef <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105119:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010511c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105121:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105124:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105127:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f010512b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010512e:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105131:	83 fa 09             	cmp    $0x9,%edx
f0105134:	77 39                	ja     f010516f <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105136:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105139:	eb e9                	jmp    f0105124 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010513b:	8b 45 14             	mov    0x14(%ebp),%eax
f010513e:	8d 48 04             	lea    0x4(%eax),%ecx
f0105141:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105144:	8b 00                	mov    (%eax),%eax
f0105146:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105149:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010514c:	eb 27                	jmp    f0105175 <vprintfmt+0xea>
f010514e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105151:	85 c0                	test   %eax,%eax
f0105153:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105158:	0f 49 c8             	cmovns %eax,%ecx
f010515b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010515e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105161:	eb 8c                	jmp    f01050ef <vprintfmt+0x64>
f0105163:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105166:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010516d:	eb 80                	jmp    f01050ef <vprintfmt+0x64>
f010516f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105172:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105175:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105179:	0f 89 70 ff ff ff    	jns    f01050ef <vprintfmt+0x64>
				width = precision, precision = -1;
f010517f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105182:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105185:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010518c:	e9 5e ff ff ff       	jmp    f01050ef <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105191:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105194:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105197:	e9 53 ff ff ff       	jmp    f01050ef <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010519c:	8b 45 14             	mov    0x14(%ebp),%eax
f010519f:	8d 50 04             	lea    0x4(%eax),%edx
f01051a2:	89 55 14             	mov    %edx,0x14(%ebp)
f01051a5:	83 ec 08             	sub    $0x8,%esp
f01051a8:	53                   	push   %ebx
f01051a9:	ff 30                	pushl  (%eax)
f01051ab:	ff d6                	call   *%esi
			break;
f01051ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01051b3:	e9 04 ff ff ff       	jmp    f01050bc <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01051b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01051bb:	8d 50 04             	lea    0x4(%eax),%edx
f01051be:	89 55 14             	mov    %edx,0x14(%ebp)
f01051c1:	8b 00                	mov    (%eax),%eax
f01051c3:	99                   	cltd   
f01051c4:	31 d0                	xor    %edx,%eax
f01051c6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01051c8:	83 f8 08             	cmp    $0x8,%eax
f01051cb:	7f 0b                	jg     f01051d8 <vprintfmt+0x14d>
f01051cd:	8b 14 85 a0 80 10 f0 	mov    -0xfef7f60(,%eax,4),%edx
f01051d4:	85 d2                	test   %edx,%edx
f01051d6:	75 18                	jne    f01051f0 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
f01051d8:	50                   	push   %eax
f01051d9:	68 96 7e 10 f0       	push   $0xf0107e96
f01051de:	53                   	push   %ebx
f01051df:	56                   	push   %esi
f01051e0:	e8 89 fe ff ff       	call   f010506e <printfmt>
f01051e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01051eb:	e9 cc fe ff ff       	jmp    f01050bc <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
f01051f0:	52                   	push   %edx
f01051f1:	68 90 6c 10 f0       	push   $0xf0106c90
f01051f6:	53                   	push   %ebx
f01051f7:	56                   	push   %esi
f01051f8:	e8 71 fe ff ff       	call   f010506e <printfmt>
f01051fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105200:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105203:	e9 b4 fe ff ff       	jmp    f01050bc <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105208:	8b 45 14             	mov    0x14(%ebp),%eax
f010520b:	8d 50 04             	lea    0x4(%eax),%edx
f010520e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105211:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105213:	85 ff                	test   %edi,%edi
f0105215:	b8 8f 7e 10 f0       	mov    $0xf0107e8f,%eax
f010521a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010521d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105221:	0f 8e 94 00 00 00    	jle    f01052bb <vprintfmt+0x230>
f0105227:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010522b:	0f 84 98 00 00 00    	je     f01052c9 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105231:	83 ec 08             	sub    $0x8,%esp
f0105234:	ff 75 d0             	pushl  -0x30(%ebp)
f0105237:	57                   	push   %edi
f0105238:	e8 9a 03 00 00       	call   f01055d7 <strnlen>
f010523d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105240:	29 c1                	sub    %eax,%ecx
f0105242:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105245:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105248:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010524c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010524f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105252:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105254:	eb 0f                	jmp    f0105265 <vprintfmt+0x1da>
					putch(padc, putdat);
f0105256:	83 ec 08             	sub    $0x8,%esp
f0105259:	53                   	push   %ebx
f010525a:	ff 75 e0             	pushl  -0x20(%ebp)
f010525d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010525f:	83 ef 01             	sub    $0x1,%edi
f0105262:	83 c4 10             	add    $0x10,%esp
f0105265:	85 ff                	test   %edi,%edi
f0105267:	7f ed                	jg     f0105256 <vprintfmt+0x1cb>
f0105269:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010526c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010526f:	85 c9                	test   %ecx,%ecx
f0105271:	b8 00 00 00 00       	mov    $0x0,%eax
f0105276:	0f 49 c1             	cmovns %ecx,%eax
f0105279:	29 c1                	sub    %eax,%ecx
f010527b:	89 75 08             	mov    %esi,0x8(%ebp)
f010527e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105281:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105284:	89 cb                	mov    %ecx,%ebx
f0105286:	eb 4d                	jmp    f01052d5 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105288:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010528c:	74 1b                	je     f01052a9 <vprintfmt+0x21e>
f010528e:	0f be c0             	movsbl %al,%eax
f0105291:	83 e8 20             	sub    $0x20,%eax
f0105294:	83 f8 5e             	cmp    $0x5e,%eax
f0105297:	76 10                	jbe    f01052a9 <vprintfmt+0x21e>
					putch('?', putdat);
f0105299:	83 ec 08             	sub    $0x8,%esp
f010529c:	ff 75 0c             	pushl  0xc(%ebp)
f010529f:	6a 3f                	push   $0x3f
f01052a1:	ff 55 08             	call   *0x8(%ebp)
f01052a4:	83 c4 10             	add    $0x10,%esp
f01052a7:	eb 0d                	jmp    f01052b6 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
f01052a9:	83 ec 08             	sub    $0x8,%esp
f01052ac:	ff 75 0c             	pushl  0xc(%ebp)
f01052af:	52                   	push   %edx
f01052b0:	ff 55 08             	call   *0x8(%ebp)
f01052b3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01052b6:	83 eb 01             	sub    $0x1,%ebx
f01052b9:	eb 1a                	jmp    f01052d5 <vprintfmt+0x24a>
f01052bb:	89 75 08             	mov    %esi,0x8(%ebp)
f01052be:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052c7:	eb 0c                	jmp    f01052d5 <vprintfmt+0x24a>
f01052c9:	89 75 08             	mov    %esi,0x8(%ebp)
f01052cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052d5:	83 c7 01             	add    $0x1,%edi
f01052d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01052dc:	0f be d0             	movsbl %al,%edx
f01052df:	85 d2                	test   %edx,%edx
f01052e1:	74 23                	je     f0105306 <vprintfmt+0x27b>
f01052e3:	85 f6                	test   %esi,%esi
f01052e5:	78 a1                	js     f0105288 <vprintfmt+0x1fd>
f01052e7:	83 ee 01             	sub    $0x1,%esi
f01052ea:	79 9c                	jns    f0105288 <vprintfmt+0x1fd>
f01052ec:	89 df                	mov    %ebx,%edi
f01052ee:	8b 75 08             	mov    0x8(%ebp),%esi
f01052f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052f4:	eb 18                	jmp    f010530e <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01052f6:	83 ec 08             	sub    $0x8,%esp
f01052f9:	53                   	push   %ebx
f01052fa:	6a 20                	push   $0x20
f01052fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01052fe:	83 ef 01             	sub    $0x1,%edi
f0105301:	83 c4 10             	add    $0x10,%esp
f0105304:	eb 08                	jmp    f010530e <vprintfmt+0x283>
f0105306:	89 df                	mov    %ebx,%edi
f0105308:	8b 75 08             	mov    0x8(%ebp),%esi
f010530b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010530e:	85 ff                	test   %edi,%edi
f0105310:	7f e4                	jg     f01052f6 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105315:	e9 a2 fd ff ff       	jmp    f01050bc <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010531a:	83 fa 01             	cmp    $0x1,%edx
f010531d:	7e 16                	jle    f0105335 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
f010531f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105322:	8d 50 08             	lea    0x8(%eax),%edx
f0105325:	89 55 14             	mov    %edx,0x14(%ebp)
f0105328:	8b 50 04             	mov    0x4(%eax),%edx
f010532b:	8b 00                	mov    (%eax),%eax
f010532d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105330:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105333:	eb 32                	jmp    f0105367 <vprintfmt+0x2dc>
	else if (lflag)
f0105335:	85 d2                	test   %edx,%edx
f0105337:	74 18                	je     f0105351 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
f0105339:	8b 45 14             	mov    0x14(%ebp),%eax
f010533c:	8d 50 04             	lea    0x4(%eax),%edx
f010533f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105342:	8b 00                	mov    (%eax),%eax
f0105344:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105347:	89 c1                	mov    %eax,%ecx
f0105349:	c1 f9 1f             	sar    $0x1f,%ecx
f010534c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010534f:	eb 16                	jmp    f0105367 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
f0105351:	8b 45 14             	mov    0x14(%ebp),%eax
f0105354:	8d 50 04             	lea    0x4(%eax),%edx
f0105357:	89 55 14             	mov    %edx,0x14(%ebp)
f010535a:	8b 00                	mov    (%eax),%eax
f010535c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010535f:	89 c1                	mov    %eax,%ecx
f0105361:	c1 f9 1f             	sar    $0x1f,%ecx
f0105364:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105367:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010536a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010536d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105372:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105376:	79 74                	jns    f01053ec <vprintfmt+0x361>
				putch('-', putdat);
f0105378:	83 ec 08             	sub    $0x8,%esp
f010537b:	53                   	push   %ebx
f010537c:	6a 2d                	push   $0x2d
f010537e:	ff d6                	call   *%esi
				num = -(long long) num;
f0105380:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105383:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105386:	f7 d8                	neg    %eax
f0105388:	83 d2 00             	adc    $0x0,%edx
f010538b:	f7 da                	neg    %edx
f010538d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105390:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105395:	eb 55                	jmp    f01053ec <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105397:	8d 45 14             	lea    0x14(%ebp),%eax
f010539a:	e8 78 fc ff ff       	call   f0105017 <getuint>
			base = 10;
f010539f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01053a4:	eb 46                	jmp    f01053ec <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
f01053a6:	8d 45 14             	lea    0x14(%ebp),%eax
f01053a9:	e8 69 fc ff ff       	call   f0105017 <getuint>
      base = 8;
f01053ae:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f01053b3:	eb 37                	jmp    f01053ec <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
f01053b5:	83 ec 08             	sub    $0x8,%esp
f01053b8:	53                   	push   %ebx
f01053b9:	6a 30                	push   $0x30
f01053bb:	ff d6                	call   *%esi
			putch('x', putdat);
f01053bd:	83 c4 08             	add    $0x8,%esp
f01053c0:	53                   	push   %ebx
f01053c1:	6a 78                	push   $0x78
f01053c3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01053c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01053c8:	8d 50 04             	lea    0x4(%eax),%edx
f01053cb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01053ce:	8b 00                	mov    (%eax),%eax
f01053d0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01053d5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01053d8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01053dd:	eb 0d                	jmp    f01053ec <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01053df:	8d 45 14             	lea    0x14(%ebp),%eax
f01053e2:	e8 30 fc ff ff       	call   f0105017 <getuint>
			base = 16;
f01053e7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01053ec:	83 ec 0c             	sub    $0xc,%esp
f01053ef:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01053f3:	57                   	push   %edi
f01053f4:	ff 75 e0             	pushl  -0x20(%ebp)
f01053f7:	51                   	push   %ecx
f01053f8:	52                   	push   %edx
f01053f9:	50                   	push   %eax
f01053fa:	89 da                	mov    %ebx,%edx
f01053fc:	89 f0                	mov    %esi,%eax
f01053fe:	e8 65 fb ff ff       	call   f0104f68 <printnum>
			break;
f0105403:	83 c4 20             	add    $0x20,%esp
f0105406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105409:	e9 ae fc ff ff       	jmp    f01050bc <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010540e:	83 ec 08             	sub    $0x8,%esp
f0105411:	53                   	push   %ebx
f0105412:	51                   	push   %ecx
f0105413:	ff d6                	call   *%esi
			break;
f0105415:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010541b:	e9 9c fc ff ff       	jmp    f01050bc <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105420:	83 fa 01             	cmp    $0x1,%edx
f0105423:	7e 0d                	jle    f0105432 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
f0105425:	8b 45 14             	mov    0x14(%ebp),%eax
f0105428:	8d 50 08             	lea    0x8(%eax),%edx
f010542b:	89 55 14             	mov    %edx,0x14(%ebp)
f010542e:	8b 00                	mov    (%eax),%eax
f0105430:	eb 1c                	jmp    f010544e <vprintfmt+0x3c3>
	else if (lflag)
f0105432:	85 d2                	test   %edx,%edx
f0105434:	74 0d                	je     f0105443 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
f0105436:	8b 45 14             	mov    0x14(%ebp),%eax
f0105439:	8d 50 04             	lea    0x4(%eax),%edx
f010543c:	89 55 14             	mov    %edx,0x14(%ebp)
f010543f:	8b 00                	mov    (%eax),%eax
f0105441:	eb 0b                	jmp    f010544e <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
f0105443:	8b 45 14             	mov    0x14(%ebp),%eax
f0105446:	8d 50 04             	lea    0x4(%eax),%edx
f0105449:	89 55 14             	mov    %edx,0x14(%ebp)
f010544c:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
f010544e:	a3 88 be 22 f0       	mov    %eax,0xf022be88
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
f0105456:	e9 61 fc ff ff       	jmp    f01050bc <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010545b:	83 ec 08             	sub    $0x8,%esp
f010545e:	53                   	push   %ebx
f010545f:	6a 25                	push   $0x25
f0105461:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105463:	83 c4 10             	add    $0x10,%esp
f0105466:	eb 03                	jmp    f010546b <vprintfmt+0x3e0>
f0105468:	83 ef 01             	sub    $0x1,%edi
f010546b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010546f:	75 f7                	jne    f0105468 <vprintfmt+0x3dd>
f0105471:	e9 46 fc ff ff       	jmp    f01050bc <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
f0105476:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105479:	5b                   	pop    %ebx
f010547a:	5e                   	pop    %esi
f010547b:	5f                   	pop    %edi
f010547c:	5d                   	pop    %ebp
f010547d:	c3                   	ret    

f010547e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010547e:	55                   	push   %ebp
f010547f:	89 e5                	mov    %esp,%ebp
f0105481:	83 ec 18             	sub    $0x18,%esp
f0105484:	8b 45 08             	mov    0x8(%ebp),%eax
f0105487:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010548a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010548d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105491:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105494:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010549b:	85 c0                	test   %eax,%eax
f010549d:	74 26                	je     f01054c5 <vsnprintf+0x47>
f010549f:	85 d2                	test   %edx,%edx
f01054a1:	7e 22                	jle    f01054c5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054a3:	ff 75 14             	pushl  0x14(%ebp)
f01054a6:	ff 75 10             	pushl  0x10(%ebp)
f01054a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054ac:	50                   	push   %eax
f01054ad:	68 51 50 10 f0       	push   $0xf0105051
f01054b2:	e8 d4 fb ff ff       	call   f010508b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054c0:	83 c4 10             	add    $0x10,%esp
f01054c3:	eb 05                	jmp    f01054ca <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01054c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01054ca:	c9                   	leave  
f01054cb:	c3                   	ret    

f01054cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054cc:	55                   	push   %ebp
f01054cd:	89 e5                	mov    %esp,%ebp
f01054cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054d5:	50                   	push   %eax
f01054d6:	ff 75 10             	pushl  0x10(%ebp)
f01054d9:	ff 75 0c             	pushl  0xc(%ebp)
f01054dc:	ff 75 08             	pushl  0x8(%ebp)
f01054df:	e8 9a ff ff ff       	call   f010547e <vsnprintf>
	va_end(ap);

	return rc;
}
f01054e4:	c9                   	leave  
f01054e5:	c3                   	ret    

f01054e6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054e6:	55                   	push   %ebp
f01054e7:	89 e5                	mov    %esp,%ebp
f01054e9:	57                   	push   %edi
f01054ea:	56                   	push   %esi
f01054eb:	53                   	push   %ebx
f01054ec:	83 ec 0c             	sub    $0xc,%esp
f01054ef:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01054f2:	85 c0                	test   %eax,%eax
f01054f4:	74 11                	je     f0105507 <readline+0x21>
		cprintf("%s", prompt);
f01054f6:	83 ec 08             	sub    $0x8,%esp
f01054f9:	50                   	push   %eax
f01054fa:	68 90 6c 10 f0       	push   $0xf0106c90
f01054ff:	e8 ce e5 ff ff       	call   f0103ad2 <cprintf>
f0105504:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105507:	83 ec 0c             	sub    $0xc,%esp
f010550a:	6a 00                	push   $0x0
f010550c:	e8 ab b3 ff ff       	call   f01008bc <iscons>
f0105511:	89 c7                	mov    %eax,%edi
f0105513:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105516:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010551b:	e8 8b b3 ff ff       	call   f01008ab <getchar>
f0105520:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105522:	85 c0                	test   %eax,%eax
f0105524:	79 18                	jns    f010553e <readline+0x58>
			cprintf("read error: %e\n", c);
f0105526:	83 ec 08             	sub    $0x8,%esp
f0105529:	50                   	push   %eax
f010552a:	68 c4 80 10 f0       	push   $0xf01080c4
f010552f:	e8 9e e5 ff ff       	call   f0103ad2 <cprintf>
			return NULL;
f0105534:	83 c4 10             	add    $0x10,%esp
f0105537:	b8 00 00 00 00       	mov    $0x0,%eax
f010553c:	eb 79                	jmp    f01055b7 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010553e:	83 f8 08             	cmp    $0x8,%eax
f0105541:	0f 94 c2             	sete   %dl
f0105544:	83 f8 7f             	cmp    $0x7f,%eax
f0105547:	0f 94 c0             	sete   %al
f010554a:	08 c2                	or     %al,%dl
f010554c:	74 1a                	je     f0105568 <readline+0x82>
f010554e:	85 f6                	test   %esi,%esi
f0105550:	7e 16                	jle    f0105568 <readline+0x82>
			if (echoing)
f0105552:	85 ff                	test   %edi,%edi
f0105554:	74 0d                	je     f0105563 <readline+0x7d>
				cputchar('\b');
f0105556:	83 ec 0c             	sub    $0xc,%esp
f0105559:	6a 08                	push   $0x8
f010555b:	e8 3b b3 ff ff       	call   f010089b <cputchar>
f0105560:	83 c4 10             	add    $0x10,%esp
			i--;
f0105563:	83 ee 01             	sub    $0x1,%esi
f0105566:	eb b3                	jmp    f010551b <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105568:	83 fb 1f             	cmp    $0x1f,%ebx
f010556b:	7e 23                	jle    f0105590 <readline+0xaa>
f010556d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105573:	7f 1b                	jg     f0105590 <readline+0xaa>
			if (echoing)
f0105575:	85 ff                	test   %edi,%edi
f0105577:	74 0c                	je     f0105585 <readline+0x9f>
				cputchar(c);
f0105579:	83 ec 0c             	sub    $0xc,%esp
f010557c:	53                   	push   %ebx
f010557d:	e8 19 b3 ff ff       	call   f010089b <cputchar>
f0105582:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105585:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f010558b:	8d 76 01             	lea    0x1(%esi),%esi
f010558e:	eb 8b                	jmp    f010551b <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105590:	83 fb 0a             	cmp    $0xa,%ebx
f0105593:	74 05                	je     f010559a <readline+0xb4>
f0105595:	83 fb 0d             	cmp    $0xd,%ebx
f0105598:	75 81                	jne    f010551b <readline+0x35>
			if (echoing)
f010559a:	85 ff                	test   %edi,%edi
f010559c:	74 0d                	je     f01055ab <readline+0xc5>
				cputchar('\n');
f010559e:	83 ec 0c             	sub    $0xc,%esp
f01055a1:	6a 0a                	push   $0xa
f01055a3:	e8 f3 b2 ff ff       	call   f010089b <cputchar>
f01055a8:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01055ab:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f01055b2:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f01055b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055ba:	5b                   	pop    %ebx
f01055bb:	5e                   	pop    %esi
f01055bc:	5f                   	pop    %edi
f01055bd:	5d                   	pop    %ebp
f01055be:	c3                   	ret    

f01055bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055bf:	55                   	push   %ebp
f01055c0:	89 e5                	mov    %esp,%ebp
f01055c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01055ca:	eb 03                	jmp    f01055cf <strlen+0x10>
		n++;
f01055cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01055cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01055d3:	75 f7                	jne    f01055cc <strlen+0xd>
		n++;
	return n;
}
f01055d5:	5d                   	pop    %ebp
f01055d6:	c3                   	ret    

f01055d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01055d7:	55                   	push   %ebp
f01055d8:	89 e5                	mov    %esp,%ebp
f01055da:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01055dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01055e5:	eb 03                	jmp    f01055ea <strnlen+0x13>
		n++;
f01055e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055ea:	39 c2                	cmp    %eax,%edx
f01055ec:	74 08                	je     f01055f6 <strnlen+0x1f>
f01055ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01055f2:	75 f3                	jne    f01055e7 <strnlen+0x10>
f01055f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01055f6:	5d                   	pop    %ebp
f01055f7:	c3                   	ret    

f01055f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01055f8:	55                   	push   %ebp
f01055f9:	89 e5                	mov    %esp,%ebp
f01055fb:	53                   	push   %ebx
f01055fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01055ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105602:	89 c2                	mov    %eax,%edx
f0105604:	83 c2 01             	add    $0x1,%edx
f0105607:	83 c1 01             	add    $0x1,%ecx
f010560a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010560e:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105611:	84 db                	test   %bl,%bl
f0105613:	75 ef                	jne    f0105604 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105615:	5b                   	pop    %ebx
f0105616:	5d                   	pop    %ebp
f0105617:	c3                   	ret    

f0105618 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105618:	55                   	push   %ebp
f0105619:	89 e5                	mov    %esp,%ebp
f010561b:	53                   	push   %ebx
f010561c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010561f:	53                   	push   %ebx
f0105620:	e8 9a ff ff ff       	call   f01055bf <strlen>
f0105625:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105628:	ff 75 0c             	pushl  0xc(%ebp)
f010562b:	01 d8                	add    %ebx,%eax
f010562d:	50                   	push   %eax
f010562e:	e8 c5 ff ff ff       	call   f01055f8 <strcpy>
	return dst;
}
f0105633:	89 d8                	mov    %ebx,%eax
f0105635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105638:	c9                   	leave  
f0105639:	c3                   	ret    

f010563a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010563a:	55                   	push   %ebp
f010563b:	89 e5                	mov    %esp,%ebp
f010563d:	56                   	push   %esi
f010563e:	53                   	push   %ebx
f010563f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105642:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105645:	89 f3                	mov    %esi,%ebx
f0105647:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010564a:	89 f2                	mov    %esi,%edx
f010564c:	eb 0f                	jmp    f010565d <strncpy+0x23>
		*dst++ = *src;
f010564e:	83 c2 01             	add    $0x1,%edx
f0105651:	0f b6 01             	movzbl (%ecx),%eax
f0105654:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105657:	80 39 01             	cmpb   $0x1,(%ecx)
f010565a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010565d:	39 da                	cmp    %ebx,%edx
f010565f:	75 ed                	jne    f010564e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105661:	89 f0                	mov    %esi,%eax
f0105663:	5b                   	pop    %ebx
f0105664:	5e                   	pop    %esi
f0105665:	5d                   	pop    %ebp
f0105666:	c3                   	ret    

f0105667 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105667:	55                   	push   %ebp
f0105668:	89 e5                	mov    %esp,%ebp
f010566a:	56                   	push   %esi
f010566b:	53                   	push   %ebx
f010566c:	8b 75 08             	mov    0x8(%ebp),%esi
f010566f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105672:	8b 55 10             	mov    0x10(%ebp),%edx
f0105675:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105677:	85 d2                	test   %edx,%edx
f0105679:	74 21                	je     f010569c <strlcpy+0x35>
f010567b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010567f:	89 f2                	mov    %esi,%edx
f0105681:	eb 09                	jmp    f010568c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105683:	83 c2 01             	add    $0x1,%edx
f0105686:	83 c1 01             	add    $0x1,%ecx
f0105689:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010568c:	39 c2                	cmp    %eax,%edx
f010568e:	74 09                	je     f0105699 <strlcpy+0x32>
f0105690:	0f b6 19             	movzbl (%ecx),%ebx
f0105693:	84 db                	test   %bl,%bl
f0105695:	75 ec                	jne    f0105683 <strlcpy+0x1c>
f0105697:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105699:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010569c:	29 f0                	sub    %esi,%eax
}
f010569e:	5b                   	pop    %ebx
f010569f:	5e                   	pop    %esi
f01056a0:	5d                   	pop    %ebp
f01056a1:	c3                   	ret    

f01056a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056a2:	55                   	push   %ebp
f01056a3:	89 e5                	mov    %esp,%ebp
f01056a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056ab:	eb 06                	jmp    f01056b3 <strcmp+0x11>
		p++, q++;
f01056ad:	83 c1 01             	add    $0x1,%ecx
f01056b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056b3:	0f b6 01             	movzbl (%ecx),%eax
f01056b6:	84 c0                	test   %al,%al
f01056b8:	74 04                	je     f01056be <strcmp+0x1c>
f01056ba:	3a 02                	cmp    (%edx),%al
f01056bc:	74 ef                	je     f01056ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056be:	0f b6 c0             	movzbl %al,%eax
f01056c1:	0f b6 12             	movzbl (%edx),%edx
f01056c4:	29 d0                	sub    %edx,%eax
}
f01056c6:	5d                   	pop    %ebp
f01056c7:	c3                   	ret    

f01056c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056c8:	55                   	push   %ebp
f01056c9:	89 e5                	mov    %esp,%ebp
f01056cb:	53                   	push   %ebx
f01056cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01056cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056d2:	89 c3                	mov    %eax,%ebx
f01056d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01056d7:	eb 06                	jmp    f01056df <strncmp+0x17>
		n--, p++, q++;
f01056d9:	83 c0 01             	add    $0x1,%eax
f01056dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01056df:	39 d8                	cmp    %ebx,%eax
f01056e1:	74 15                	je     f01056f8 <strncmp+0x30>
f01056e3:	0f b6 08             	movzbl (%eax),%ecx
f01056e6:	84 c9                	test   %cl,%cl
f01056e8:	74 04                	je     f01056ee <strncmp+0x26>
f01056ea:	3a 0a                	cmp    (%edx),%cl
f01056ec:	74 eb                	je     f01056d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01056ee:	0f b6 00             	movzbl (%eax),%eax
f01056f1:	0f b6 12             	movzbl (%edx),%edx
f01056f4:	29 d0                	sub    %edx,%eax
f01056f6:	eb 05                	jmp    f01056fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01056f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01056fd:	5b                   	pop    %ebx
f01056fe:	5d                   	pop    %ebp
f01056ff:	c3                   	ret    

f0105700 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105700:	55                   	push   %ebp
f0105701:	89 e5                	mov    %esp,%ebp
f0105703:	8b 45 08             	mov    0x8(%ebp),%eax
f0105706:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010570a:	eb 07                	jmp    f0105713 <strchr+0x13>
		if (*s == c)
f010570c:	38 ca                	cmp    %cl,%dl
f010570e:	74 0f                	je     f010571f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105710:	83 c0 01             	add    $0x1,%eax
f0105713:	0f b6 10             	movzbl (%eax),%edx
f0105716:	84 d2                	test   %dl,%dl
f0105718:	75 f2                	jne    f010570c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010571a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010571f:	5d                   	pop    %ebp
f0105720:	c3                   	ret    

f0105721 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105721:	55                   	push   %ebp
f0105722:	89 e5                	mov    %esp,%ebp
f0105724:	8b 45 08             	mov    0x8(%ebp),%eax
f0105727:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010572b:	eb 03                	jmp    f0105730 <strfind+0xf>
f010572d:	83 c0 01             	add    $0x1,%eax
f0105730:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105733:	38 ca                	cmp    %cl,%dl
f0105735:	74 04                	je     f010573b <strfind+0x1a>
f0105737:	84 d2                	test   %dl,%dl
f0105739:	75 f2                	jne    f010572d <strfind+0xc>
			break;
	return (char *) s;
}
f010573b:	5d                   	pop    %ebp
f010573c:	c3                   	ret    

f010573d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010573d:	55                   	push   %ebp
f010573e:	89 e5                	mov    %esp,%ebp
f0105740:	57                   	push   %edi
f0105741:	56                   	push   %esi
f0105742:	53                   	push   %ebx
f0105743:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105746:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105749:	85 c9                	test   %ecx,%ecx
f010574b:	74 36                	je     f0105783 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010574d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105753:	75 28                	jne    f010577d <memset+0x40>
f0105755:	f6 c1 03             	test   $0x3,%cl
f0105758:	75 23                	jne    f010577d <memset+0x40>
		c &= 0xFF;
f010575a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010575e:	89 d3                	mov    %edx,%ebx
f0105760:	c1 e3 08             	shl    $0x8,%ebx
f0105763:	89 d6                	mov    %edx,%esi
f0105765:	c1 e6 18             	shl    $0x18,%esi
f0105768:	89 d0                	mov    %edx,%eax
f010576a:	c1 e0 10             	shl    $0x10,%eax
f010576d:	09 f0                	or     %esi,%eax
f010576f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105771:	89 d8                	mov    %ebx,%eax
f0105773:	09 d0                	or     %edx,%eax
f0105775:	c1 e9 02             	shr    $0x2,%ecx
f0105778:	fc                   	cld    
f0105779:	f3 ab                	rep stos %eax,%es:(%edi)
f010577b:	eb 06                	jmp    f0105783 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010577d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105780:	fc                   	cld    
f0105781:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105783:	89 f8                	mov    %edi,%eax
f0105785:	5b                   	pop    %ebx
f0105786:	5e                   	pop    %esi
f0105787:	5f                   	pop    %edi
f0105788:	5d                   	pop    %ebp
f0105789:	c3                   	ret    

f010578a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010578a:	55                   	push   %ebp
f010578b:	89 e5                	mov    %esp,%ebp
f010578d:	57                   	push   %edi
f010578e:	56                   	push   %esi
f010578f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105792:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105795:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105798:	39 c6                	cmp    %eax,%esi
f010579a:	73 35                	jae    f01057d1 <memmove+0x47>
f010579c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010579f:	39 d0                	cmp    %edx,%eax
f01057a1:	73 2e                	jae    f01057d1 <memmove+0x47>
		s += n;
		d += n;
f01057a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057a6:	89 d6                	mov    %edx,%esi
f01057a8:	09 fe                	or     %edi,%esi
f01057aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057b0:	75 13                	jne    f01057c5 <memmove+0x3b>
f01057b2:	f6 c1 03             	test   $0x3,%cl
f01057b5:	75 0e                	jne    f01057c5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01057b7:	83 ef 04             	sub    $0x4,%edi
f01057ba:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057bd:	c1 e9 02             	shr    $0x2,%ecx
f01057c0:	fd                   	std    
f01057c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057c3:	eb 09                	jmp    f01057ce <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01057c5:	83 ef 01             	sub    $0x1,%edi
f01057c8:	8d 72 ff             	lea    -0x1(%edx),%esi
f01057cb:	fd                   	std    
f01057cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057ce:	fc                   	cld    
f01057cf:	eb 1d                	jmp    f01057ee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057d1:	89 f2                	mov    %esi,%edx
f01057d3:	09 c2                	or     %eax,%edx
f01057d5:	f6 c2 03             	test   $0x3,%dl
f01057d8:	75 0f                	jne    f01057e9 <memmove+0x5f>
f01057da:	f6 c1 03             	test   $0x3,%cl
f01057dd:	75 0a                	jne    f01057e9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01057df:	c1 e9 02             	shr    $0x2,%ecx
f01057e2:	89 c7                	mov    %eax,%edi
f01057e4:	fc                   	cld    
f01057e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057e7:	eb 05                	jmp    f01057ee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01057e9:	89 c7                	mov    %eax,%edi
f01057eb:	fc                   	cld    
f01057ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01057ee:	5e                   	pop    %esi
f01057ef:	5f                   	pop    %edi
f01057f0:	5d                   	pop    %ebp
f01057f1:	c3                   	ret    

f01057f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01057f2:	55                   	push   %ebp
f01057f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01057f5:	ff 75 10             	pushl  0x10(%ebp)
f01057f8:	ff 75 0c             	pushl  0xc(%ebp)
f01057fb:	ff 75 08             	pushl  0x8(%ebp)
f01057fe:	e8 87 ff ff ff       	call   f010578a <memmove>
}
f0105803:	c9                   	leave  
f0105804:	c3                   	ret    

f0105805 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105805:	55                   	push   %ebp
f0105806:	89 e5                	mov    %esp,%ebp
f0105808:	56                   	push   %esi
f0105809:	53                   	push   %ebx
f010580a:	8b 45 08             	mov    0x8(%ebp),%eax
f010580d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105810:	89 c6                	mov    %eax,%esi
f0105812:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105815:	eb 1a                	jmp    f0105831 <memcmp+0x2c>
		if (*s1 != *s2)
f0105817:	0f b6 08             	movzbl (%eax),%ecx
f010581a:	0f b6 1a             	movzbl (%edx),%ebx
f010581d:	38 d9                	cmp    %bl,%cl
f010581f:	74 0a                	je     f010582b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105821:	0f b6 c1             	movzbl %cl,%eax
f0105824:	0f b6 db             	movzbl %bl,%ebx
f0105827:	29 d8                	sub    %ebx,%eax
f0105829:	eb 0f                	jmp    f010583a <memcmp+0x35>
		s1++, s2++;
f010582b:	83 c0 01             	add    $0x1,%eax
f010582e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105831:	39 f0                	cmp    %esi,%eax
f0105833:	75 e2                	jne    f0105817 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105835:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010583a:	5b                   	pop    %ebx
f010583b:	5e                   	pop    %esi
f010583c:	5d                   	pop    %ebp
f010583d:	c3                   	ret    

f010583e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010583e:	55                   	push   %ebp
f010583f:	89 e5                	mov    %esp,%ebp
f0105841:	53                   	push   %ebx
f0105842:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105845:	89 c1                	mov    %eax,%ecx
f0105847:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010584a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010584e:	eb 0a                	jmp    f010585a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105850:	0f b6 10             	movzbl (%eax),%edx
f0105853:	39 da                	cmp    %ebx,%edx
f0105855:	74 07                	je     f010585e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105857:	83 c0 01             	add    $0x1,%eax
f010585a:	39 c8                	cmp    %ecx,%eax
f010585c:	72 f2                	jb     f0105850 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010585e:	5b                   	pop    %ebx
f010585f:	5d                   	pop    %ebp
f0105860:	c3                   	ret    

f0105861 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105861:	55                   	push   %ebp
f0105862:	89 e5                	mov    %esp,%ebp
f0105864:	57                   	push   %edi
f0105865:	56                   	push   %esi
f0105866:	53                   	push   %ebx
f0105867:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010586a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010586d:	eb 03                	jmp    f0105872 <strtol+0x11>
		s++;
f010586f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105872:	0f b6 01             	movzbl (%ecx),%eax
f0105875:	3c 20                	cmp    $0x20,%al
f0105877:	74 f6                	je     f010586f <strtol+0xe>
f0105879:	3c 09                	cmp    $0x9,%al
f010587b:	74 f2                	je     f010586f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010587d:	3c 2b                	cmp    $0x2b,%al
f010587f:	75 0a                	jne    f010588b <strtol+0x2a>
		s++;
f0105881:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105884:	bf 00 00 00 00       	mov    $0x0,%edi
f0105889:	eb 11                	jmp    f010589c <strtol+0x3b>
f010588b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105890:	3c 2d                	cmp    $0x2d,%al
f0105892:	75 08                	jne    f010589c <strtol+0x3b>
		s++, neg = 1;
f0105894:	83 c1 01             	add    $0x1,%ecx
f0105897:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010589c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01058a2:	75 15                	jne    f01058b9 <strtol+0x58>
f01058a4:	80 39 30             	cmpb   $0x30,(%ecx)
f01058a7:	75 10                	jne    f01058b9 <strtol+0x58>
f01058a9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058ad:	75 7c                	jne    f010592b <strtol+0xca>
		s += 2, base = 16;
f01058af:	83 c1 02             	add    $0x2,%ecx
f01058b2:	bb 10 00 00 00       	mov    $0x10,%ebx
f01058b7:	eb 16                	jmp    f01058cf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01058b9:	85 db                	test   %ebx,%ebx
f01058bb:	75 12                	jne    f01058cf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058c2:	80 39 30             	cmpb   $0x30,(%ecx)
f01058c5:	75 08                	jne    f01058cf <strtol+0x6e>
		s++, base = 8;
f01058c7:	83 c1 01             	add    $0x1,%ecx
f01058ca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01058cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01058d4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01058d7:	0f b6 11             	movzbl (%ecx),%edx
f01058da:	8d 72 d0             	lea    -0x30(%edx),%esi
f01058dd:	89 f3                	mov    %esi,%ebx
f01058df:	80 fb 09             	cmp    $0x9,%bl
f01058e2:	77 08                	ja     f01058ec <strtol+0x8b>
			dig = *s - '0';
f01058e4:	0f be d2             	movsbl %dl,%edx
f01058e7:	83 ea 30             	sub    $0x30,%edx
f01058ea:	eb 22                	jmp    f010590e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01058ec:	8d 72 9f             	lea    -0x61(%edx),%esi
f01058ef:	89 f3                	mov    %esi,%ebx
f01058f1:	80 fb 19             	cmp    $0x19,%bl
f01058f4:	77 08                	ja     f01058fe <strtol+0x9d>
			dig = *s - 'a' + 10;
f01058f6:	0f be d2             	movsbl %dl,%edx
f01058f9:	83 ea 57             	sub    $0x57,%edx
f01058fc:	eb 10                	jmp    f010590e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01058fe:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105901:	89 f3                	mov    %esi,%ebx
f0105903:	80 fb 19             	cmp    $0x19,%bl
f0105906:	77 16                	ja     f010591e <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105908:	0f be d2             	movsbl %dl,%edx
f010590b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010590e:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105911:	7d 0b                	jge    f010591e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105913:	83 c1 01             	add    $0x1,%ecx
f0105916:	0f af 45 10          	imul   0x10(%ebp),%eax
f010591a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010591c:	eb b9                	jmp    f01058d7 <strtol+0x76>

	if (endptr)
f010591e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105922:	74 0d                	je     f0105931 <strtol+0xd0>
		*endptr = (char *) s;
f0105924:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105927:	89 0e                	mov    %ecx,(%esi)
f0105929:	eb 06                	jmp    f0105931 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010592b:	85 db                	test   %ebx,%ebx
f010592d:	74 98                	je     f01058c7 <strtol+0x66>
f010592f:	eb 9e                	jmp    f01058cf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105931:	89 c2                	mov    %eax,%edx
f0105933:	f7 da                	neg    %edx
f0105935:	85 ff                	test   %edi,%edi
f0105937:	0f 45 c2             	cmovne %edx,%eax
}
f010593a:	5b                   	pop    %ebx
f010593b:	5e                   	pop    %esi
f010593c:	5f                   	pop    %edi
f010593d:	5d                   	pop    %ebp
f010593e:	c3                   	ret    
f010593f:	90                   	nop

f0105940 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105940:	fa                   	cli    

	xorw    %ax, %ax
f0105941:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105943:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105945:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105947:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105949:	0f 01 16             	lgdtl  (%esi)
f010594c:	74 70                	je     f01059be <mpsearch1+0x3>
	movl    %cr0, %eax
f010594e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105951:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105955:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105958:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010595e:	08 00                	or     %al,(%eax)

f0105960 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105960:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105964:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105966:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105968:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010596a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010596e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105970:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105972:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105977:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010597a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010597d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105982:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105985:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010598b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105990:	b8 df 02 10 f0       	mov    $0xf01002df,%eax
	call    *%eax
f0105995:	ff d0                	call   *%eax

f0105997 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105997:	eb fe                	jmp    f0105997 <spin>
f0105999:	8d 76 00             	lea    0x0(%esi),%esi

f010599c <gdt>:
	...
f01059a4:	ff                   	(bad)  
f01059a5:	ff 00                	incl   (%eax)
f01059a7:	00 00                	add    %al,(%eax)
f01059a9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01059b0:	00                   	.byte 0x0
f01059b1:	92                   	xchg   %eax,%edx
f01059b2:	cf                   	iret   
	...

f01059b4 <gdtdesc>:
f01059b4:	17                   	pop    %ss
f01059b5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01059ba <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01059ba:	90                   	nop

f01059bb <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01059bb:	55                   	push   %ebp
f01059bc:	89 e5                	mov    %esp,%ebp
f01059be:	57                   	push   %edi
f01059bf:	56                   	push   %esi
f01059c0:	53                   	push   %ebx
f01059c1:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059c4:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
f01059ca:	89 c3                	mov    %eax,%ebx
f01059cc:	c1 eb 0c             	shr    $0xc,%ebx
f01059cf:	39 cb                	cmp    %ecx,%ebx
f01059d1:	72 12                	jb     f01059e5 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059d3:	50                   	push   %eax
f01059d4:	68 3c 65 10 f0       	push   $0xf010653c
f01059d9:	6a 57                	push   $0x57
f01059db:	68 61 82 10 f0       	push   $0xf0108261
f01059e0:	e8 af a6 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01059e5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01059eb:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059ed:	89 c2                	mov    %eax,%edx
f01059ef:	c1 ea 0c             	shr    $0xc,%edx
f01059f2:	39 ca                	cmp    %ecx,%edx
f01059f4:	72 12                	jb     f0105a08 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059f6:	50                   	push   %eax
f01059f7:	68 3c 65 10 f0       	push   $0xf010653c
f01059fc:	6a 57                	push   $0x57
f01059fe:	68 61 82 10 f0       	push   $0xf0108261
f0105a03:	e8 8c a6 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105a08:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105a0e:	eb 2f                	jmp    f0105a3f <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a10:	83 ec 04             	sub    $0x4,%esp
f0105a13:	6a 04                	push   $0x4
f0105a15:	68 71 82 10 f0       	push   $0xf0108271
f0105a1a:	53                   	push   %ebx
f0105a1b:	e8 e5 fd ff ff       	call   f0105805 <memcmp>
f0105a20:	83 c4 10             	add    $0x10,%esp
f0105a23:	85 c0                	test   %eax,%eax
f0105a25:	75 15                	jne    f0105a3c <mpsearch1+0x81>
f0105a27:	89 da                	mov    %ebx,%edx
f0105a29:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105a2c:	0f b6 0a             	movzbl (%edx),%ecx
f0105a2f:	01 c8                	add    %ecx,%eax
f0105a31:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a34:	39 d7                	cmp    %edx,%edi
f0105a36:	75 f4                	jne    f0105a2c <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a38:	84 c0                	test   %al,%al
f0105a3a:	74 0e                	je     f0105a4a <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105a3c:	83 c3 10             	add    $0x10,%ebx
f0105a3f:	39 f3                	cmp    %esi,%ebx
f0105a41:	72 cd                	jb     f0105a10 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105a43:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a48:	eb 02                	jmp    f0105a4c <mpsearch1+0x91>
f0105a4a:	89 d8                	mov    %ebx,%eax
}
f0105a4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a4f:	5b                   	pop    %ebx
f0105a50:	5e                   	pop    %esi
f0105a51:	5f                   	pop    %edi
f0105a52:	5d                   	pop    %ebp
f0105a53:	c3                   	ret    

f0105a54 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a54:	55                   	push   %ebp
f0105a55:	89 e5                	mov    %esp,%ebp
f0105a57:	57                   	push   %edi
f0105a58:	56                   	push   %esi
f0105a59:	53                   	push   %ebx
f0105a5a:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a5d:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f0105a64:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a67:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f0105a6e:	75 16                	jne    f0105a86 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a70:	68 00 04 00 00       	push   $0x400
f0105a75:	68 3c 65 10 f0       	push   $0xf010653c
f0105a7a:	6a 6f                	push   $0x6f
f0105a7c:	68 61 82 10 f0       	push   $0xf0108261
f0105a81:	e8 0e a6 ff ff       	call   f0100094 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105a86:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105a8d:	85 c0                	test   %eax,%eax
f0105a8f:	74 16                	je     f0105aa7 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105a91:	c1 e0 04             	shl    $0x4,%eax
f0105a94:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a99:	e8 1d ff ff ff       	call   f01059bb <mpsearch1>
f0105a9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105aa1:	85 c0                	test   %eax,%eax
f0105aa3:	75 3c                	jne    f0105ae1 <mp_init+0x8d>
f0105aa5:	eb 20                	jmp    f0105ac7 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105aa7:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105aae:	c1 e0 0a             	shl    $0xa,%eax
f0105ab1:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ab6:	ba 00 04 00 00       	mov    $0x400,%edx
f0105abb:	e8 fb fe ff ff       	call   f01059bb <mpsearch1>
f0105ac0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ac3:	85 c0                	test   %eax,%eax
f0105ac5:	75 1a                	jne    f0105ae1 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105ac7:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105acc:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105ad1:	e8 e5 fe ff ff       	call   f01059bb <mpsearch1>
f0105ad6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105ad9:	85 c0                	test   %eax,%eax
f0105adb:	0f 84 5b 02 00 00    	je     f0105d3c <mp_init+0x2e8>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ae4:	8b 70 04             	mov    0x4(%eax),%esi
f0105ae7:	85 f6                	test   %esi,%esi
f0105ae9:	74 06                	je     f0105af1 <mp_init+0x9d>
f0105aeb:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105aef:	74 15                	je     f0105b06 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105af1:	83 ec 0c             	sub    $0xc,%esp
f0105af4:	68 d4 80 10 f0       	push   $0xf01080d4
f0105af9:	e8 d4 df ff ff       	call   f0103ad2 <cprintf>
f0105afe:	83 c4 10             	add    $0x10,%esp
f0105b01:	e9 36 02 00 00       	jmp    f0105d3c <mp_init+0x2e8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b06:	89 f0                	mov    %esi,%eax
f0105b08:	c1 e8 0c             	shr    $0xc,%eax
f0105b0b:	3b 05 90 be 22 f0    	cmp    0xf022be90,%eax
f0105b11:	72 15                	jb     f0105b28 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b13:	56                   	push   %esi
f0105b14:	68 3c 65 10 f0       	push   $0xf010653c
f0105b19:	68 90 00 00 00       	push   $0x90
f0105b1e:	68 61 82 10 f0       	push   $0xf0108261
f0105b23:	e8 6c a5 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105b28:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b2e:	83 ec 04             	sub    $0x4,%esp
f0105b31:	6a 04                	push   $0x4
f0105b33:	68 76 82 10 f0       	push   $0xf0108276
f0105b38:	53                   	push   %ebx
f0105b39:	e8 c7 fc ff ff       	call   f0105805 <memcmp>
f0105b3e:	83 c4 10             	add    $0x10,%esp
f0105b41:	85 c0                	test   %eax,%eax
f0105b43:	74 15                	je     f0105b5a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b45:	83 ec 0c             	sub    $0xc,%esp
f0105b48:	68 04 81 10 f0       	push   $0xf0108104
f0105b4d:	e8 80 df ff ff       	call   f0103ad2 <cprintf>
f0105b52:	83 c4 10             	add    $0x10,%esp
f0105b55:	e9 e2 01 00 00       	jmp    f0105d3c <mp_init+0x2e8>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b5a:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105b5e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105b62:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b65:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b6f:	eb 0d                	jmp    f0105b7e <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105b71:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105b78:	f0 
f0105b79:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105b7b:	83 c0 01             	add    $0x1,%eax
f0105b7e:	39 c7                	cmp    %eax,%edi
f0105b80:	75 ef                	jne    f0105b71 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b82:	84 d2                	test   %dl,%dl
f0105b84:	74 15                	je     f0105b9b <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105b86:	83 ec 0c             	sub    $0xc,%esp
f0105b89:	68 38 81 10 f0       	push   $0xf0108138
f0105b8e:	e8 3f df ff ff       	call   f0103ad2 <cprintf>
f0105b93:	83 c4 10             	add    $0x10,%esp
f0105b96:	e9 a1 01 00 00       	jmp    f0105d3c <mp_init+0x2e8>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105b9b:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105b9f:	3c 01                	cmp    $0x1,%al
f0105ba1:	74 1d                	je     f0105bc0 <mp_init+0x16c>
f0105ba3:	3c 04                	cmp    $0x4,%al
f0105ba5:	74 19                	je     f0105bc0 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105ba7:	83 ec 08             	sub    $0x8,%esp
f0105baa:	0f b6 c0             	movzbl %al,%eax
f0105bad:	50                   	push   %eax
f0105bae:	68 5c 81 10 f0       	push   $0xf010815c
f0105bb3:	e8 1a df ff ff       	call   f0103ad2 <cprintf>
f0105bb8:	83 c4 10             	add    $0x10,%esp
f0105bbb:	e9 7c 01 00 00       	jmp    f0105d3c <mp_init+0x2e8>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105bc0:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105bc4:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105bc8:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105bcd:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105bd2:	01 ce                	add    %ecx,%esi
f0105bd4:	eb 0d                	jmp    f0105be3 <mp_init+0x18f>
f0105bd6:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105bdd:	f0 
f0105bde:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105be0:	83 c0 01             	add    $0x1,%eax
f0105be3:	39 c7                	cmp    %eax,%edi
f0105be5:	75 ef                	jne    f0105bd6 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105be7:	38 53 2a             	cmp    %dl,0x2a(%ebx)
f0105bea:	74 15                	je     f0105c01 <mp_init+0x1ad>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105bec:	83 ec 0c             	sub    $0xc,%esp
f0105bef:	68 7c 81 10 f0       	push   $0xf010817c
f0105bf4:	e8 d9 de ff ff       	call   f0103ad2 <cprintf>
f0105bf9:	83 c4 10             	add    $0x10,%esp
f0105bfc:	e9 3b 01 00 00       	jmp    f0105d3c <mp_init+0x2e8>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105c01:	85 db                	test   %ebx,%ebx
f0105c03:	0f 84 33 01 00 00    	je     f0105d3c <mp_init+0x2e8>
		return;
	ismp = 1;
f0105c09:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f0105c10:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c13:	8b 43 24             	mov    0x24(%ebx),%eax
f0105c16:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c1b:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105c1e:	be 00 00 00 00       	mov    $0x0,%esi
f0105c23:	e9 85 00 00 00       	jmp    f0105cad <mp_init+0x259>
		switch (*p) {
f0105c28:	0f b6 07             	movzbl (%edi),%eax
f0105c2b:	84 c0                	test   %al,%al
f0105c2d:	74 06                	je     f0105c35 <mp_init+0x1e1>
f0105c2f:	3c 04                	cmp    $0x4,%al
f0105c31:	77 55                	ja     f0105c88 <mp_init+0x234>
f0105c33:	eb 4e                	jmp    f0105c83 <mp_init+0x22f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105c35:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105c39:	74 11                	je     f0105c4c <mp_init+0x1f8>
				bootcpu = &cpus[ncpu];
f0105c3b:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0105c42:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105c47:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f0105c4c:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f0105c51:	83 f8 07             	cmp    $0x7,%eax
f0105c54:	7f 13                	jg     f0105c69 <mp_init+0x215>
				cpus[ncpu].cpu_id = ncpu;
f0105c56:	6b d0 74             	imul   $0x74,%eax,%edx
f0105c59:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f0105c5f:	83 c0 01             	add    $0x1,%eax
f0105c62:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f0105c67:	eb 15                	jmp    f0105c7e <mp_init+0x22a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c69:	83 ec 08             	sub    $0x8,%esp
f0105c6c:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105c70:	50                   	push   %eax
f0105c71:	68 ac 81 10 f0       	push   $0xf01081ac
f0105c76:	e8 57 de ff ff       	call   f0103ad2 <cprintf>
f0105c7b:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105c7e:	83 c7 14             	add    $0x14,%edi
			continue;
f0105c81:	eb 27                	jmp    f0105caa <mp_init+0x256>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105c83:	83 c7 08             	add    $0x8,%edi
			continue;
f0105c86:	eb 22                	jmp    f0105caa <mp_init+0x256>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c88:	83 ec 08             	sub    $0x8,%esp
f0105c8b:	0f b6 c0             	movzbl %al,%eax
f0105c8e:	50                   	push   %eax
f0105c8f:	68 d4 81 10 f0       	push   $0xf01081d4
f0105c94:	e8 39 de ff ff       	call   f0103ad2 <cprintf>
			ismp = 0;
f0105c99:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f0105ca0:	00 00 00 
			i = conf->entry;
f0105ca3:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105ca7:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105caa:	83 c6 01             	add    $0x1,%esi
f0105cad:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105cb1:	39 c6                	cmp    %eax,%esi
f0105cb3:	0f 82 6f ff ff ff    	jb     f0105c28 <mp_init+0x1d4>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105cb9:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f0105cbe:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105cc5:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f0105ccc:	75 26                	jne    f0105cf4 <mp_init+0x2a0>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105cce:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f0105cd5:	00 00 00 
		lapicaddr = 0;
f0105cd8:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f0105cdf:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105ce2:	83 ec 0c             	sub    $0xc,%esp
f0105ce5:	68 f4 81 10 f0       	push   $0xf01081f4
f0105cea:	e8 e3 dd ff ff       	call   f0103ad2 <cprintf>
		return;
f0105cef:	83 c4 10             	add    $0x10,%esp
f0105cf2:	eb 48                	jmp    f0105d3c <mp_init+0x2e8>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105cf4:	83 ec 04             	sub    $0x4,%esp
f0105cf7:	ff 35 c4 c3 22 f0    	pushl  0xf022c3c4
f0105cfd:	0f b6 00             	movzbl (%eax),%eax
f0105d00:	50                   	push   %eax
f0105d01:	68 7b 82 10 f0       	push   $0xf010827b
f0105d06:	e8 c7 dd ff ff       	call   f0103ad2 <cprintf>

	if (mp->imcrp) {
f0105d0b:	83 c4 10             	add    $0x10,%esp
f0105d0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d11:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d15:	74 25                	je     f0105d3c <mp_init+0x2e8>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d17:	83 ec 0c             	sub    $0xc,%esp
f0105d1a:	68 20 82 10 f0       	push   $0xf0108220
f0105d1f:	e8 ae dd ff ff       	call   f0103ad2 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d24:	ba 22 00 00 00       	mov    $0x22,%edx
f0105d29:	b8 70 00 00 00       	mov    $0x70,%eax
f0105d2e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105d2f:	ba 23 00 00 00       	mov    $0x23,%edx
f0105d34:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d35:	83 c8 01             	or     $0x1,%eax
f0105d38:	ee                   	out    %al,(%dx)
f0105d39:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d3f:	5b                   	pop    %ebx
f0105d40:	5e                   	pop    %esi
f0105d41:	5f                   	pop    %edi
f0105d42:	5d                   	pop    %ebp
f0105d43:	c3                   	ret    

f0105d44 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105d44:	55                   	push   %ebp
f0105d45:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105d47:	8b 0d 04 d0 26 f0    	mov    0xf026d004,%ecx
f0105d4d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105d50:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105d52:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0105d57:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105d5a:	5d                   	pop    %ebp
f0105d5b:	c3                   	ret    

f0105d5c <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105d5c:	55                   	push   %ebp
f0105d5d:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105d5f:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0105d64:	85 c0                	test   %eax,%eax
f0105d66:	74 08                	je     f0105d70 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105d68:	8b 40 20             	mov    0x20(%eax),%eax
f0105d6b:	c1 e8 18             	shr    $0x18,%eax
f0105d6e:	eb 05                	jmp    f0105d75 <cpunum+0x19>
	return 0;
f0105d70:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d75:	5d                   	pop    %ebp
f0105d76:	c3                   	ret    

f0105d77 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105d77:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f0105d7c:	85 c0                	test   %eax,%eax
f0105d7e:	0f 84 21 01 00 00    	je     f0105ea5 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105d84:	55                   	push   %ebp
f0105d85:	89 e5                	mov    %esp,%ebp
f0105d87:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105d8a:	68 00 10 00 00       	push   $0x1000
f0105d8f:	50                   	push   %eax
f0105d90:	e8 d7 b8 ff ff       	call   f010166c <mmio_map_region>
f0105d95:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105d9a:	ba 27 01 00 00       	mov    $0x127,%edx
f0105d9f:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105da4:	e8 9b ff ff ff       	call   f0105d44 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105da9:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105dae:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105db3:	e8 8c ff ff ff       	call   f0105d44 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105db8:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105dbd:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105dc2:	e8 7d ff ff ff       	call   f0105d44 <lapicw>
	lapicw(TICR, 10000000); 
f0105dc7:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105dcc:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105dd1:	e8 6e ff ff ff       	call   f0105d44 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)//mask every cpu other than bootcpu
f0105dd6:	e8 81 ff ff ff       	call   f0105d5c <cpunum>
f0105ddb:	6b c0 74             	imul   $0x74,%eax,%eax
f0105dde:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105de3:	83 c4 10             	add    $0x10,%esp
f0105de6:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f0105dec:	74 0f                	je     f0105dfd <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105dee:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105df3:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105df8:	e8 47 ff ff ff       	call   f0105d44 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);//why?
f0105dfd:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e02:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e07:	e8 38 ff ff ff       	call   f0105d44 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e0c:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0105e11:	8b 40 30             	mov    0x30(%eax),%eax
f0105e14:	c1 e8 10             	shr    $0x10,%eax
f0105e17:	3c 03                	cmp    $0x3,%al
f0105e19:	76 0f                	jbe    f0105e2a <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105e1b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e20:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e25:	e8 1a ff ff ff       	call   f0105d44 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e2a:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e2f:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e34:	e8 0b ff ff ff       	call   f0105d44 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105e39:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e3e:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e43:	e8 fc fe ff ff       	call   f0105d44 <lapicw>
	lapicw(ESR, 0);
f0105e48:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e4d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e52:	e8 ed fe ff ff       	call   f0105d44 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105e57:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e5c:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e61:	e8 de fe ff ff       	call   f0105d44 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105e66:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e6b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e70:	e8 cf fe ff ff       	call   f0105d44 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105e75:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105e7a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e7f:	e8 c0 fe ff ff       	call   f0105d44 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105e84:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0105e8a:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e90:	f6 c4 10             	test   $0x10,%ah
f0105e93:	75 f5                	jne    f0105e8a <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105e95:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e9a:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e9f:	e8 a0 fe ff ff       	call   f0105d44 <lapicw>
}
f0105ea4:	c9                   	leave  
f0105ea5:	f3 c3                	repz ret 

f0105ea7 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105ea7:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f0105eae:	74 13                	je     f0105ec3 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105eb0:	55                   	push   %ebp
f0105eb1:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105eb3:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eb8:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ebd:	e8 82 fe ff ff       	call   f0105d44 <lapicw>
}
f0105ec2:	5d                   	pop    %ebp
f0105ec3:	f3 c3                	repz ret 

f0105ec5 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ec5:	55                   	push   %ebp
f0105ec6:	89 e5                	mov    %esp,%ebp
f0105ec8:	56                   	push   %esi
f0105ec9:	53                   	push   %ebx
f0105eca:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ecd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ed0:	ba 70 00 00 00       	mov    $0x70,%edx
f0105ed5:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105eda:	ee                   	out    %al,(%dx)
f0105edb:	ba 71 00 00 00       	mov    $0x71,%edx
f0105ee0:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105ee5:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ee6:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f0105eed:	75 19                	jne    f0105f08 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105eef:	68 67 04 00 00       	push   $0x467
f0105ef4:	68 3c 65 10 f0       	push   $0xf010653c
f0105ef9:	68 98 00 00 00       	push   $0x98
f0105efe:	68 98 82 10 f0       	push   $0xf0108298
f0105f03:	e8 8c a1 ff ff       	call   f0100094 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f08:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f0f:	00 00 
	wrv[1] = addr >> 4;
f0105f11:	89 d8                	mov    %ebx,%eax
f0105f13:	c1 e8 04             	shr    $0x4,%eax
f0105f16:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f1c:	c1 e6 18             	shl    $0x18,%esi
f0105f1f:	89 f2                	mov    %esi,%edx
f0105f21:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f26:	e8 19 fe ff ff       	call   f0105d44 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f2b:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f30:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f35:	e8 0a fe ff ff       	call   f0105d44 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f3a:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f3f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f44:	e8 fb fd ff ff       	call   f0105d44 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f49:	c1 eb 0c             	shr    $0xc,%ebx
f0105f4c:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f4f:	89 f2                	mov    %esi,%edx
f0105f51:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f56:	e8 e9 fd ff ff       	call   f0105d44 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f5b:	89 da                	mov    %ebx,%edx
f0105f5d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f62:	e8 dd fd ff ff       	call   f0105d44 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f67:	89 f2                	mov    %esi,%edx
f0105f69:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f6e:	e8 d1 fd ff ff       	call   f0105d44 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f73:	89 da                	mov    %ebx,%edx
f0105f75:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f7a:	e8 c5 fd ff ff       	call   f0105d44 <lapicw>
		microdelay(200);
	}
}
f0105f7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f82:	5b                   	pop    %ebx
f0105f83:	5e                   	pop    %esi
f0105f84:	5d                   	pop    %ebp
f0105f85:	c3                   	ret    

f0105f86 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105f86:	55                   	push   %ebp
f0105f87:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105f89:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f8c:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105f92:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f97:	e8 a8 fd ff ff       	call   f0105d44 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105f9c:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0105fa2:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105fa8:	f6 c4 10             	test   $0x10,%ah
f0105fab:	75 f5                	jne    f0105fa2 <lapic_ipi+0x1c>
		;
}
f0105fad:	5d                   	pop    %ebp
f0105fae:	c3                   	ret    

f0105faf <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105faf:	55                   	push   %ebp
f0105fb0:	89 e5                	mov    %esp,%ebp
f0105fb2:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105fb5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105fbb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fbe:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105fc1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105fc8:	5d                   	pop    %ebp
f0105fc9:	c3                   	ret    

f0105fca <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105fca:	55                   	push   %ebp
f0105fcb:	89 e5                	mov    %esp,%ebp
f0105fcd:	56                   	push   %esi
f0105fce:	53                   	push   %ebx
f0105fcf:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105fd2:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105fd5:	74 14                	je     f0105feb <spin_lock+0x21>
f0105fd7:	8b 73 08             	mov    0x8(%ebx),%esi
f0105fda:	e8 7d fd ff ff       	call   f0105d5c <cpunum>
f0105fdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fe2:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105fe7:	39 c6                	cmp    %eax,%esi
f0105fe9:	74 07                	je     f0105ff2 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105feb:	ba 01 00 00 00       	mov    $0x1,%edx
f0105ff0:	eb 20                	jmp    f0106012 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105ff2:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105ff5:	e8 62 fd ff ff       	call   f0105d5c <cpunum>
f0105ffa:	83 ec 0c             	sub    $0xc,%esp
f0105ffd:	53                   	push   %ebx
f0105ffe:	50                   	push   %eax
f0105fff:	68 a8 82 10 f0       	push   $0xf01082a8
f0106004:	6a 41                	push   $0x41
f0106006:	68 0c 83 10 f0       	push   $0xf010830c
f010600b:	e8 84 a0 ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106010:	f3 90                	pause  
f0106012:	89 d0                	mov    %edx,%eax
f0106014:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106017:	85 c0                	test   %eax,%eax
f0106019:	75 f5                	jne    f0106010 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010601b:	e8 3c fd ff ff       	call   f0105d5c <cpunum>
f0106020:	6b c0 74             	imul   $0x74,%eax,%eax
f0106023:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0106028:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010602b:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010602e:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106030:	b8 00 00 00 00       	mov    $0x0,%eax
f0106035:	eb 0b                	jmp    f0106042 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106037:	8b 4a 04             	mov    0x4(%edx),%ecx
f010603a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010603d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010603f:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106042:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106048:	76 11                	jbe    f010605b <spin_lock+0x91>
f010604a:	83 f8 09             	cmp    $0x9,%eax
f010604d:	7e e8                	jle    f0106037 <spin_lock+0x6d>
f010604f:	eb 0a                	jmp    f010605b <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106051:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106058:	83 c0 01             	add    $0x1,%eax
f010605b:	83 f8 09             	cmp    $0x9,%eax
f010605e:	7e f1                	jle    f0106051 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106060:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106063:	5b                   	pop    %ebx
f0106064:	5e                   	pop    %esi
f0106065:	5d                   	pop    %ebp
f0106066:	c3                   	ret    

f0106067 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106067:	55                   	push   %ebp
f0106068:	89 e5                	mov    %esp,%ebp
f010606a:	57                   	push   %edi
f010606b:	56                   	push   %esi
f010606c:	53                   	push   %ebx
f010606d:	83 ec 4c             	sub    $0x4c,%esp
f0106070:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106073:	83 3e 00             	cmpl   $0x0,(%esi)
f0106076:	74 18                	je     f0106090 <spin_unlock+0x29>
f0106078:	8b 5e 08             	mov    0x8(%esi),%ebx
f010607b:	e8 dc fc ff ff       	call   f0105d5c <cpunum>
f0106080:	6b c0 74             	imul   $0x74,%eax,%eax
f0106083:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106088:	39 c3                	cmp    %eax,%ebx
f010608a:	0f 84 a5 00 00 00    	je     f0106135 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106090:	83 ec 04             	sub    $0x4,%esp
f0106093:	6a 28                	push   $0x28
f0106095:	8d 46 0c             	lea    0xc(%esi),%eax
f0106098:	50                   	push   %eax
f0106099:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010609c:	53                   	push   %ebx
f010609d:	e8 e8 f6 ff ff       	call   f010578a <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01060a2:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01060a5:	0f b6 38             	movzbl (%eax),%edi
f01060a8:	8b 76 04             	mov    0x4(%esi),%esi
f01060ab:	e8 ac fc ff ff       	call   f0105d5c <cpunum>
f01060b0:	57                   	push   %edi
f01060b1:	56                   	push   %esi
f01060b2:	50                   	push   %eax
f01060b3:	68 d4 82 10 f0       	push   $0xf01082d4
f01060b8:	e8 15 da ff ff       	call   f0103ad2 <cprintf>
f01060bd:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01060c0:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01060c3:	eb 54                	jmp    f0106119 <spin_unlock+0xb2>
f01060c5:	83 ec 08             	sub    $0x8,%esp
f01060c8:	57                   	push   %edi
f01060c9:	50                   	push   %eax
f01060ca:	e8 d3 eb ff ff       	call   f0104ca2 <debuginfo_eip>
f01060cf:	83 c4 10             	add    $0x10,%esp
f01060d2:	85 c0                	test   %eax,%eax
f01060d4:	78 27                	js     f01060fd <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01060d6:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01060d8:	83 ec 04             	sub    $0x4,%esp
f01060db:	89 c2                	mov    %eax,%edx
f01060dd:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01060e0:	52                   	push   %edx
f01060e1:	ff 75 b0             	pushl  -0x50(%ebp)
f01060e4:	ff 75 b4             	pushl  -0x4c(%ebp)
f01060e7:	ff 75 ac             	pushl  -0x54(%ebp)
f01060ea:	ff 75 a8             	pushl  -0x58(%ebp)
f01060ed:	50                   	push   %eax
f01060ee:	68 1c 83 10 f0       	push   $0xf010831c
f01060f3:	e8 da d9 ff ff       	call   f0103ad2 <cprintf>
f01060f8:	83 c4 20             	add    $0x20,%esp
f01060fb:	eb 12                	jmp    f010610f <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01060fd:	83 ec 08             	sub    $0x8,%esp
f0106100:	ff 36                	pushl  (%esi)
f0106102:	68 33 83 10 f0       	push   $0xf0108333
f0106107:	e8 c6 d9 ff ff       	call   f0103ad2 <cprintf>
f010610c:	83 c4 10             	add    $0x10,%esp
f010610f:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106112:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106115:	39 c3                	cmp    %eax,%ebx
f0106117:	74 08                	je     f0106121 <spin_unlock+0xba>
f0106119:	89 de                	mov    %ebx,%esi
f010611b:	8b 03                	mov    (%ebx),%eax
f010611d:	85 c0                	test   %eax,%eax
f010611f:	75 a4                	jne    f01060c5 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106121:	83 ec 04             	sub    $0x4,%esp
f0106124:	68 3b 83 10 f0       	push   $0xf010833b
f0106129:	6a 67                	push   $0x67
f010612b:	68 0c 83 10 f0       	push   $0xf010830c
f0106130:	e8 5f 9f ff ff       	call   f0100094 <_panic>
	}

	lk->pcs[0] = 0;
f0106135:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010613c:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106143:	b8 00 00 00 00       	mov    $0x0,%eax
f0106148:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010614b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010614e:	5b                   	pop    %ebx
f010614f:	5e                   	pop    %esi
f0106150:	5f                   	pop    %edi
f0106151:	5d                   	pop    %ebp
f0106152:	c3                   	ret    
f0106153:	66 90                	xchg   %ax,%ax
f0106155:	66 90                	xchg   %ax,%ax
f0106157:	66 90                	xchg   %ax,%ax
f0106159:	66 90                	xchg   %ax,%ax
f010615b:	66 90                	xchg   %ax,%ax
f010615d:	66 90                	xchg   %ax,%ax
f010615f:	90                   	nop

f0106160 <__udivdi3>:
f0106160:	55                   	push   %ebp
f0106161:	57                   	push   %edi
f0106162:	56                   	push   %esi
f0106163:	53                   	push   %ebx
f0106164:	83 ec 1c             	sub    $0x1c,%esp
f0106167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010616b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010616f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106173:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106177:	85 f6                	test   %esi,%esi
f0106179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010617d:	89 ca                	mov    %ecx,%edx
f010617f:	89 f8                	mov    %edi,%eax
f0106181:	75 3d                	jne    f01061c0 <__udivdi3+0x60>
f0106183:	39 cf                	cmp    %ecx,%edi
f0106185:	0f 87 c5 00 00 00    	ja     f0106250 <__udivdi3+0xf0>
f010618b:	85 ff                	test   %edi,%edi
f010618d:	89 fd                	mov    %edi,%ebp
f010618f:	75 0b                	jne    f010619c <__udivdi3+0x3c>
f0106191:	b8 01 00 00 00       	mov    $0x1,%eax
f0106196:	31 d2                	xor    %edx,%edx
f0106198:	f7 f7                	div    %edi
f010619a:	89 c5                	mov    %eax,%ebp
f010619c:	89 c8                	mov    %ecx,%eax
f010619e:	31 d2                	xor    %edx,%edx
f01061a0:	f7 f5                	div    %ebp
f01061a2:	89 c1                	mov    %eax,%ecx
f01061a4:	89 d8                	mov    %ebx,%eax
f01061a6:	89 cf                	mov    %ecx,%edi
f01061a8:	f7 f5                	div    %ebp
f01061aa:	89 c3                	mov    %eax,%ebx
f01061ac:	89 d8                	mov    %ebx,%eax
f01061ae:	89 fa                	mov    %edi,%edx
f01061b0:	83 c4 1c             	add    $0x1c,%esp
f01061b3:	5b                   	pop    %ebx
f01061b4:	5e                   	pop    %esi
f01061b5:	5f                   	pop    %edi
f01061b6:	5d                   	pop    %ebp
f01061b7:	c3                   	ret    
f01061b8:	90                   	nop
f01061b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061c0:	39 ce                	cmp    %ecx,%esi
f01061c2:	77 74                	ja     f0106238 <__udivdi3+0xd8>
f01061c4:	0f bd fe             	bsr    %esi,%edi
f01061c7:	83 f7 1f             	xor    $0x1f,%edi
f01061ca:	0f 84 98 00 00 00    	je     f0106268 <__udivdi3+0x108>
f01061d0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01061d5:	89 f9                	mov    %edi,%ecx
f01061d7:	89 c5                	mov    %eax,%ebp
f01061d9:	29 fb                	sub    %edi,%ebx
f01061db:	d3 e6                	shl    %cl,%esi
f01061dd:	89 d9                	mov    %ebx,%ecx
f01061df:	d3 ed                	shr    %cl,%ebp
f01061e1:	89 f9                	mov    %edi,%ecx
f01061e3:	d3 e0                	shl    %cl,%eax
f01061e5:	09 ee                	or     %ebp,%esi
f01061e7:	89 d9                	mov    %ebx,%ecx
f01061e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061ed:	89 d5                	mov    %edx,%ebp
f01061ef:	8b 44 24 08          	mov    0x8(%esp),%eax
f01061f3:	d3 ed                	shr    %cl,%ebp
f01061f5:	89 f9                	mov    %edi,%ecx
f01061f7:	d3 e2                	shl    %cl,%edx
f01061f9:	89 d9                	mov    %ebx,%ecx
f01061fb:	d3 e8                	shr    %cl,%eax
f01061fd:	09 c2                	or     %eax,%edx
f01061ff:	89 d0                	mov    %edx,%eax
f0106201:	89 ea                	mov    %ebp,%edx
f0106203:	f7 f6                	div    %esi
f0106205:	89 d5                	mov    %edx,%ebp
f0106207:	89 c3                	mov    %eax,%ebx
f0106209:	f7 64 24 0c          	mull   0xc(%esp)
f010620d:	39 d5                	cmp    %edx,%ebp
f010620f:	72 10                	jb     f0106221 <__udivdi3+0xc1>
f0106211:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106215:	89 f9                	mov    %edi,%ecx
f0106217:	d3 e6                	shl    %cl,%esi
f0106219:	39 c6                	cmp    %eax,%esi
f010621b:	73 07                	jae    f0106224 <__udivdi3+0xc4>
f010621d:	39 d5                	cmp    %edx,%ebp
f010621f:	75 03                	jne    f0106224 <__udivdi3+0xc4>
f0106221:	83 eb 01             	sub    $0x1,%ebx
f0106224:	31 ff                	xor    %edi,%edi
f0106226:	89 d8                	mov    %ebx,%eax
f0106228:	89 fa                	mov    %edi,%edx
f010622a:	83 c4 1c             	add    $0x1c,%esp
f010622d:	5b                   	pop    %ebx
f010622e:	5e                   	pop    %esi
f010622f:	5f                   	pop    %edi
f0106230:	5d                   	pop    %ebp
f0106231:	c3                   	ret    
f0106232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106238:	31 ff                	xor    %edi,%edi
f010623a:	31 db                	xor    %ebx,%ebx
f010623c:	89 d8                	mov    %ebx,%eax
f010623e:	89 fa                	mov    %edi,%edx
f0106240:	83 c4 1c             	add    $0x1c,%esp
f0106243:	5b                   	pop    %ebx
f0106244:	5e                   	pop    %esi
f0106245:	5f                   	pop    %edi
f0106246:	5d                   	pop    %ebp
f0106247:	c3                   	ret    
f0106248:	90                   	nop
f0106249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106250:	89 d8                	mov    %ebx,%eax
f0106252:	f7 f7                	div    %edi
f0106254:	31 ff                	xor    %edi,%edi
f0106256:	89 c3                	mov    %eax,%ebx
f0106258:	89 d8                	mov    %ebx,%eax
f010625a:	89 fa                	mov    %edi,%edx
f010625c:	83 c4 1c             	add    $0x1c,%esp
f010625f:	5b                   	pop    %ebx
f0106260:	5e                   	pop    %esi
f0106261:	5f                   	pop    %edi
f0106262:	5d                   	pop    %ebp
f0106263:	c3                   	ret    
f0106264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106268:	39 ce                	cmp    %ecx,%esi
f010626a:	72 0c                	jb     f0106278 <__udivdi3+0x118>
f010626c:	31 db                	xor    %ebx,%ebx
f010626e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106272:	0f 87 34 ff ff ff    	ja     f01061ac <__udivdi3+0x4c>
f0106278:	bb 01 00 00 00       	mov    $0x1,%ebx
f010627d:	e9 2a ff ff ff       	jmp    f01061ac <__udivdi3+0x4c>
f0106282:	66 90                	xchg   %ax,%ax
f0106284:	66 90                	xchg   %ax,%ax
f0106286:	66 90                	xchg   %ax,%ax
f0106288:	66 90                	xchg   %ax,%ax
f010628a:	66 90                	xchg   %ax,%ax
f010628c:	66 90                	xchg   %ax,%ax
f010628e:	66 90                	xchg   %ax,%ax

f0106290 <__umoddi3>:
f0106290:	55                   	push   %ebp
f0106291:	57                   	push   %edi
f0106292:	56                   	push   %esi
f0106293:	53                   	push   %ebx
f0106294:	83 ec 1c             	sub    $0x1c,%esp
f0106297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010629b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010629f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01062a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01062a7:	85 d2                	test   %edx,%edx
f01062a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01062ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01062b1:	89 f3                	mov    %esi,%ebx
f01062b3:	89 3c 24             	mov    %edi,(%esp)
f01062b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01062ba:	75 1c                	jne    f01062d8 <__umoddi3+0x48>
f01062bc:	39 f7                	cmp    %esi,%edi
f01062be:	76 50                	jbe    f0106310 <__umoddi3+0x80>
f01062c0:	89 c8                	mov    %ecx,%eax
f01062c2:	89 f2                	mov    %esi,%edx
f01062c4:	f7 f7                	div    %edi
f01062c6:	89 d0                	mov    %edx,%eax
f01062c8:	31 d2                	xor    %edx,%edx
f01062ca:	83 c4 1c             	add    $0x1c,%esp
f01062cd:	5b                   	pop    %ebx
f01062ce:	5e                   	pop    %esi
f01062cf:	5f                   	pop    %edi
f01062d0:	5d                   	pop    %ebp
f01062d1:	c3                   	ret    
f01062d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01062d8:	39 f2                	cmp    %esi,%edx
f01062da:	89 d0                	mov    %edx,%eax
f01062dc:	77 52                	ja     f0106330 <__umoddi3+0xa0>
f01062de:	0f bd ea             	bsr    %edx,%ebp
f01062e1:	83 f5 1f             	xor    $0x1f,%ebp
f01062e4:	75 5a                	jne    f0106340 <__umoddi3+0xb0>
f01062e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01062ea:	0f 82 e0 00 00 00    	jb     f01063d0 <__umoddi3+0x140>
f01062f0:	39 0c 24             	cmp    %ecx,(%esp)
f01062f3:	0f 86 d7 00 00 00    	jbe    f01063d0 <__umoddi3+0x140>
f01062f9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01062fd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106301:	83 c4 1c             	add    $0x1c,%esp
f0106304:	5b                   	pop    %ebx
f0106305:	5e                   	pop    %esi
f0106306:	5f                   	pop    %edi
f0106307:	5d                   	pop    %ebp
f0106308:	c3                   	ret    
f0106309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106310:	85 ff                	test   %edi,%edi
f0106312:	89 fd                	mov    %edi,%ebp
f0106314:	75 0b                	jne    f0106321 <__umoddi3+0x91>
f0106316:	b8 01 00 00 00       	mov    $0x1,%eax
f010631b:	31 d2                	xor    %edx,%edx
f010631d:	f7 f7                	div    %edi
f010631f:	89 c5                	mov    %eax,%ebp
f0106321:	89 f0                	mov    %esi,%eax
f0106323:	31 d2                	xor    %edx,%edx
f0106325:	f7 f5                	div    %ebp
f0106327:	89 c8                	mov    %ecx,%eax
f0106329:	f7 f5                	div    %ebp
f010632b:	89 d0                	mov    %edx,%eax
f010632d:	eb 99                	jmp    f01062c8 <__umoddi3+0x38>
f010632f:	90                   	nop
f0106330:	89 c8                	mov    %ecx,%eax
f0106332:	89 f2                	mov    %esi,%edx
f0106334:	83 c4 1c             	add    $0x1c,%esp
f0106337:	5b                   	pop    %ebx
f0106338:	5e                   	pop    %esi
f0106339:	5f                   	pop    %edi
f010633a:	5d                   	pop    %ebp
f010633b:	c3                   	ret    
f010633c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106340:	8b 34 24             	mov    (%esp),%esi
f0106343:	bf 20 00 00 00       	mov    $0x20,%edi
f0106348:	89 e9                	mov    %ebp,%ecx
f010634a:	29 ef                	sub    %ebp,%edi
f010634c:	d3 e0                	shl    %cl,%eax
f010634e:	89 f9                	mov    %edi,%ecx
f0106350:	89 f2                	mov    %esi,%edx
f0106352:	d3 ea                	shr    %cl,%edx
f0106354:	89 e9                	mov    %ebp,%ecx
f0106356:	09 c2                	or     %eax,%edx
f0106358:	89 d8                	mov    %ebx,%eax
f010635a:	89 14 24             	mov    %edx,(%esp)
f010635d:	89 f2                	mov    %esi,%edx
f010635f:	d3 e2                	shl    %cl,%edx
f0106361:	89 f9                	mov    %edi,%ecx
f0106363:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106367:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010636b:	d3 e8                	shr    %cl,%eax
f010636d:	89 e9                	mov    %ebp,%ecx
f010636f:	89 c6                	mov    %eax,%esi
f0106371:	d3 e3                	shl    %cl,%ebx
f0106373:	89 f9                	mov    %edi,%ecx
f0106375:	89 d0                	mov    %edx,%eax
f0106377:	d3 e8                	shr    %cl,%eax
f0106379:	89 e9                	mov    %ebp,%ecx
f010637b:	09 d8                	or     %ebx,%eax
f010637d:	89 d3                	mov    %edx,%ebx
f010637f:	89 f2                	mov    %esi,%edx
f0106381:	f7 34 24             	divl   (%esp)
f0106384:	89 d6                	mov    %edx,%esi
f0106386:	d3 e3                	shl    %cl,%ebx
f0106388:	f7 64 24 04          	mull   0x4(%esp)
f010638c:	39 d6                	cmp    %edx,%esi
f010638e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106392:	89 d1                	mov    %edx,%ecx
f0106394:	89 c3                	mov    %eax,%ebx
f0106396:	72 08                	jb     f01063a0 <__umoddi3+0x110>
f0106398:	75 11                	jne    f01063ab <__umoddi3+0x11b>
f010639a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010639e:	73 0b                	jae    f01063ab <__umoddi3+0x11b>
f01063a0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01063a4:	1b 14 24             	sbb    (%esp),%edx
f01063a7:	89 d1                	mov    %edx,%ecx
f01063a9:	89 c3                	mov    %eax,%ebx
f01063ab:	8b 54 24 08          	mov    0x8(%esp),%edx
f01063af:	29 da                	sub    %ebx,%edx
f01063b1:	19 ce                	sbb    %ecx,%esi
f01063b3:	89 f9                	mov    %edi,%ecx
f01063b5:	89 f0                	mov    %esi,%eax
f01063b7:	d3 e0                	shl    %cl,%eax
f01063b9:	89 e9                	mov    %ebp,%ecx
f01063bb:	d3 ea                	shr    %cl,%edx
f01063bd:	89 e9                	mov    %ebp,%ecx
f01063bf:	d3 ee                	shr    %cl,%esi
f01063c1:	09 d0                	or     %edx,%eax
f01063c3:	89 f2                	mov    %esi,%edx
f01063c5:	83 c4 1c             	add    $0x1c,%esp
f01063c8:	5b                   	pop    %ebx
f01063c9:	5e                   	pop    %esi
f01063ca:	5f                   	pop    %edi
f01063cb:	5d                   	pop    %ebp
f01063cc:	c3                   	ret    
f01063cd:	8d 76 00             	lea    0x0(%esi),%esi
f01063d0:	29 f9                	sub    %edi,%ecx
f01063d2:	19 d6                	sbb    %edx,%esi
f01063d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01063d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01063dc:	e9 18 ff ff ff       	jmp    f01062f9 <__umoddi3+0x69>
