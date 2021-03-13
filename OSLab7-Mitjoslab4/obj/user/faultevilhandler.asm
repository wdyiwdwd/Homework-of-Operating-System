
obj/user/faultevilhandler：     文件格式 elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 32 01 00 00       	call   800179 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 2c 02 00 00       	call   800282 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800070:	e8 c6 00 00 00       	call   80013b <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	c1 e0 07             	shl    $0x7,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 42 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	b8 03 00 00 00       	mov    $0x3,%eax
  80010d:	8b 55 08             	mov    0x8(%ebp),%edx
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7e 17                	jle    800133 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	50                   	push   %eax
  800120:	6a 03                	push   $0x3
  800122:	68 ea 0f 80 00       	push   $0x800fea
  800127:	6a 23                	push   $0x23
  800129:	68 07 10 80 00       	push   $0x801007
  80012e:	e8 15 02 00 00       	call   800348 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 17                	jle    8001b4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	6a 04                	push   $0x4
  8001a3:	68 ea 0f 80 00       	push   $0x800fea
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 07 10 80 00       	push   $0x801007
  8001af:	e8 94 01 00 00       	call   800348 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7e 17                	jle    8001f6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	50                   	push   %eax
  8001e3:	6a 05                	push   $0x5
  8001e5:	68 ea 0f 80 00       	push   $0x800fea
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 07 10 80 00       	push   $0x801007
  8001f1:	e8 52 01 00 00       	call   800348 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	b8 06 00 00 00       	mov    $0x6,%eax
  800211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7e 17                	jle    800238 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	50                   	push   %eax
  800225:	6a 06                	push   $0x6
  800227:	68 ea 0f 80 00       	push   $0x800fea
  80022c:	6a 23                	push   $0x23
  80022e:	68 07 10 80 00       	push   $0x801007
  800233:	e8 10 01 00 00       	call   800348 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 17                	jle    80027a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	50                   	push   %eax
  800267:	6a 08                	push   $0x8
  800269:	68 ea 0f 80 00       	push   $0x800fea
  80026e:	6a 23                	push   $0x23
  800270:	68 07 10 80 00       	push   $0x801007
  800275:	e8 ce 00 00 00       	call   800348 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	b8 09 00 00 00       	mov    $0x9,%eax
  800295:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7e 17                	jle    8002bc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	50                   	push   %eax
  8002a9:	6a 09                	push   $0x9
  8002ab:	68 ea 0f 80 00       	push   $0x800fea
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 07 10 80 00       	push   $0x801007
  8002b7:	e8 8c 00 00 00       	call   800348 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ca:	be 00 00 00 00       	mov    $0x0,%esi
  8002cf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	89 cb                	mov    %ecx,%ebx
  8002ff:	89 cf                	mov    %ecx,%edi
  800301:	89 ce                	mov    %ecx,%esi
  800303:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800305:	85 c0                	test   %eax,%eax
  800307:	7e 17                	jle    800320 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	50                   	push   %eax
  80030d:	6a 0c                	push   $0xc
  80030f:	68 ea 0f 80 00       	push   $0x800fea
  800314:	6a 23                	push   $0x23
  800316:	68 07 10 80 00       	push   $0x801007
  80031b:	e8 28 00 00 00       	call   800348 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800333:	b8 0d 00 00 00       	mov    $0xd,%eax
  800338:	8b 55 08             	mov    0x8(%ebp),%edx
  80033b:	89 cb                	mov    %ecx,%ebx
  80033d:	89 cf                	mov    %ecx,%edi
  80033f:	89 ce                	mov    %ecx,%esi
  800341:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80034d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800350:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800356:	e8 e0 fd ff ff       	call   80013b <sys_getenvid>
  80035b:	83 ec 0c             	sub    $0xc,%esp
  80035e:	ff 75 0c             	pushl  0xc(%ebp)
  800361:	ff 75 08             	pushl  0x8(%ebp)
  800364:	56                   	push   %esi
  800365:	50                   	push   %eax
  800366:	68 18 10 80 00       	push   $0x801018
  80036b:	e8 b1 00 00 00       	call   800421 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800370:	83 c4 18             	add    $0x18,%esp
  800373:	53                   	push   %ebx
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	e8 54 00 00 00       	call   8003d0 <vcprintf>
	cprintf("\n");
  80037c:	c7 04 24 3c 10 80 00 	movl   $0x80103c,(%esp)
  800383:	e8 99 00 00 00       	call   800421 <cprintf>
  800388:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038b:	cc                   	int3   
  80038c:	eb fd                	jmp    80038b <_panic+0x43>

0080038e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	53                   	push   %ebx
  800392:	83 ec 04             	sub    $0x4,%esp
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800398:	8b 13                	mov    (%ebx),%edx
  80039a:	8d 42 01             	lea    0x1(%edx),%eax
  80039d:	89 03                	mov    %eax,(%ebx)
  80039f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ab:	75 1a                	jne    8003c7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	68 ff 00 00 00       	push   $0xff
  8003b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b8:	50                   	push   %eax
  8003b9:	e8 ff fc ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  8003be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003c7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e0:	00 00 00 
	b.cnt = 0;
  8003e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ed:	ff 75 0c             	pushl  0xc(%ebp)
  8003f0:	ff 75 08             	pushl  0x8(%ebp)
  8003f3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f9:	50                   	push   %eax
  8003fa:	68 8e 03 80 00       	push   $0x80038e
  8003ff:	e8 54 01 00 00       	call   800558 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800404:	83 c4 08             	add    $0x8,%esp
  800407:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80040d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800413:	50                   	push   %eax
  800414:	e8 a4 fc ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  800419:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041f:	c9                   	leave  
  800420:	c3                   	ret    

00800421 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800427:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042a:	50                   	push   %eax
  80042b:	ff 75 08             	pushl  0x8(%ebp)
  80042e:	e8 9d ff ff ff       	call   8003d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800433:	c9                   	leave  
  800434:	c3                   	ret    

00800435 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	57                   	push   %edi
  800439:	56                   	push   %esi
  80043a:	53                   	push   %ebx
  80043b:	83 ec 1c             	sub    $0x1c,%esp
  80043e:	89 c7                	mov    %eax,%edi
  800440:	89 d6                	mov    %edx,%esi
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	8b 55 0c             	mov    0xc(%ebp),%edx
  800448:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800451:	bb 00 00 00 00       	mov    $0x0,%ebx
  800456:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800459:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80045c:	39 d3                	cmp    %edx,%ebx
  80045e:	72 05                	jb     800465 <printnum+0x30>
  800460:	39 45 10             	cmp    %eax,0x10(%ebp)
  800463:	77 45                	ja     8004aa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800465:	83 ec 0c             	sub    $0xc,%esp
  800468:	ff 75 18             	pushl  0x18(%ebp)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800471:	53                   	push   %ebx
  800472:	ff 75 10             	pushl  0x10(%ebp)
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047b:	ff 75 e0             	pushl  -0x20(%ebp)
  80047e:	ff 75 dc             	pushl  -0x24(%ebp)
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	e8 b7 08 00 00       	call   800d40 <__udivdi3>
  800489:	83 c4 18             	add    $0x18,%esp
  80048c:	52                   	push   %edx
  80048d:	50                   	push   %eax
  80048e:	89 f2                	mov    %esi,%edx
  800490:	89 f8                	mov    %edi,%eax
  800492:	e8 9e ff ff ff       	call   800435 <printnum>
  800497:	83 c4 20             	add    $0x20,%esp
  80049a:	eb 18                	jmp    8004b4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	56                   	push   %esi
  8004a0:	ff 75 18             	pushl  0x18(%ebp)
  8004a3:	ff d7                	call   *%edi
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	eb 03                	jmp    8004ad <printnum+0x78>
  8004aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	85 db                	test   %ebx,%ebx
  8004b2:	7f e8                	jg     80049c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	56                   	push   %esi
  8004b8:	83 ec 04             	sub    $0x4,%esp
  8004bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004be:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c7:	e8 a4 09 00 00       	call   800e70 <__umoddi3>
  8004cc:	83 c4 14             	add    $0x14,%esp
  8004cf:	0f be 80 3e 10 80 00 	movsbl 0x80103e(%eax),%eax
  8004d6:	50                   	push   %eax
  8004d7:	ff d7                	call   *%edi
}
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004df:	5b                   	pop    %ebx
  8004e0:	5e                   	pop    %esi
  8004e1:	5f                   	pop    %edi
  8004e2:	5d                   	pop    %ebp
  8004e3:	c3                   	ret    

008004e4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e7:	83 fa 01             	cmp    $0x1,%edx
  8004ea:	7e 0e                	jle    8004fa <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004f1:	89 08                	mov    %ecx,(%eax)
  8004f3:	8b 02                	mov    (%edx),%eax
  8004f5:	8b 52 04             	mov    0x4(%edx),%edx
  8004f8:	eb 22                	jmp    80051c <getuint+0x38>
	else if (lflag)
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	74 10                	je     80050e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004fe:	8b 10                	mov    (%eax),%edx
  800500:	8d 4a 04             	lea    0x4(%edx),%ecx
  800503:	89 08                	mov    %ecx,(%eax)
  800505:	8b 02                	mov    (%edx),%eax
  800507:	ba 00 00 00 00       	mov    $0x0,%edx
  80050c:	eb 0e                	jmp    80051c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80050e:	8b 10                	mov    (%eax),%edx
  800510:	8d 4a 04             	lea    0x4(%edx),%ecx
  800513:	89 08                	mov    %ecx,(%eax)
  800515:	8b 02                	mov    (%edx),%eax
  800517:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051c:	5d                   	pop    %ebp
  80051d:	c3                   	ret    

0080051e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80051e:	55                   	push   %ebp
  80051f:	89 e5                	mov    %esp,%ebp
  800521:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800524:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	3b 50 04             	cmp    0x4(%eax),%edx
  80052d:	73 0a                	jae    800539 <sprintputch+0x1b>
		*b->buf++ = ch;
  80052f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800532:	89 08                	mov    %ecx,(%eax)
  800534:	8b 45 08             	mov    0x8(%ebp),%eax
  800537:	88 02                	mov    %al,(%edx)
}
  800539:	5d                   	pop    %ebp
  80053a:	c3                   	ret    

0080053b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800541:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800544:	50                   	push   %eax
  800545:	ff 75 10             	pushl  0x10(%ebp)
  800548:	ff 75 0c             	pushl  0xc(%ebp)
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 05 00 00 00       	call   800558 <vprintfmt>
	va_end(ap);
}
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	c9                   	leave  
  800557:	c3                   	ret    

00800558 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	57                   	push   %edi
  80055c:	56                   	push   %esi
  80055d:	53                   	push   %ebx
  80055e:	83 ec 2c             	sub    $0x2c,%esp
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	8b 7d 10             	mov    0x10(%ebp),%edi
  80056a:	eb 1d                	jmp    800589 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80056c:	85 c0                	test   %eax,%eax
  80056e:	75 0f                	jne    80057f <vprintfmt+0x27>
				csa = 0x0700;
  800570:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800577:	07 00 00 
				return;
  80057a:	e9 c4 03 00 00       	jmp    800943 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	53                   	push   %ebx
  800583:	50                   	push   %eax
  800584:	ff d6                	call   *%esi
  800586:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800589:	83 c7 01             	add    $0x1,%edi
  80058c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800590:	83 f8 25             	cmp    $0x25,%eax
  800593:	75 d7                	jne    80056c <vprintfmt+0x14>
  800595:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800599:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005a0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b3:	eb 07                	jmp    8005bc <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005b8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8d 47 01             	lea    0x1(%edi),%eax
  8005bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c2:	0f b6 07             	movzbl (%edi),%eax
  8005c5:	0f b6 c8             	movzbl %al,%ecx
  8005c8:	83 e8 23             	sub    $0x23,%eax
  8005cb:	3c 55                	cmp    $0x55,%al
  8005cd:	0f 87 55 03 00 00    	ja     800928 <vprintfmt+0x3d0>
  8005d3:	0f b6 c0             	movzbl %al,%eax
  8005d6:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  8005dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005e0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005e4:	eb d6                	jmp    8005bc <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005f1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005f4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005f8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005fb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005fe:	83 fa 09             	cmp    $0x9,%edx
  800601:	77 39                	ja     80063c <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800603:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800606:	eb e9                	jmp    8005f1 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 48 04             	lea    0x4(%eax),%ecx
  80060e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800611:	8b 00                	mov    (%eax),%eax
  800613:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800619:	eb 27                	jmp    800642 <vprintfmt+0xea>
  80061b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061e:	85 c0                	test   %eax,%eax
  800620:	b9 00 00 00 00       	mov    $0x0,%ecx
  800625:	0f 49 c8             	cmovns %eax,%ecx
  800628:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062e:	eb 8c                	jmp    8005bc <vprintfmt+0x64>
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800633:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80063a:	eb 80                	jmp    8005bc <vprintfmt+0x64>
  80063c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80063f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800642:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800646:	0f 89 70 ff ff ff    	jns    8005bc <vprintfmt+0x64>
				width = precision, precision = -1;
  80064c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80064f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800652:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800659:	e9 5e ff ff ff       	jmp    8005bc <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80065e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800664:	e9 53 ff ff ff       	jmp    8005bc <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	ff 30                	pushl  (%eax)
  800678:	ff d6                	call   *%esi
			break;
  80067a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800680:	e9 04 ff ff ff       	jmp    800589 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8d 50 04             	lea    0x4(%eax),%edx
  80068b:	89 55 14             	mov    %edx,0x14(%ebp)
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	99                   	cltd   
  800691:	31 d0                	xor    %edx,%eax
  800693:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800695:	83 f8 08             	cmp    $0x8,%eax
  800698:	7f 0b                	jg     8006a5 <vprintfmt+0x14d>
  80069a:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  8006a1:	85 d2                	test   %edx,%edx
  8006a3:	75 18                	jne    8006bd <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8006a5:	50                   	push   %eax
  8006a6:	68 56 10 80 00       	push   $0x801056
  8006ab:	53                   	push   %ebx
  8006ac:	56                   	push   %esi
  8006ad:	e8 89 fe ff ff       	call   80053b <printfmt>
  8006b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006b8:	e9 cc fe ff ff       	jmp    800589 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8006bd:	52                   	push   %edx
  8006be:	68 5f 10 80 00       	push   $0x80105f
  8006c3:	53                   	push   %ebx
  8006c4:	56                   	push   %esi
  8006c5:	e8 71 fe ff ff       	call   80053b <printfmt>
  8006ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d0:	e9 b4 fe ff ff       	jmp    800589 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006e0:	85 ff                	test   %edi,%edi
  8006e2:	b8 4f 10 80 00       	mov    $0x80104f,%eax
  8006e7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ee:	0f 8e 94 00 00 00    	jle    800788 <vprintfmt+0x230>
  8006f4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006f8:	0f 84 98 00 00 00    	je     800796 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	ff 75 d0             	pushl  -0x30(%ebp)
  800704:	57                   	push   %edi
  800705:	e8 c1 02 00 00       	call   8009cb <strnlen>
  80070a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80070d:	29 c1                	sub    %eax,%ecx
  80070f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800712:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800715:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800719:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80071c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80071f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800721:	eb 0f                	jmp    800732 <vprintfmt+0x1da>
					putch(padc, putdat);
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	53                   	push   %ebx
  800727:	ff 75 e0             	pushl  -0x20(%ebp)
  80072a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072c:	83 ef 01             	sub    $0x1,%edi
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 ff                	test   %edi,%edi
  800734:	7f ed                	jg     800723 <vprintfmt+0x1cb>
  800736:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800739:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80073c:	85 c9                	test   %ecx,%ecx
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	0f 49 c1             	cmovns %ecx,%eax
  800746:	29 c1                	sub    %eax,%ecx
  800748:	89 75 08             	mov    %esi,0x8(%ebp)
  80074b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800751:	89 cb                	mov    %ecx,%ebx
  800753:	eb 4d                	jmp    8007a2 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800755:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800759:	74 1b                	je     800776 <vprintfmt+0x21e>
  80075b:	0f be c0             	movsbl %al,%eax
  80075e:	83 e8 20             	sub    $0x20,%eax
  800761:	83 f8 5e             	cmp    $0x5e,%eax
  800764:	76 10                	jbe    800776 <vprintfmt+0x21e>
					putch('?', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	6a 3f                	push   $0x3f
  80076e:	ff 55 08             	call   *0x8(%ebp)
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	eb 0d                	jmp    800783 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800776:	83 ec 08             	sub    $0x8,%esp
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	52                   	push   %edx
  80077d:	ff 55 08             	call   *0x8(%ebp)
  800780:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800783:	83 eb 01             	sub    $0x1,%ebx
  800786:	eb 1a                	jmp    8007a2 <vprintfmt+0x24a>
  800788:	89 75 08             	mov    %esi,0x8(%ebp)
  80078b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80078e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800791:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800794:	eb 0c                	jmp    8007a2 <vprintfmt+0x24a>
  800796:	89 75 08             	mov    %esi,0x8(%ebp)
  800799:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80079c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80079f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007a2:	83 c7 01             	add    $0x1,%edi
  8007a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007a9:	0f be d0             	movsbl %al,%edx
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 23                	je     8007d3 <vprintfmt+0x27b>
  8007b0:	85 f6                	test   %esi,%esi
  8007b2:	78 a1                	js     800755 <vprintfmt+0x1fd>
  8007b4:	83 ee 01             	sub    $0x1,%esi
  8007b7:	79 9c                	jns    800755 <vprintfmt+0x1fd>
  8007b9:	89 df                	mov    %ebx,%edi
  8007bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c1:	eb 18                	jmp    8007db <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	6a 20                	push   $0x20
  8007c9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007cb:	83 ef 01             	sub    $0x1,%edi
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	eb 08                	jmp    8007db <vprintfmt+0x283>
  8007d3:	89 df                	mov    %ebx,%edi
  8007d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007db:	85 ff                	test   %edi,%edi
  8007dd:	7f e4                	jg     8007c3 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e2:	e9 a2 fd ff ff       	jmp    800589 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e7:	83 fa 01             	cmp    $0x1,%edx
  8007ea:	7e 16                	jle    800802 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8d 50 08             	lea    0x8(%eax),%edx
  8007f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f5:	8b 50 04             	mov    0x4(%eax),%edx
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800800:	eb 32                	jmp    800834 <vprintfmt+0x2dc>
	else if (lflag)
  800802:	85 d2                	test   %edx,%edx
  800804:	74 18                	je     80081e <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 00                	mov    (%eax),%eax
  800811:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800814:	89 c1                	mov    %eax,%ecx
  800816:	c1 f9 1f             	sar    $0x1f,%ecx
  800819:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80081c:	eb 16                	jmp    800834 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8d 50 04             	lea    0x4(%eax),%edx
  800824:	89 55 14             	mov    %edx,0x14(%ebp)
  800827:	8b 00                	mov    (%eax),%eax
  800829:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082c:	89 c1                	mov    %eax,%ecx
  80082e:	c1 f9 1f             	sar    $0x1f,%ecx
  800831:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800834:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800837:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80083a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80083f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800843:	79 74                	jns    8008b9 <vprintfmt+0x361>
				putch('-', putdat);
  800845:	83 ec 08             	sub    $0x8,%esp
  800848:	53                   	push   %ebx
  800849:	6a 2d                	push   $0x2d
  80084b:	ff d6                	call   *%esi
				num = -(long long) num;
  80084d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800850:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800853:	f7 d8                	neg    %eax
  800855:	83 d2 00             	adc    $0x0,%edx
  800858:	f7 da                	neg    %edx
  80085a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80085d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800862:	eb 55                	jmp    8008b9 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800864:	8d 45 14             	lea    0x14(%ebp),%eax
  800867:	e8 78 fc ff ff       	call   8004e4 <getuint>
			base = 10;
  80086c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800871:	eb 46                	jmp    8008b9 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800873:	8d 45 14             	lea    0x14(%ebp),%eax
  800876:	e8 69 fc ff ff       	call   8004e4 <getuint>
      base = 8;
  80087b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800880:	eb 37                	jmp    8008b9 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	53                   	push   %ebx
  800886:	6a 30                	push   $0x30
  800888:	ff d6                	call   *%esi
			putch('x', putdat);
  80088a:	83 c4 08             	add    $0x8,%esp
  80088d:	53                   	push   %ebx
  80088e:	6a 78                	push   $0x78
  800890:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	8d 50 04             	lea    0x4(%eax),%edx
  800898:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80089b:	8b 00                	mov    (%eax),%eax
  80089d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008a2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008aa:	eb 0d                	jmp    8008b9 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8008af:	e8 30 fc ff ff       	call   8004e4 <getuint>
			base = 16;
  8008b4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b9:	83 ec 0c             	sub    $0xc,%esp
  8008bc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008c0:	57                   	push   %edi
  8008c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c4:	51                   	push   %ecx
  8008c5:	52                   	push   %edx
  8008c6:	50                   	push   %eax
  8008c7:	89 da                	mov    %ebx,%edx
  8008c9:	89 f0                	mov    %esi,%eax
  8008cb:	e8 65 fb ff ff       	call   800435 <printnum>
			break;
  8008d0:	83 c4 20             	add    $0x20,%esp
  8008d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d6:	e9 ae fc ff ff       	jmp    800589 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008db:	83 ec 08             	sub    $0x8,%esp
  8008de:	53                   	push   %ebx
  8008df:	51                   	push   %ecx
  8008e0:	ff d6                	call   *%esi
			break;
  8008e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e8:	e9 9c fc ff ff       	jmp    800589 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ed:	83 fa 01             	cmp    $0x1,%edx
  8008f0:	7e 0d                	jle    8008ff <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8d 50 08             	lea    0x8(%eax),%edx
  8008f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fb:	8b 00                	mov    (%eax),%eax
  8008fd:	eb 1c                	jmp    80091b <vprintfmt+0x3c3>
	else if (lflag)
  8008ff:	85 d2                	test   %edx,%edx
  800901:	74 0d                	je     800910 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8d 50 04             	lea    0x4(%eax),%edx
  800909:	89 55 14             	mov    %edx,0x14(%ebp)
  80090c:	8b 00                	mov    (%eax),%eax
  80090e:	eb 0b                	jmp    80091b <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800910:	8b 45 14             	mov    0x14(%ebp),%eax
  800913:	8d 50 04             	lea    0x4(%eax),%edx
  800916:	89 55 14             	mov    %edx,0x14(%ebp)
  800919:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  80091b:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800920:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800923:	e9 61 fc ff ff       	jmp    800589 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800928:	83 ec 08             	sub    $0x8,%esp
  80092b:	53                   	push   %ebx
  80092c:	6a 25                	push   $0x25
  80092e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800930:	83 c4 10             	add    $0x10,%esp
  800933:	eb 03                	jmp    800938 <vprintfmt+0x3e0>
  800935:	83 ef 01             	sub    $0x1,%edi
  800938:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80093c:	75 f7                	jne    800935 <vprintfmt+0x3dd>
  80093e:	e9 46 fc ff ff       	jmp    800589 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800943:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	83 ec 18             	sub    $0x18,%esp
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800957:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80095e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800961:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800968:	85 c0                	test   %eax,%eax
  80096a:	74 26                	je     800992 <vsnprintf+0x47>
  80096c:	85 d2                	test   %edx,%edx
  80096e:	7e 22                	jle    800992 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800970:	ff 75 14             	pushl  0x14(%ebp)
  800973:	ff 75 10             	pushl  0x10(%ebp)
  800976:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800979:	50                   	push   %eax
  80097a:	68 1e 05 80 00       	push   $0x80051e
  80097f:	e8 d4 fb ff ff       	call   800558 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800984:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800987:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098d:	83 c4 10             	add    $0x10,%esp
  800990:	eb 05                	jmp    800997 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800992:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800997:	c9                   	leave  
  800998:	c3                   	ret    

00800999 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80099f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a2:	50                   	push   %eax
  8009a3:	ff 75 10             	pushl  0x10(%ebp)
  8009a6:	ff 75 0c             	pushl  0xc(%ebp)
  8009a9:	ff 75 08             	pushl  0x8(%ebp)
  8009ac:	e8 9a ff ff ff       	call   80094b <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009be:	eb 03                	jmp    8009c3 <strlen+0x10>
		n++;
  8009c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c7:	75 f7                	jne    8009c0 <strlen+0xd>
		n++;
	return n;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d9:	eb 03                	jmp    8009de <strnlen+0x13>
		n++;
  8009db:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009de:	39 c2                	cmp    %eax,%edx
  8009e0:	74 08                	je     8009ea <strnlen+0x1f>
  8009e2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009e6:	75 f3                	jne    8009db <strnlen+0x10>
  8009e8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	53                   	push   %ebx
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f6:	89 c2                	mov    %eax,%edx
  8009f8:	83 c2 01             	add    $0x1,%edx
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a02:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a05:	84 db                	test   %bl,%bl
  800a07:	75 ef                	jne    8009f8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	53                   	push   %ebx
  800a10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a13:	53                   	push   %ebx
  800a14:	e8 9a ff ff ff       	call   8009b3 <strlen>
  800a19:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a1c:	ff 75 0c             	pushl  0xc(%ebp)
  800a1f:	01 d8                	add    %ebx,%eax
  800a21:	50                   	push   %eax
  800a22:	e8 c5 ff ff ff       	call   8009ec <strcpy>
	return dst;
}
  800a27:	89 d8                	mov    %ebx,%eax
  800a29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 75 08             	mov    0x8(%ebp),%esi
  800a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a39:	89 f3                	mov    %esi,%ebx
  800a3b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3e:	89 f2                	mov    %esi,%edx
  800a40:	eb 0f                	jmp    800a51 <strncpy+0x23>
		*dst++ = *src;
  800a42:	83 c2 01             	add    $0x1,%edx
  800a45:	0f b6 01             	movzbl (%ecx),%eax
  800a48:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a4b:	80 39 01             	cmpb   $0x1,(%ecx)
  800a4e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a51:	39 da                	cmp    %ebx,%edx
  800a53:	75 ed                	jne    800a42 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a55:	89 f0                	mov    %esi,%eax
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 75 08             	mov    0x8(%ebp),%esi
  800a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a66:	8b 55 10             	mov    0x10(%ebp),%edx
  800a69:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a6b:	85 d2                	test   %edx,%edx
  800a6d:	74 21                	je     800a90 <strlcpy+0x35>
  800a6f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a73:	89 f2                	mov    %esi,%edx
  800a75:	eb 09                	jmp    800a80 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a77:	83 c2 01             	add    $0x1,%edx
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a80:	39 c2                	cmp    %eax,%edx
  800a82:	74 09                	je     800a8d <strlcpy+0x32>
  800a84:	0f b6 19             	movzbl (%ecx),%ebx
  800a87:	84 db                	test   %bl,%bl
  800a89:	75 ec                	jne    800a77 <strlcpy+0x1c>
  800a8b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a8d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a90:	29 f0                	sub    %esi,%eax
}
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a9f:	eb 06                	jmp    800aa7 <strcmp+0x11>
		p++, q++;
  800aa1:	83 c1 01             	add    $0x1,%ecx
  800aa4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aa7:	0f b6 01             	movzbl (%ecx),%eax
  800aaa:	84 c0                	test   %al,%al
  800aac:	74 04                	je     800ab2 <strcmp+0x1c>
  800aae:	3a 02                	cmp    (%edx),%al
  800ab0:	74 ef                	je     800aa1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab2:	0f b6 c0             	movzbl %al,%eax
  800ab5:	0f b6 12             	movzbl (%edx),%edx
  800ab8:	29 d0                	sub    %edx,%eax
}
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac6:	89 c3                	mov    %eax,%ebx
  800ac8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800acb:	eb 06                	jmp    800ad3 <strncmp+0x17>
		n--, p++, q++;
  800acd:	83 c0 01             	add    $0x1,%eax
  800ad0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad3:	39 d8                	cmp    %ebx,%eax
  800ad5:	74 15                	je     800aec <strncmp+0x30>
  800ad7:	0f b6 08             	movzbl (%eax),%ecx
  800ada:	84 c9                	test   %cl,%cl
  800adc:	74 04                	je     800ae2 <strncmp+0x26>
  800ade:	3a 0a                	cmp    (%edx),%cl
  800ae0:	74 eb                	je     800acd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae2:	0f b6 00             	movzbl (%eax),%eax
  800ae5:	0f b6 12             	movzbl (%edx),%edx
  800ae8:	29 d0                	sub    %edx,%eax
  800aea:	eb 05                	jmp    800af1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800afe:	eb 07                	jmp    800b07 <strchr+0x13>
		if (*s == c)
  800b00:	38 ca                	cmp    %cl,%dl
  800b02:	74 0f                	je     800b13 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b04:	83 c0 01             	add    $0x1,%eax
  800b07:	0f b6 10             	movzbl (%eax),%edx
  800b0a:	84 d2                	test   %dl,%dl
  800b0c:	75 f2                	jne    800b00 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b1f:	eb 03                	jmp    800b24 <strfind+0xf>
  800b21:	83 c0 01             	add    $0x1,%eax
  800b24:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b27:	38 ca                	cmp    %cl,%dl
  800b29:	74 04                	je     800b2f <strfind+0x1a>
  800b2b:	84 d2                	test   %dl,%dl
  800b2d:	75 f2                	jne    800b21 <strfind+0xc>
			break;
	return (char *) s;
}
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b3d:	85 c9                	test   %ecx,%ecx
  800b3f:	74 36                	je     800b77 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b41:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b47:	75 28                	jne    800b71 <memset+0x40>
  800b49:	f6 c1 03             	test   $0x3,%cl
  800b4c:	75 23                	jne    800b71 <memset+0x40>
		c &= 0xFF;
  800b4e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b52:	89 d3                	mov    %edx,%ebx
  800b54:	c1 e3 08             	shl    $0x8,%ebx
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	c1 e6 18             	shl    $0x18,%esi
  800b5c:	89 d0                	mov    %edx,%eax
  800b5e:	c1 e0 10             	shl    $0x10,%eax
  800b61:	09 f0                	or     %esi,%eax
  800b63:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b65:	89 d8                	mov    %ebx,%eax
  800b67:	09 d0                	or     %edx,%eax
  800b69:	c1 e9 02             	shr    $0x2,%ecx
  800b6c:	fc                   	cld    
  800b6d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b6f:	eb 06                	jmp    800b77 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b74:	fc                   	cld    
  800b75:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b77:	89 f8                	mov    %edi,%eax
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
  800b86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b8c:	39 c6                	cmp    %eax,%esi
  800b8e:	73 35                	jae    800bc5 <memmove+0x47>
  800b90:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b93:	39 d0                	cmp    %edx,%eax
  800b95:	73 2e                	jae    800bc5 <memmove+0x47>
		s += n;
		d += n;
  800b97:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	09 fe                	or     %edi,%esi
  800b9e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba4:	75 13                	jne    800bb9 <memmove+0x3b>
  800ba6:	f6 c1 03             	test   $0x3,%cl
  800ba9:	75 0e                	jne    800bb9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bab:	83 ef 04             	sub    $0x4,%edi
  800bae:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb1:	c1 e9 02             	shr    $0x2,%ecx
  800bb4:	fd                   	std    
  800bb5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb7:	eb 09                	jmp    800bc2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb9:	83 ef 01             	sub    $0x1,%edi
  800bbc:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bbf:	fd                   	std    
  800bc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc2:	fc                   	cld    
  800bc3:	eb 1d                	jmp    800be2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc5:	89 f2                	mov    %esi,%edx
  800bc7:	09 c2                	or     %eax,%edx
  800bc9:	f6 c2 03             	test   $0x3,%dl
  800bcc:	75 0f                	jne    800bdd <memmove+0x5f>
  800bce:	f6 c1 03             	test   $0x3,%cl
  800bd1:	75 0a                	jne    800bdd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bd3:	c1 e9 02             	shr    $0x2,%ecx
  800bd6:	89 c7                	mov    %eax,%edi
  800bd8:	fc                   	cld    
  800bd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bdb:	eb 05                	jmp    800be2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bdd:	89 c7                	mov    %eax,%edi
  800bdf:	fc                   	cld    
  800be0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800be9:	ff 75 10             	pushl  0x10(%ebp)
  800bec:	ff 75 0c             	pushl  0xc(%ebp)
  800bef:	ff 75 08             	pushl  0x8(%ebp)
  800bf2:	e8 87 ff ff ff       	call   800b7e <memmove>
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c04:	89 c6                	mov    %eax,%esi
  800c06:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c09:	eb 1a                	jmp    800c25 <memcmp+0x2c>
		if (*s1 != *s2)
  800c0b:	0f b6 08             	movzbl (%eax),%ecx
  800c0e:	0f b6 1a             	movzbl (%edx),%ebx
  800c11:	38 d9                	cmp    %bl,%cl
  800c13:	74 0a                	je     800c1f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c15:	0f b6 c1             	movzbl %cl,%eax
  800c18:	0f b6 db             	movzbl %bl,%ebx
  800c1b:	29 d8                	sub    %ebx,%eax
  800c1d:	eb 0f                	jmp    800c2e <memcmp+0x35>
		s1++, s2++;
  800c1f:	83 c0 01             	add    $0x1,%eax
  800c22:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c25:	39 f0                	cmp    %esi,%eax
  800c27:	75 e2                	jne    800c0b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	53                   	push   %ebx
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c39:	89 c1                	mov    %eax,%ecx
  800c3b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c42:	eb 0a                	jmp    800c4e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c44:	0f b6 10             	movzbl (%eax),%edx
  800c47:	39 da                	cmp    %ebx,%edx
  800c49:	74 07                	je     800c52 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4b:	83 c0 01             	add    $0x1,%eax
  800c4e:	39 c8                	cmp    %ecx,%eax
  800c50:	72 f2                	jb     800c44 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c52:	5b                   	pop    %ebx
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c61:	eb 03                	jmp    800c66 <strtol+0x11>
		s++;
  800c63:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c66:	0f b6 01             	movzbl (%ecx),%eax
  800c69:	3c 20                	cmp    $0x20,%al
  800c6b:	74 f6                	je     800c63 <strtol+0xe>
  800c6d:	3c 09                	cmp    $0x9,%al
  800c6f:	74 f2                	je     800c63 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c71:	3c 2b                	cmp    $0x2b,%al
  800c73:	75 0a                	jne    800c7f <strtol+0x2a>
		s++;
  800c75:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c78:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7d:	eb 11                	jmp    800c90 <strtol+0x3b>
  800c7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c84:	3c 2d                	cmp    $0x2d,%al
  800c86:	75 08                	jne    800c90 <strtol+0x3b>
		s++, neg = 1;
  800c88:	83 c1 01             	add    $0x1,%ecx
  800c8b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c90:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c96:	75 15                	jne    800cad <strtol+0x58>
  800c98:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9b:	75 10                	jne    800cad <strtol+0x58>
  800c9d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ca1:	75 7c                	jne    800d1f <strtol+0xca>
		s += 2, base = 16;
  800ca3:	83 c1 02             	add    $0x2,%ecx
  800ca6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cab:	eb 16                	jmp    800cc3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cad:	85 db                	test   %ebx,%ebx
  800caf:	75 12                	jne    800cc3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb9:	75 08                	jne    800cc3 <strtol+0x6e>
		s++, base = 8;
  800cbb:	83 c1 01             	add    $0x1,%ecx
  800cbe:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ccb:	0f b6 11             	movzbl (%ecx),%edx
  800cce:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cd1:	89 f3                	mov    %esi,%ebx
  800cd3:	80 fb 09             	cmp    $0x9,%bl
  800cd6:	77 08                	ja     800ce0 <strtol+0x8b>
			dig = *s - '0';
  800cd8:	0f be d2             	movsbl %dl,%edx
  800cdb:	83 ea 30             	sub    $0x30,%edx
  800cde:	eb 22                	jmp    800d02 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ce0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ce3:	89 f3                	mov    %esi,%ebx
  800ce5:	80 fb 19             	cmp    $0x19,%bl
  800ce8:	77 08                	ja     800cf2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cea:	0f be d2             	movsbl %dl,%edx
  800ced:	83 ea 57             	sub    $0x57,%edx
  800cf0:	eb 10                	jmp    800d02 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cf2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cf5:	89 f3                	mov    %esi,%ebx
  800cf7:	80 fb 19             	cmp    $0x19,%bl
  800cfa:	77 16                	ja     800d12 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cfc:	0f be d2             	movsbl %dl,%edx
  800cff:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d02:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d05:	7d 0b                	jge    800d12 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d07:	83 c1 01             	add    $0x1,%ecx
  800d0a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d0e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d10:	eb b9                	jmp    800ccb <strtol+0x76>

	if (endptr)
  800d12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d16:	74 0d                	je     800d25 <strtol+0xd0>
		*endptr = (char *) s;
  800d18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d1b:	89 0e                	mov    %ecx,(%esi)
  800d1d:	eb 06                	jmp    800d25 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d1f:	85 db                	test   %ebx,%ebx
  800d21:	74 98                	je     800cbb <strtol+0x66>
  800d23:	eb 9e                	jmp    800cc3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d25:	89 c2                	mov    %eax,%edx
  800d27:	f7 da                	neg    %edx
  800d29:	85 ff                	test   %edi,%edi
  800d2b:	0f 45 c2             	cmovne %edx,%eax
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    
  800d33:	66 90                	xchg   %ax,%ax
  800d35:	66 90                	xchg   %ax,%ax
  800d37:	66 90                	xchg   %ax,%ax
  800d39:	66 90                	xchg   %ax,%ax
  800d3b:	66 90                	xchg   %ax,%ax
  800d3d:	66 90                	xchg   %ax,%ax
  800d3f:	90                   	nop

00800d40 <__udivdi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d57:	85 f6                	test   %esi,%esi
  800d59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d5d:	89 ca                	mov    %ecx,%edx
  800d5f:	89 f8                	mov    %edi,%eax
  800d61:	75 3d                	jne    800da0 <__udivdi3+0x60>
  800d63:	39 cf                	cmp    %ecx,%edi
  800d65:	0f 87 c5 00 00 00    	ja     800e30 <__udivdi3+0xf0>
  800d6b:	85 ff                	test   %edi,%edi
  800d6d:	89 fd                	mov    %edi,%ebp
  800d6f:	75 0b                	jne    800d7c <__udivdi3+0x3c>
  800d71:	b8 01 00 00 00       	mov    $0x1,%eax
  800d76:	31 d2                	xor    %edx,%edx
  800d78:	f7 f7                	div    %edi
  800d7a:	89 c5                	mov    %eax,%ebp
  800d7c:	89 c8                	mov    %ecx,%eax
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	f7 f5                	div    %ebp
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	89 d8                	mov    %ebx,%eax
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	f7 f5                	div    %ebp
  800d8a:	89 c3                	mov    %eax,%ebx
  800d8c:	89 d8                	mov    %ebx,%eax
  800d8e:	89 fa                	mov    %edi,%edx
  800d90:	83 c4 1c             	add    $0x1c,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    
  800d98:	90                   	nop
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	39 ce                	cmp    %ecx,%esi
  800da2:	77 74                	ja     800e18 <__udivdi3+0xd8>
  800da4:	0f bd fe             	bsr    %esi,%edi
  800da7:	83 f7 1f             	xor    $0x1f,%edi
  800daa:	0f 84 98 00 00 00    	je     800e48 <__udivdi3+0x108>
  800db0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	89 c5                	mov    %eax,%ebp
  800db9:	29 fb                	sub    %edi,%ebx
  800dbb:	d3 e6                	shl    %cl,%esi
  800dbd:	89 d9                	mov    %ebx,%ecx
  800dbf:	d3 ed                	shr    %cl,%ebp
  800dc1:	89 f9                	mov    %edi,%ecx
  800dc3:	d3 e0                	shl    %cl,%eax
  800dc5:	09 ee                	or     %ebp,%esi
  800dc7:	89 d9                	mov    %ebx,%ecx
  800dc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dcd:	89 d5                	mov    %edx,%ebp
  800dcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dd3:	d3 ed                	shr    %cl,%ebp
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e2                	shl    %cl,%edx
  800dd9:	89 d9                	mov    %ebx,%ecx
  800ddb:	d3 e8                	shr    %cl,%eax
  800ddd:	09 c2                	or     %eax,%edx
  800ddf:	89 d0                	mov    %edx,%eax
  800de1:	89 ea                	mov    %ebp,%edx
  800de3:	f7 f6                	div    %esi
  800de5:	89 d5                	mov    %edx,%ebp
  800de7:	89 c3                	mov    %eax,%ebx
  800de9:	f7 64 24 0c          	mull   0xc(%esp)
  800ded:	39 d5                	cmp    %edx,%ebp
  800def:	72 10                	jb     800e01 <__udivdi3+0xc1>
  800df1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	d3 e6                	shl    %cl,%esi
  800df9:	39 c6                	cmp    %eax,%esi
  800dfb:	73 07                	jae    800e04 <__udivdi3+0xc4>
  800dfd:	39 d5                	cmp    %edx,%ebp
  800dff:	75 03                	jne    800e04 <__udivdi3+0xc4>
  800e01:	83 eb 01             	sub    $0x1,%ebx
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 d8                	mov    %ebx,%eax
  800e08:	89 fa                	mov    %edi,%edx
  800e0a:	83 c4 1c             	add    $0x1c,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
  800e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e18:	31 ff                	xor    %edi,%edi
  800e1a:	31 db                	xor    %ebx,%ebx
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	89 fa                	mov    %edi,%edx
  800e20:	83 c4 1c             	add    $0x1c,%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	89 d8                	mov    %ebx,%eax
  800e32:	f7 f7                	div    %edi
  800e34:	31 ff                	xor    %edi,%edi
  800e36:	89 c3                	mov    %eax,%ebx
  800e38:	89 d8                	mov    %ebx,%eax
  800e3a:	89 fa                	mov    %edi,%edx
  800e3c:	83 c4 1c             	add    $0x1c,%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    
  800e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e48:	39 ce                	cmp    %ecx,%esi
  800e4a:	72 0c                	jb     800e58 <__udivdi3+0x118>
  800e4c:	31 db                	xor    %ebx,%ebx
  800e4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e52:	0f 87 34 ff ff ff    	ja     800d8c <__udivdi3+0x4c>
  800e58:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e5d:	e9 2a ff ff ff       	jmp    800d8c <__udivdi3+0x4c>
  800e62:	66 90                	xchg   %ax,%ax
  800e64:	66 90                	xchg   %ax,%ax
  800e66:	66 90                	xchg   %ax,%ax
  800e68:	66 90                	xchg   %ax,%ax
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__umoddi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 d2                	test   %edx,%edx
  800e89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f3                	mov    %esi,%ebx
  800e93:	89 3c 24             	mov    %edi,(%esp)
  800e96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e9a:	75 1c                	jne    800eb8 <__umoddi3+0x48>
  800e9c:	39 f7                	cmp    %esi,%edi
  800e9e:	76 50                	jbe    800ef0 <__umoddi3+0x80>
  800ea0:	89 c8                	mov    %ecx,%eax
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	f7 f7                	div    %edi
  800ea6:	89 d0                	mov    %edx,%eax
  800ea8:	31 d2                	xor    %edx,%edx
  800eaa:	83 c4 1c             	add    $0x1c,%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
  800eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb8:	39 f2                	cmp    %esi,%edx
  800eba:	89 d0                	mov    %edx,%eax
  800ebc:	77 52                	ja     800f10 <__umoddi3+0xa0>
  800ebe:	0f bd ea             	bsr    %edx,%ebp
  800ec1:	83 f5 1f             	xor    $0x1f,%ebp
  800ec4:	75 5a                	jne    800f20 <__umoddi3+0xb0>
  800ec6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eca:	0f 82 e0 00 00 00    	jb     800fb0 <__umoddi3+0x140>
  800ed0:	39 0c 24             	cmp    %ecx,(%esp)
  800ed3:	0f 86 d7 00 00 00    	jbe    800fb0 <__umoddi3+0x140>
  800ed9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800edd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ee1:	83 c4 1c             	add    $0x1c,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	85 ff                	test   %edi,%edi
  800ef2:	89 fd                	mov    %edi,%ebp
  800ef4:	75 0b                	jne    800f01 <__umoddi3+0x91>
  800ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	f7 f7                	div    %edi
  800eff:	89 c5                	mov    %eax,%ebp
  800f01:	89 f0                	mov    %esi,%eax
  800f03:	31 d2                	xor    %edx,%edx
  800f05:	f7 f5                	div    %ebp
  800f07:	89 c8                	mov    %ecx,%eax
  800f09:	f7 f5                	div    %ebp
  800f0b:	89 d0                	mov    %edx,%eax
  800f0d:	eb 99                	jmp    800ea8 <__umoddi3+0x38>
  800f0f:	90                   	nop
  800f10:	89 c8                	mov    %ecx,%eax
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	83 c4 1c             	add    $0x1c,%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    
  800f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f20:	8b 34 24             	mov    (%esp),%esi
  800f23:	bf 20 00 00 00       	mov    $0x20,%edi
  800f28:	89 e9                	mov    %ebp,%ecx
  800f2a:	29 ef                	sub    %ebp,%edi
  800f2c:	d3 e0                	shl    %cl,%eax
  800f2e:	89 f9                	mov    %edi,%ecx
  800f30:	89 f2                	mov    %esi,%edx
  800f32:	d3 ea                	shr    %cl,%edx
  800f34:	89 e9                	mov    %ebp,%ecx
  800f36:	09 c2                	or     %eax,%edx
  800f38:	89 d8                	mov    %ebx,%eax
  800f3a:	89 14 24             	mov    %edx,(%esp)
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	d3 e2                	shl    %cl,%edx
  800f41:	89 f9                	mov    %edi,%ecx
  800f43:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f4b:	d3 e8                	shr    %cl,%eax
  800f4d:	89 e9                	mov    %ebp,%ecx
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	d3 e3                	shl    %cl,%ebx
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	89 d0                	mov    %edx,%eax
  800f57:	d3 e8                	shr    %cl,%eax
  800f59:	89 e9                	mov    %ebp,%ecx
  800f5b:	09 d8                	or     %ebx,%eax
  800f5d:	89 d3                	mov    %edx,%ebx
  800f5f:	89 f2                	mov    %esi,%edx
  800f61:	f7 34 24             	divl   (%esp)
  800f64:	89 d6                	mov    %edx,%esi
  800f66:	d3 e3                	shl    %cl,%ebx
  800f68:	f7 64 24 04          	mull   0x4(%esp)
  800f6c:	39 d6                	cmp    %edx,%esi
  800f6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f72:	89 d1                	mov    %edx,%ecx
  800f74:	89 c3                	mov    %eax,%ebx
  800f76:	72 08                	jb     800f80 <__umoddi3+0x110>
  800f78:	75 11                	jne    800f8b <__umoddi3+0x11b>
  800f7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f7e:	73 0b                	jae    800f8b <__umoddi3+0x11b>
  800f80:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f84:	1b 14 24             	sbb    (%esp),%edx
  800f87:	89 d1                	mov    %edx,%ecx
  800f89:	89 c3                	mov    %eax,%ebx
  800f8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f8f:	29 da                	sub    %ebx,%edx
  800f91:	19 ce                	sbb    %ecx,%esi
  800f93:	89 f9                	mov    %edi,%ecx
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	d3 e0                	shl    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	d3 ea                	shr    %cl,%edx
  800f9d:	89 e9                	mov    %ebp,%ecx
  800f9f:	d3 ee                	shr    %cl,%esi
  800fa1:	09 d0                	or     %edx,%eax
  800fa3:	89 f2                	mov    %esi,%edx
  800fa5:	83 c4 1c             	add    $0x1c,%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    
  800fad:	8d 76 00             	lea    0x0(%esi),%esi
  800fb0:	29 f9                	sub    %edi,%ecx
  800fb2:	19 d6                	sbb    %edx,%esi
  800fb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fbc:	e9 18 ff ff ff       	jmp    800ed9 <__umoddi3+0x69>
