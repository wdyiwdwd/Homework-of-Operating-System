
obj/user/softint：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800045:	e8 c6 00 00 00       	call   800110 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	c1 e0 07             	shl    $0x7,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7e 17                	jle    800108 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	50                   	push   %eax
  8000f5:	6a 03                	push   $0x3
  8000f7:	68 aa 0f 80 00       	push   $0x800faa
  8000fc:	6a 23                	push   $0x23
  8000fe:	68 c7 0f 80 00       	push   $0x800fc7
  800103:	e8 15 02 00 00       	call   80031d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_yield>:

void
sys_yield(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	be 00 00 00 00       	mov    $0x0,%esi
  80015c:	b8 04 00 00 00       	mov    $0x4,%eax
  800161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016a:	89 f7                	mov    %esi,%edi
  80016c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 17                	jle    800189 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	50                   	push   %eax
  800176:	6a 04                	push   $0x4
  800178:	68 aa 0f 80 00       	push   $0x800faa
  80017d:	6a 23                	push   $0x23
  80017f:	68 c7 0f 80 00       	push   $0x800fc7
  800184:	e8 94 01 00 00       	call   80031d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	b8 05 00 00 00       	mov    $0x5,%eax
  80019f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ab:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7e 17                	jle    8001cb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	6a 05                	push   $0x5
  8001ba:	68 aa 0f 80 00       	push   $0x800faa
  8001bf:	6a 23                	push   $0x23
  8001c1:	68 c7 0f 80 00       	push   $0x800fc7
  8001c6:	e8 52 01 00 00       	call   80031d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 df                	mov    %ebx,%edi
  8001ee:	89 de                	mov    %ebx,%esi
  8001f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 17                	jle    80020d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	50                   	push   %eax
  8001fa:	6a 06                	push   $0x6
  8001fc:	68 aa 0f 80 00       	push   $0x800faa
  800201:	6a 23                	push   $0x23
  800203:	68 c7 0f 80 00       	push   $0x800fc7
  800208:	e8 10 01 00 00       	call   80031d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	b8 08 00 00 00       	mov    $0x8,%eax
  800228:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	89 df                	mov    %ebx,%edi
  800230:	89 de                	mov    %ebx,%esi
  800232:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7e 17                	jle    80024f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	50                   	push   %eax
  80023c:	6a 08                	push   $0x8
  80023e:	68 aa 0f 80 00       	push   $0x800faa
  800243:	6a 23                	push   $0x23
  800245:	68 c7 0f 80 00       	push   $0x800fc7
  80024a:	e8 ce 00 00 00       	call   80031d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	b8 09 00 00 00       	mov    $0x9,%eax
  80026a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	89 df                	mov    %ebx,%edi
  800272:	89 de                	mov    %ebx,%esi
  800274:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7e 17                	jle    800291 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	50                   	push   %eax
  80027e:	6a 09                	push   $0x9
  800280:	68 aa 0f 80 00       	push   $0x800faa
  800285:	6a 23                	push   $0x23
  800287:	68 c7 0f 80 00       	push   $0x800fc7
  80028c:	e8 8c 00 00 00       	call   80031d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029f:	be 00 00 00 00       	mov    $0x0,%esi
  8002a4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ca:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d2:	89 cb                	mov    %ecx,%ebx
  8002d4:	89 cf                	mov    %ecx,%edi
  8002d6:	89 ce                	mov    %ecx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0c                	push   $0xc
  8002e4:	68 aa 0f 80 00       	push   $0x800faa
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 c7 0f 80 00       	push   $0x800fc7
  8002f0:	e8 28 00 00 00       	call   80031d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_change_pr>:

int
sys_change_pr(int pr)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	b9 00 00 00 00       	mov    $0x0,%ecx
  800308:	b8 0d 00 00 00       	mov    $0xd,%eax
  80030d:	8b 55 08             	mov    0x8(%ebp),%edx
  800310:	89 cb                	mov    %ecx,%ebx
  800312:	89 cf                	mov    %ecx,%edi
  800314:	89 ce                	mov    %ecx,%esi
  800316:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800322:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800325:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80032b:	e8 e0 fd ff ff       	call   800110 <sys_getenvid>
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	ff 75 0c             	pushl  0xc(%ebp)
  800336:	ff 75 08             	pushl  0x8(%ebp)
  800339:	56                   	push   %esi
  80033a:	50                   	push   %eax
  80033b:	68 d8 0f 80 00       	push   $0x800fd8
  800340:	e8 b1 00 00 00       	call   8003f6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800345:	83 c4 18             	add    $0x18,%esp
  800348:	53                   	push   %ebx
  800349:	ff 75 10             	pushl  0x10(%ebp)
  80034c:	e8 54 00 00 00       	call   8003a5 <vcprintf>
	cprintf("\n");
  800351:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800358:	e8 99 00 00 00       	call   8003f6 <cprintf>
  80035d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800360:	cc                   	int3   
  800361:	eb fd                	jmp    800360 <_panic+0x43>

00800363 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	53                   	push   %ebx
  800367:	83 ec 04             	sub    $0x4,%esp
  80036a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80036d:	8b 13                	mov    (%ebx),%edx
  80036f:	8d 42 01             	lea    0x1(%edx),%eax
  800372:	89 03                	mov    %eax,(%ebx)
  800374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800377:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80037b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800380:	75 1a                	jne    80039c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	68 ff 00 00 00       	push   $0xff
  80038a:	8d 43 08             	lea    0x8(%ebx),%eax
  80038d:	50                   	push   %eax
  80038e:	e8 ff fc ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  800393:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800399:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80039c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ae:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b5:	00 00 00 
	b.cnt = 0;
  8003b8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003bf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c2:	ff 75 0c             	pushl  0xc(%ebp)
  8003c5:	ff 75 08             	pushl  0x8(%ebp)
  8003c8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ce:	50                   	push   %eax
  8003cf:	68 63 03 80 00       	push   $0x800363
  8003d4:	e8 54 01 00 00       	call   80052d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d9:	83 c4 08             	add    $0x8,%esp
  8003dc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e8:	50                   	push   %eax
  8003e9:	e8 a4 fc ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  8003ee:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f4:	c9                   	leave  
  8003f5:	c3                   	ret    

008003f6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ff:	50                   	push   %eax
  800400:	ff 75 08             	pushl  0x8(%ebp)
  800403:	e8 9d ff ff ff       	call   8003a5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800408:	c9                   	leave  
  800409:	c3                   	ret    

0080040a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	57                   	push   %edi
  80040e:	56                   	push   %esi
  80040f:	53                   	push   %ebx
  800410:	83 ec 1c             	sub    $0x1c,%esp
  800413:	89 c7                	mov    %eax,%edi
  800415:	89 d6                	mov    %edx,%esi
  800417:	8b 45 08             	mov    0x8(%ebp),%eax
  80041a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800420:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800423:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800426:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80042e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800431:	39 d3                	cmp    %edx,%ebx
  800433:	72 05                	jb     80043a <printnum+0x30>
  800435:	39 45 10             	cmp    %eax,0x10(%ebp)
  800438:	77 45                	ja     80047f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80043a:	83 ec 0c             	sub    $0xc,%esp
  80043d:	ff 75 18             	pushl  0x18(%ebp)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800446:	53                   	push   %ebx
  800447:	ff 75 10             	pushl  0x10(%ebp)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800450:	ff 75 e0             	pushl  -0x20(%ebp)
  800453:	ff 75 dc             	pushl  -0x24(%ebp)
  800456:	ff 75 d8             	pushl  -0x28(%ebp)
  800459:	e8 b2 08 00 00       	call   800d10 <__udivdi3>
  80045e:	83 c4 18             	add    $0x18,%esp
  800461:	52                   	push   %edx
  800462:	50                   	push   %eax
  800463:	89 f2                	mov    %esi,%edx
  800465:	89 f8                	mov    %edi,%eax
  800467:	e8 9e ff ff ff       	call   80040a <printnum>
  80046c:	83 c4 20             	add    $0x20,%esp
  80046f:	eb 18                	jmp    800489 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	56                   	push   %esi
  800475:	ff 75 18             	pushl  0x18(%ebp)
  800478:	ff d7                	call   *%edi
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	eb 03                	jmp    800482 <printnum+0x78>
  80047f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800482:	83 eb 01             	sub    $0x1,%ebx
  800485:	85 db                	test   %ebx,%ebx
  800487:	7f e8                	jg     800471 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	56                   	push   %esi
  80048d:	83 ec 04             	sub    $0x4,%esp
  800490:	ff 75 e4             	pushl  -0x1c(%ebp)
  800493:	ff 75 e0             	pushl  -0x20(%ebp)
  800496:	ff 75 dc             	pushl  -0x24(%ebp)
  800499:	ff 75 d8             	pushl  -0x28(%ebp)
  80049c:	e8 9f 09 00 00       	call   800e40 <__umoddi3>
  8004a1:	83 c4 14             	add    $0x14,%esp
  8004a4:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  8004ab:	50                   	push   %eax
  8004ac:	ff d7                	call   *%edi
}
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b4:	5b                   	pop    %ebx
  8004b5:	5e                   	pop    %esi
  8004b6:	5f                   	pop    %edi
  8004b7:	5d                   	pop    %ebp
  8004b8:	c3                   	ret    

008004b9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004bc:	83 fa 01             	cmp    $0x1,%edx
  8004bf:	7e 0e                	jle    8004cf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c1:	8b 10                	mov    (%eax),%edx
  8004c3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c6:	89 08                	mov    %ecx,(%eax)
  8004c8:	8b 02                	mov    (%edx),%eax
  8004ca:	8b 52 04             	mov    0x4(%edx),%edx
  8004cd:	eb 22                	jmp    8004f1 <getuint+0x38>
	else if (lflag)
  8004cf:	85 d2                	test   %edx,%edx
  8004d1:	74 10                	je     8004e3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d8:	89 08                	mov    %ecx,(%eax)
  8004da:	8b 02                	mov    (%edx),%eax
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e1:	eb 0e                	jmp    8004f1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e3:	8b 10                	mov    (%eax),%edx
  8004e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e8:	89 08                	mov    %ecx,(%eax)
  8004ea:	8b 02                	mov    (%edx),%eax
  8004ec:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f1:	5d                   	pop    %ebp
  8004f2:	c3                   	ret    

008004f3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004fd:	8b 10                	mov    (%eax),%edx
  8004ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800502:	73 0a                	jae    80050e <sprintputch+0x1b>
		*b->buf++ = ch;
  800504:	8d 4a 01             	lea    0x1(%edx),%ecx
  800507:	89 08                	mov    %ecx,(%eax)
  800509:	8b 45 08             	mov    0x8(%ebp),%eax
  80050c:	88 02                	mov    %al,(%edx)
}
  80050e:	5d                   	pop    %ebp
  80050f:	c3                   	ret    

00800510 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800516:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800519:	50                   	push   %eax
  80051a:	ff 75 10             	pushl  0x10(%ebp)
  80051d:	ff 75 0c             	pushl  0xc(%ebp)
  800520:	ff 75 08             	pushl  0x8(%ebp)
  800523:	e8 05 00 00 00       	call   80052d <vprintfmt>
	va_end(ap);
}
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	c9                   	leave  
  80052c:	c3                   	ret    

0080052d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	57                   	push   %edi
  800531:	56                   	push   %esi
  800532:	53                   	push   %ebx
  800533:	83 ec 2c             	sub    $0x2c,%esp
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053f:	eb 1d                	jmp    80055e <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800541:	85 c0                	test   %eax,%eax
  800543:	75 0f                	jne    800554 <vprintfmt+0x27>
				csa = 0x0700;
  800545:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80054c:	07 00 00 
				return;
  80054f:	e9 c4 03 00 00       	jmp    800918 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	53                   	push   %ebx
  800558:	50                   	push   %eax
  800559:	ff d6                	call   *%esi
  80055b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055e:	83 c7 01             	add    $0x1,%edi
  800561:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800565:	83 f8 25             	cmp    $0x25,%eax
  800568:	75 d7                	jne    800541 <vprintfmt+0x14>
  80056a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800575:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80057c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800583:	ba 00 00 00 00       	mov    $0x0,%edx
  800588:	eb 07                	jmp    800591 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80058d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800591:	8d 47 01             	lea    0x1(%edi),%eax
  800594:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800597:	0f b6 07             	movzbl (%edi),%eax
  80059a:	0f b6 c8             	movzbl %al,%ecx
  80059d:	83 e8 23             	sub    $0x23,%eax
  8005a0:	3c 55                	cmp    $0x55,%al
  8005a2:	0f 87 55 03 00 00    	ja     8008fd <vprintfmt+0x3d0>
  8005a8:	0f b6 c0             	movzbl %al,%eax
  8005ab:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b9:	eb d6                	jmp    800591 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005be:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005cd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005d0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005d3:	83 fa 09             	cmp    $0x9,%edx
  8005d6:	77 39                	ja     800611 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005db:	eb e9                	jmp    8005c6 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 48 04             	lea    0x4(%eax),%ecx
  8005e3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ee:	eb 27                	jmp    800617 <vprintfmt+0xea>
  8005f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fa:	0f 49 c8             	cmovns %eax,%ecx
  8005fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800603:	eb 8c                	jmp    800591 <vprintfmt+0x64>
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800608:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060f:	eb 80                	jmp    800591 <vprintfmt+0x64>
  800611:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800614:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800617:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061b:	0f 89 70 ff ff ff    	jns    800591 <vprintfmt+0x64>
				width = precision, precision = -1;
  800621:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800624:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800627:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80062e:	e9 5e ff ff ff       	jmp    800591 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800633:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800639:	e9 53 ff ff ff       	jmp    800591 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	ff 30                	pushl  (%eax)
  80064d:	ff d6                	call   *%esi
			break;
  80064f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800655:	e9 04 ff ff ff       	jmp    80055e <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	99                   	cltd   
  800666:	31 d0                	xor    %edx,%eax
  800668:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066a:	83 f8 08             	cmp    $0x8,%eax
  80066d:	7f 0b                	jg     80067a <vprintfmt+0x14d>
  80066f:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800676:	85 d2                	test   %edx,%edx
  800678:	75 18                	jne    800692 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80067a:	50                   	push   %eax
  80067b:	68 16 10 80 00       	push   $0x801016
  800680:	53                   	push   %ebx
  800681:	56                   	push   %esi
  800682:	e8 89 fe ff ff       	call   800510 <printfmt>
  800687:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80068d:	e9 cc fe ff ff       	jmp    80055e <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800692:	52                   	push   %edx
  800693:	68 1f 10 80 00       	push   $0x80101f
  800698:	53                   	push   %ebx
  800699:	56                   	push   %esi
  80069a:	e8 71 fe ff ff       	call   800510 <printfmt>
  80069f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a5:	e9 b4 fe ff ff       	jmp    80055e <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 50 04             	lea    0x4(%eax),%edx
  8006b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b5:	85 ff                	test   %edi,%edi
  8006b7:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  8006bc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c3:	0f 8e 94 00 00 00    	jle    80075d <vprintfmt+0x230>
  8006c9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006cd:	0f 84 98 00 00 00    	je     80076b <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d9:	57                   	push   %edi
  8006da:	e8 c1 02 00 00       	call   8009a0 <strnlen>
  8006df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e2:	29 c1                	sub    %eax,%ecx
  8006e4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ea:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f6:	eb 0f                	jmp    800707 <vprintfmt+0x1da>
					putch(padc, putdat);
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ff:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800701:	83 ef 01             	sub    $0x1,%edi
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	85 ff                	test   %edi,%edi
  800709:	7f ed                	jg     8006f8 <vprintfmt+0x1cb>
  80070b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800711:	85 c9                	test   %ecx,%ecx
  800713:	b8 00 00 00 00       	mov    $0x0,%eax
  800718:	0f 49 c1             	cmovns %ecx,%eax
  80071b:	29 c1                	sub    %eax,%ecx
  80071d:	89 75 08             	mov    %esi,0x8(%ebp)
  800720:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800723:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800726:	89 cb                	mov    %ecx,%ebx
  800728:	eb 4d                	jmp    800777 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072e:	74 1b                	je     80074b <vprintfmt+0x21e>
  800730:	0f be c0             	movsbl %al,%eax
  800733:	83 e8 20             	sub    $0x20,%eax
  800736:	83 f8 5e             	cmp    $0x5e,%eax
  800739:	76 10                	jbe    80074b <vprintfmt+0x21e>
					putch('?', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	ff 75 0c             	pushl  0xc(%ebp)
  800741:	6a 3f                	push   $0x3f
  800743:	ff 55 08             	call   *0x8(%ebp)
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	eb 0d                	jmp    800758 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	52                   	push   %edx
  800752:	ff 55 08             	call   *0x8(%ebp)
  800755:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800758:	83 eb 01             	sub    $0x1,%ebx
  80075b:	eb 1a                	jmp    800777 <vprintfmt+0x24a>
  80075d:	89 75 08             	mov    %esi,0x8(%ebp)
  800760:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800763:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800766:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800769:	eb 0c                	jmp    800777 <vprintfmt+0x24a>
  80076b:	89 75 08             	mov    %esi,0x8(%ebp)
  80076e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800771:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800774:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800777:	83 c7 01             	add    $0x1,%edi
  80077a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077e:	0f be d0             	movsbl %al,%edx
  800781:	85 d2                	test   %edx,%edx
  800783:	74 23                	je     8007a8 <vprintfmt+0x27b>
  800785:	85 f6                	test   %esi,%esi
  800787:	78 a1                	js     80072a <vprintfmt+0x1fd>
  800789:	83 ee 01             	sub    $0x1,%esi
  80078c:	79 9c                	jns    80072a <vprintfmt+0x1fd>
  80078e:	89 df                	mov    %ebx,%edi
  800790:	8b 75 08             	mov    0x8(%ebp),%esi
  800793:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800796:	eb 18                	jmp    8007b0 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	53                   	push   %ebx
  80079c:	6a 20                	push   $0x20
  80079e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a0:	83 ef 01             	sub    $0x1,%edi
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	eb 08                	jmp    8007b0 <vprintfmt+0x283>
  8007a8:	89 df                	mov    %ebx,%edi
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b0:	85 ff                	test   %edi,%edi
  8007b2:	7f e4                	jg     800798 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b7:	e9 a2 fd ff ff       	jmp    80055e <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007bc:	83 fa 01             	cmp    $0x1,%edx
  8007bf:	7e 16                	jle    8007d7 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 50 08             	lea    0x8(%eax),%edx
  8007c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ca:	8b 50 04             	mov    0x4(%eax),%edx
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d5:	eb 32                	jmp    800809 <vprintfmt+0x2dc>
	else if (lflag)
  8007d7:	85 d2                	test   %edx,%edx
  8007d9:	74 18                	je     8007f3 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 50 04             	lea    0x4(%eax),%edx
  8007e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e4:	8b 00                	mov    (%eax),%eax
  8007e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e9:	89 c1                	mov    %eax,%ecx
  8007eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f1:	eb 16                	jmp    800809 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 50 04             	lea    0x4(%eax),%edx
  8007f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fc:	8b 00                	mov    (%eax),%eax
  8007fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800801:	89 c1                	mov    %eax,%ecx
  800803:	c1 f9 1f             	sar    $0x1f,%ecx
  800806:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800809:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800814:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800818:	79 74                	jns    80088e <vprintfmt+0x361>
				putch('-', putdat);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	53                   	push   %ebx
  80081e:	6a 2d                	push   $0x2d
  800820:	ff d6                	call   *%esi
				num = -(long long) num;
  800822:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800825:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800828:	f7 d8                	neg    %eax
  80082a:	83 d2 00             	adc    $0x0,%edx
  80082d:	f7 da                	neg    %edx
  80082f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800832:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800837:	eb 55                	jmp    80088e <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800839:	8d 45 14             	lea    0x14(%ebp),%eax
  80083c:	e8 78 fc ff ff       	call   8004b9 <getuint>
			base = 10;
  800841:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800846:	eb 46                	jmp    80088e <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800848:	8d 45 14             	lea    0x14(%ebp),%eax
  80084b:	e8 69 fc ff ff       	call   8004b9 <getuint>
      base = 8;
  800850:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800855:	eb 37                	jmp    80088e <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	53                   	push   %ebx
  80085b:	6a 30                	push   $0x30
  80085d:	ff d6                	call   *%esi
			putch('x', putdat);
  80085f:	83 c4 08             	add    $0x8,%esp
  800862:	53                   	push   %ebx
  800863:	6a 78                	push   $0x78
  800865:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800867:	8b 45 14             	mov    0x14(%ebp),%eax
  80086a:	8d 50 04             	lea    0x4(%eax),%edx
  80086d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800870:	8b 00                	mov    (%eax),%eax
  800872:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800877:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80087a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80087f:	eb 0d                	jmp    80088e <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
  800884:	e8 30 fc ff ff       	call   8004b9 <getuint>
			base = 16;
  800889:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088e:	83 ec 0c             	sub    $0xc,%esp
  800891:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800895:	57                   	push   %edi
  800896:	ff 75 e0             	pushl  -0x20(%ebp)
  800899:	51                   	push   %ecx
  80089a:	52                   	push   %edx
  80089b:	50                   	push   %eax
  80089c:	89 da                	mov    %ebx,%edx
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	e8 65 fb ff ff       	call   80040a <printnum>
			break;
  8008a5:	83 c4 20             	add    $0x20,%esp
  8008a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ab:	e9 ae fc ff ff       	jmp    80055e <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b0:	83 ec 08             	sub    $0x8,%esp
  8008b3:	53                   	push   %ebx
  8008b4:	51                   	push   %ecx
  8008b5:	ff d6                	call   *%esi
			break;
  8008b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008bd:	e9 9c fc ff ff       	jmp    80055e <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c2:	83 fa 01             	cmp    $0x1,%edx
  8008c5:	7e 0d                	jle    8008d4 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 50 08             	lea    0x8(%eax),%edx
  8008cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d0:	8b 00                	mov    (%eax),%eax
  8008d2:	eb 1c                	jmp    8008f0 <vprintfmt+0x3c3>
	else if (lflag)
  8008d4:	85 d2                	test   %edx,%edx
  8008d6:	74 0d                	je     8008e5 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8d 50 04             	lea    0x4(%eax),%edx
  8008de:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e1:	8b 00                	mov    (%eax),%eax
  8008e3:	eb 0b                	jmp    8008f0 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8d 50 04             	lea    0x4(%eax),%edx
  8008eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ee:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8008f0:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8008f8:	e9 61 fc ff ff       	jmp    80055e <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	53                   	push   %ebx
  800901:	6a 25                	push   $0x25
  800903:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	eb 03                	jmp    80090d <vprintfmt+0x3e0>
  80090a:	83 ef 01             	sub    $0x1,%edi
  80090d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800911:	75 f7                	jne    80090a <vprintfmt+0x3dd>
  800913:	e9 46 fc ff ff       	jmp    80055e <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800918:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	83 ec 18             	sub    $0x18,%esp
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800933:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800936:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093d:	85 c0                	test   %eax,%eax
  80093f:	74 26                	je     800967 <vsnprintf+0x47>
  800941:	85 d2                	test   %edx,%edx
  800943:	7e 22                	jle    800967 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800945:	ff 75 14             	pushl  0x14(%ebp)
  800948:	ff 75 10             	pushl  0x10(%ebp)
  80094b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094e:	50                   	push   %eax
  80094f:	68 f3 04 80 00       	push   $0x8004f3
  800954:	e8 d4 fb ff ff       	call   80052d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800959:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800962:	83 c4 10             	add    $0x10,%esp
  800965:	eb 05                	jmp    80096c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800967:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800974:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800977:	50                   	push   %eax
  800978:	ff 75 10             	pushl  0x10(%ebp)
  80097b:	ff 75 0c             	pushl  0xc(%ebp)
  80097e:	ff 75 08             	pushl  0x8(%ebp)
  800981:	e8 9a ff ff ff       	call   800920 <vsnprintf>
	va_end(ap);

	return rc;
}
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
  800993:	eb 03                	jmp    800998 <strlen+0x10>
		n++;
  800995:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800998:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80099c:	75 f7                	jne    800995 <strlen+0xd>
		n++;
	return n;
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ae:	eb 03                	jmp    8009b3 <strnlen+0x13>
		n++;
  8009b0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b3:	39 c2                	cmp    %eax,%edx
  8009b5:	74 08                	je     8009bf <strnlen+0x1f>
  8009b7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009bb:	75 f3                	jne    8009b0 <strnlen+0x10>
  8009bd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	53                   	push   %ebx
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009cb:	89 c2                	mov    %eax,%edx
  8009cd:	83 c2 01             	add    $0x1,%edx
  8009d0:	83 c1 01             	add    $0x1,%ecx
  8009d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009d7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009da:	84 db                	test   %bl,%bl
  8009dc:	75 ef                	jne    8009cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009de:	5b                   	pop    %ebx
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	53                   	push   %ebx
  8009e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e8:	53                   	push   %ebx
  8009e9:	e8 9a ff ff ff       	call   800988 <strlen>
  8009ee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009f1:	ff 75 0c             	pushl  0xc(%ebp)
  8009f4:	01 d8                	add    %ebx,%eax
  8009f6:	50                   	push   %eax
  8009f7:	e8 c5 ff ff ff       	call   8009c1 <strcpy>
	return dst;
}
  8009fc:	89 d8                	mov    %ebx,%eax
  8009fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0e:	89 f3                	mov    %esi,%ebx
  800a10:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a13:	89 f2                	mov    %esi,%edx
  800a15:	eb 0f                	jmp    800a26 <strncpy+0x23>
		*dst++ = *src;
  800a17:	83 c2 01             	add    $0x1,%edx
  800a1a:	0f b6 01             	movzbl (%ecx),%eax
  800a1d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a20:	80 39 01             	cmpb   $0x1,(%ecx)
  800a23:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a26:	39 da                	cmp    %ebx,%edx
  800a28:	75 ed                	jne    800a17 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a2a:	89 f0                	mov    %esi,%eax
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 75 08             	mov    0x8(%ebp),%esi
  800a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3b:	8b 55 10             	mov    0x10(%ebp),%edx
  800a3e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a40:	85 d2                	test   %edx,%edx
  800a42:	74 21                	je     800a65 <strlcpy+0x35>
  800a44:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a48:	89 f2                	mov    %esi,%edx
  800a4a:	eb 09                	jmp    800a55 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a4c:	83 c2 01             	add    $0x1,%edx
  800a4f:	83 c1 01             	add    $0x1,%ecx
  800a52:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a55:	39 c2                	cmp    %eax,%edx
  800a57:	74 09                	je     800a62 <strlcpy+0x32>
  800a59:	0f b6 19             	movzbl (%ecx),%ebx
  800a5c:	84 db                	test   %bl,%bl
  800a5e:	75 ec                	jne    800a4c <strlcpy+0x1c>
  800a60:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a62:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a65:	29 f0                	sub    %esi,%eax
}
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a74:	eb 06                	jmp    800a7c <strcmp+0x11>
		p++, q++;
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a7c:	0f b6 01             	movzbl (%ecx),%eax
  800a7f:	84 c0                	test   %al,%al
  800a81:	74 04                	je     800a87 <strcmp+0x1c>
  800a83:	3a 02                	cmp    (%edx),%al
  800a85:	74 ef                	je     800a76 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a87:	0f b6 c0             	movzbl %al,%eax
  800a8a:	0f b6 12             	movzbl (%edx),%edx
  800a8d:	29 d0                	sub    %edx,%eax
}
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	53                   	push   %ebx
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9b:	89 c3                	mov    %eax,%ebx
  800a9d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa0:	eb 06                	jmp    800aa8 <strncmp+0x17>
		n--, p++, q++;
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa8:	39 d8                	cmp    %ebx,%eax
  800aaa:	74 15                	je     800ac1 <strncmp+0x30>
  800aac:	0f b6 08             	movzbl (%eax),%ecx
  800aaf:	84 c9                	test   %cl,%cl
  800ab1:	74 04                	je     800ab7 <strncmp+0x26>
  800ab3:	3a 0a                	cmp    (%edx),%cl
  800ab5:	74 eb                	je     800aa2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab7:	0f b6 00             	movzbl (%eax),%eax
  800aba:	0f b6 12             	movzbl (%edx),%edx
  800abd:	29 d0                	sub    %edx,%eax
  800abf:	eb 05                	jmp    800ac6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac6:	5b                   	pop    %ebx
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad3:	eb 07                	jmp    800adc <strchr+0x13>
		if (*s == c)
  800ad5:	38 ca                	cmp    %cl,%dl
  800ad7:	74 0f                	je     800ae8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad9:	83 c0 01             	add    $0x1,%eax
  800adc:	0f b6 10             	movzbl (%eax),%edx
  800adf:	84 d2                	test   %dl,%dl
  800ae1:	75 f2                	jne    800ad5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af4:	eb 03                	jmp    800af9 <strfind+0xf>
  800af6:	83 c0 01             	add    $0x1,%eax
  800af9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800afc:	38 ca                	cmp    %cl,%dl
  800afe:	74 04                	je     800b04 <strfind+0x1a>
  800b00:	84 d2                	test   %dl,%dl
  800b02:	75 f2                	jne    800af6 <strfind+0xc>
			break;
	return (char *) s;
}
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b12:	85 c9                	test   %ecx,%ecx
  800b14:	74 36                	je     800b4c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b16:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1c:	75 28                	jne    800b46 <memset+0x40>
  800b1e:	f6 c1 03             	test   $0x3,%cl
  800b21:	75 23                	jne    800b46 <memset+0x40>
		c &= 0xFF;
  800b23:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b27:	89 d3                	mov    %edx,%ebx
  800b29:	c1 e3 08             	shl    $0x8,%ebx
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	c1 e6 18             	shl    $0x18,%esi
  800b31:	89 d0                	mov    %edx,%eax
  800b33:	c1 e0 10             	shl    $0x10,%eax
  800b36:	09 f0                	or     %esi,%eax
  800b38:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b3a:	89 d8                	mov    %ebx,%eax
  800b3c:	09 d0                	or     %edx,%eax
  800b3e:	c1 e9 02             	shr    $0x2,%ecx
  800b41:	fc                   	cld    
  800b42:	f3 ab                	rep stos %eax,%es:(%edi)
  800b44:	eb 06                	jmp    800b4c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b49:	fc                   	cld    
  800b4a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b4c:	89 f8                	mov    %edi,%eax
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b61:	39 c6                	cmp    %eax,%esi
  800b63:	73 35                	jae    800b9a <memmove+0x47>
  800b65:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b68:	39 d0                	cmp    %edx,%eax
  800b6a:	73 2e                	jae    800b9a <memmove+0x47>
		s += n;
		d += n;
  800b6c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	09 fe                	or     %edi,%esi
  800b73:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b79:	75 13                	jne    800b8e <memmove+0x3b>
  800b7b:	f6 c1 03             	test   $0x3,%cl
  800b7e:	75 0e                	jne    800b8e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b80:	83 ef 04             	sub    $0x4,%edi
  800b83:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b86:	c1 e9 02             	shr    $0x2,%ecx
  800b89:	fd                   	std    
  800b8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8c:	eb 09                	jmp    800b97 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8e:	83 ef 01             	sub    $0x1,%edi
  800b91:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b94:	fd                   	std    
  800b95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b97:	fc                   	cld    
  800b98:	eb 1d                	jmp    800bb7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9a:	89 f2                	mov    %esi,%edx
  800b9c:	09 c2                	or     %eax,%edx
  800b9e:	f6 c2 03             	test   $0x3,%dl
  800ba1:	75 0f                	jne    800bb2 <memmove+0x5f>
  800ba3:	f6 c1 03             	test   $0x3,%cl
  800ba6:	75 0a                	jne    800bb2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ba8:	c1 e9 02             	shr    $0x2,%ecx
  800bab:	89 c7                	mov    %eax,%edi
  800bad:	fc                   	cld    
  800bae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb0:	eb 05                	jmp    800bb7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb2:	89 c7                	mov    %eax,%edi
  800bb4:	fc                   	cld    
  800bb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bbe:	ff 75 10             	pushl  0x10(%ebp)
  800bc1:	ff 75 0c             	pushl  0xc(%ebp)
  800bc4:	ff 75 08             	pushl  0x8(%ebp)
  800bc7:	e8 87 ff ff ff       	call   800b53 <memmove>
}
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd9:	89 c6                	mov    %eax,%esi
  800bdb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bde:	eb 1a                	jmp    800bfa <memcmp+0x2c>
		if (*s1 != *s2)
  800be0:	0f b6 08             	movzbl (%eax),%ecx
  800be3:	0f b6 1a             	movzbl (%edx),%ebx
  800be6:	38 d9                	cmp    %bl,%cl
  800be8:	74 0a                	je     800bf4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bea:	0f b6 c1             	movzbl %cl,%eax
  800bed:	0f b6 db             	movzbl %bl,%ebx
  800bf0:	29 d8                	sub    %ebx,%eax
  800bf2:	eb 0f                	jmp    800c03 <memcmp+0x35>
		s1++, s2++;
  800bf4:	83 c0 01             	add    $0x1,%eax
  800bf7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfa:	39 f0                	cmp    %esi,%eax
  800bfc:	75 e2                	jne    800be0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	53                   	push   %ebx
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c0e:	89 c1                	mov    %eax,%ecx
  800c10:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c13:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c17:	eb 0a                	jmp    800c23 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c19:	0f b6 10             	movzbl (%eax),%edx
  800c1c:	39 da                	cmp    %ebx,%edx
  800c1e:	74 07                	je     800c27 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c20:	83 c0 01             	add    $0x1,%eax
  800c23:	39 c8                	cmp    %ecx,%eax
  800c25:	72 f2                	jb     800c19 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c27:	5b                   	pop    %ebx
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c36:	eb 03                	jmp    800c3b <strtol+0x11>
		s++;
  800c38:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3b:	0f b6 01             	movzbl (%ecx),%eax
  800c3e:	3c 20                	cmp    $0x20,%al
  800c40:	74 f6                	je     800c38 <strtol+0xe>
  800c42:	3c 09                	cmp    $0x9,%al
  800c44:	74 f2                	je     800c38 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c46:	3c 2b                	cmp    $0x2b,%al
  800c48:	75 0a                	jne    800c54 <strtol+0x2a>
		s++;
  800c4a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c52:	eb 11                	jmp    800c65 <strtol+0x3b>
  800c54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c59:	3c 2d                	cmp    $0x2d,%al
  800c5b:	75 08                	jne    800c65 <strtol+0x3b>
		s++, neg = 1;
  800c5d:	83 c1 01             	add    $0x1,%ecx
  800c60:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c6b:	75 15                	jne    800c82 <strtol+0x58>
  800c6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c70:	75 10                	jne    800c82 <strtol+0x58>
  800c72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c76:	75 7c                	jne    800cf4 <strtol+0xca>
		s += 2, base = 16;
  800c78:	83 c1 02             	add    $0x2,%ecx
  800c7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c80:	eb 16                	jmp    800c98 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c82:	85 db                	test   %ebx,%ebx
  800c84:	75 12                	jne    800c98 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c86:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c8e:	75 08                	jne    800c98 <strtol+0x6e>
		s++, base = 8;
  800c90:	83 c1 01             	add    $0x1,%ecx
  800c93:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c98:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca0:	0f b6 11             	movzbl (%ecx),%edx
  800ca3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ca6:	89 f3                	mov    %esi,%ebx
  800ca8:	80 fb 09             	cmp    $0x9,%bl
  800cab:	77 08                	ja     800cb5 <strtol+0x8b>
			dig = *s - '0';
  800cad:	0f be d2             	movsbl %dl,%edx
  800cb0:	83 ea 30             	sub    $0x30,%edx
  800cb3:	eb 22                	jmp    800cd7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cb5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb8:	89 f3                	mov    %esi,%ebx
  800cba:	80 fb 19             	cmp    $0x19,%bl
  800cbd:	77 08                	ja     800cc7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cbf:	0f be d2             	movsbl %dl,%edx
  800cc2:	83 ea 57             	sub    $0x57,%edx
  800cc5:	eb 10                	jmp    800cd7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cc7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cca:	89 f3                	mov    %esi,%ebx
  800ccc:	80 fb 19             	cmp    $0x19,%bl
  800ccf:	77 16                	ja     800ce7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cd1:	0f be d2             	movsbl %dl,%edx
  800cd4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cd7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cda:	7d 0b                	jge    800ce7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cdc:	83 c1 01             	add    $0x1,%ecx
  800cdf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ce3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ce5:	eb b9                	jmp    800ca0 <strtol+0x76>

	if (endptr)
  800ce7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ceb:	74 0d                	je     800cfa <strtol+0xd0>
		*endptr = (char *) s;
  800ced:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf0:	89 0e                	mov    %ecx,(%esi)
  800cf2:	eb 06                	jmp    800cfa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf4:	85 db                	test   %ebx,%ebx
  800cf6:	74 98                	je     800c90 <strtol+0x66>
  800cf8:	eb 9e                	jmp    800c98 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cfa:	89 c2                	mov    %eax,%edx
  800cfc:	f7 da                	neg    %edx
  800cfe:	85 ff                	test   %edi,%edi
  800d00:	0f 45 c2             	cmovne %edx,%eax
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__udivdi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 f6                	test   %esi,%esi
  800d29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d2d:	89 ca                	mov    %ecx,%edx
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	75 3d                	jne    800d70 <__udivdi3+0x60>
  800d33:	39 cf                	cmp    %ecx,%edi
  800d35:	0f 87 c5 00 00 00    	ja     800e00 <__udivdi3+0xf0>
  800d3b:	85 ff                	test   %edi,%edi
  800d3d:	89 fd                	mov    %edi,%ebp
  800d3f:	75 0b                	jne    800d4c <__udivdi3+0x3c>
  800d41:	b8 01 00 00 00       	mov    $0x1,%eax
  800d46:	31 d2                	xor    %edx,%edx
  800d48:	f7 f7                	div    %edi
  800d4a:	89 c5                	mov    %eax,%ebp
  800d4c:	89 c8                	mov    %ecx,%eax
  800d4e:	31 d2                	xor    %edx,%edx
  800d50:	f7 f5                	div    %ebp
  800d52:	89 c1                	mov    %eax,%ecx
  800d54:	89 d8                	mov    %ebx,%eax
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	f7 f5                	div    %ebp
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	89 d8                	mov    %ebx,%eax
  800d5e:	89 fa                	mov    %edi,%edx
  800d60:	83 c4 1c             	add    $0x1c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
  800d68:	90                   	nop
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	39 ce                	cmp    %ecx,%esi
  800d72:	77 74                	ja     800de8 <__udivdi3+0xd8>
  800d74:	0f bd fe             	bsr    %esi,%edi
  800d77:	83 f7 1f             	xor    $0x1f,%edi
  800d7a:	0f 84 98 00 00 00    	je     800e18 <__udivdi3+0x108>
  800d80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	89 c5                	mov    %eax,%ebp
  800d89:	29 fb                	sub    %edi,%ebx
  800d8b:	d3 e6                	shl    %cl,%esi
  800d8d:	89 d9                	mov    %ebx,%ecx
  800d8f:	d3 ed                	shr    %cl,%ebp
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e0                	shl    %cl,%eax
  800d95:	09 ee                	or     %ebp,%esi
  800d97:	89 d9                	mov    %ebx,%ecx
  800d99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9d:	89 d5                	mov    %edx,%ebp
  800d9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800da3:	d3 ed                	shr    %cl,%ebp
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e2                	shl    %cl,%edx
  800da9:	89 d9                	mov    %ebx,%ecx
  800dab:	d3 e8                	shr    %cl,%eax
  800dad:	09 c2                	or     %eax,%edx
  800daf:	89 d0                	mov    %edx,%eax
  800db1:	89 ea                	mov    %ebp,%edx
  800db3:	f7 f6                	div    %esi
  800db5:	89 d5                	mov    %edx,%ebp
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	f7 64 24 0c          	mull   0xc(%esp)
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	72 10                	jb     800dd1 <__udivdi3+0xc1>
  800dc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e6                	shl    %cl,%esi
  800dc9:	39 c6                	cmp    %eax,%esi
  800dcb:	73 07                	jae    800dd4 <__udivdi3+0xc4>
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	75 03                	jne    800dd4 <__udivdi3+0xc4>
  800dd1:	83 eb 01             	sub    $0x1,%ebx
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	89 d8                	mov    %ebx,%eax
  800dd8:	89 fa                	mov    %edi,%edx
  800dda:	83 c4 1c             	add    $0x1c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
  800de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800de8:	31 ff                	xor    %edi,%edi
  800dea:	31 db                	xor    %ebx,%ebx
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	89 fa                	mov    %edi,%edx
  800df0:	83 c4 1c             	add    $0x1c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	90                   	nop
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	f7 f7                	div    %edi
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 1c             	add    $0x1c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	39 ce                	cmp    %ecx,%esi
  800e1a:	72 0c                	jb     800e28 <__udivdi3+0x118>
  800e1c:	31 db                	xor    %ebx,%ebx
  800e1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e22:	0f 87 34 ff ff ff    	ja     800d5c <__udivdi3+0x4c>
  800e28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e2d:	e9 2a ff ff ff       	jmp    800d5c <__udivdi3+0x4c>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 1c             	sub    $0x1c,%esp
  800e47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e57:	85 d2                	test   %edx,%edx
  800e59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f3                	mov    %esi,%ebx
  800e63:	89 3c 24             	mov    %edi,(%esp)
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	75 1c                	jne    800e88 <__umoddi3+0x48>
  800e6c:	39 f7                	cmp    %esi,%edi
  800e6e:	76 50                	jbe    800ec0 <__umoddi3+0x80>
  800e70:	89 c8                	mov    %ecx,%eax
  800e72:	89 f2                	mov    %esi,%edx
  800e74:	f7 f7                	div    %edi
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	89 d0                	mov    %edx,%eax
  800e8c:	77 52                	ja     800ee0 <__umoddi3+0xa0>
  800e8e:	0f bd ea             	bsr    %edx,%ebp
  800e91:	83 f5 1f             	xor    $0x1f,%ebp
  800e94:	75 5a                	jne    800ef0 <__umoddi3+0xb0>
  800e96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e9a:	0f 82 e0 00 00 00    	jb     800f80 <__umoddi3+0x140>
  800ea0:	39 0c 24             	cmp    %ecx,(%esp)
  800ea3:	0f 86 d7 00 00 00    	jbe    800f80 <__umoddi3+0x140>
  800ea9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ead:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	85 ff                	test   %edi,%edi
  800ec2:	89 fd                	mov    %edi,%ebp
  800ec4:	75 0b                	jne    800ed1 <__umoddi3+0x91>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f7                	div    %edi
  800ecf:	89 c5                	mov    %eax,%ebp
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f5                	div    %ebp
  800ed7:	89 c8                	mov    %ecx,%eax
  800ed9:	f7 f5                	div    %ebp
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	eb 99                	jmp    800e78 <__umoddi3+0x38>
  800edf:	90                   	nop
  800ee0:	89 c8                	mov    %ecx,%eax
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	8b 34 24             	mov    (%esp),%esi
  800ef3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef8:	89 e9                	mov    %ebp,%ecx
  800efa:	29 ef                	sub    %ebp,%edi
  800efc:	d3 e0                	shl    %cl,%eax
  800efe:	89 f9                	mov    %edi,%ecx
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	d3 ea                	shr    %cl,%edx
  800f04:	89 e9                	mov    %ebp,%ecx
  800f06:	09 c2                	or     %eax,%edx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 14 24             	mov    %edx,(%esp)
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	d3 e2                	shl    %cl,%edx
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	d3 e3                	shl    %cl,%ebx
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 d0                	mov    %edx,%eax
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	09 d8                	or     %ebx,%eax
  800f2d:	89 d3                	mov    %edx,%ebx
  800f2f:	89 f2                	mov    %esi,%edx
  800f31:	f7 34 24             	divl   (%esp)
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	d3 e3                	shl    %cl,%ebx
  800f38:	f7 64 24 04          	mull   0x4(%esp)
  800f3c:	39 d6                	cmp    %edx,%esi
  800f3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f42:	89 d1                	mov    %edx,%ecx
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	72 08                	jb     800f50 <__umoddi3+0x110>
  800f48:	75 11                	jne    800f5b <__umoddi3+0x11b>
  800f4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f4e:	73 0b                	jae    800f5b <__umoddi3+0x11b>
  800f50:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f54:	1b 14 24             	sbb    (%esp),%edx
  800f57:	89 d1                	mov    %edx,%ecx
  800f59:	89 c3                	mov    %eax,%ebx
  800f5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f5f:	29 da                	sub    %ebx,%edx
  800f61:	19 ce                	sbb    %ecx,%esi
  800f63:	89 f9                	mov    %edi,%ecx
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	d3 e0                	shl    %cl,%eax
  800f69:	89 e9                	mov    %ebp,%ecx
  800f6b:	d3 ea                	shr    %cl,%edx
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	d3 ee                	shr    %cl,%esi
  800f71:	09 d0                	or     %edx,%eax
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	83 c4 1c             	add    $0x1c,%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	29 f9                	sub    %edi,%ecx
  800f82:	19 d6                	sbb    %edx,%esi
  800f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f8c:	e9 18 ff ff ff       	jmp    800ea9 <__umoddi3+0x69>
