
obj/user/faultnostack：     文件格式 elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 37 03 80 00       	push   $0x800337
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	c1 e0 07             	shl    $0x7,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 6a 10 80 00       	push   $0x80106a
  800116:	6a 23                	push   $0x23
  800118:	68 87 10 80 00       	push   $0x801087
  80011d:	e8 39 02 00 00       	call   80035b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 6a 10 80 00       	push   $0x80106a
  800197:	6a 23                	push   $0x23
  800199:	68 87 10 80 00       	push   $0x801087
  80019e:	e8 b8 01 00 00       	call   80035b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 6a 10 80 00       	push   $0x80106a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 87 10 80 00       	push   $0x801087
  8001e0:	e8 76 01 00 00       	call   80035b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 6a 10 80 00       	push   $0x80106a
  80021b:	6a 23                	push   $0x23
  80021d:	68 87 10 80 00       	push   $0x801087
  800222:	e8 34 01 00 00       	call   80035b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 6a 10 80 00       	push   $0x80106a
  80025d:	6a 23                	push   $0x23
  80025f:	68 87 10 80 00       	push   $0x801087
  800264:	e8 f2 00 00 00       	call   80035b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 6a 10 80 00       	push   $0x80106a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 87 10 80 00       	push   $0x801087
  8002a6:	e8 b0 00 00 00       	call   80035b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	be 00 00 00 00       	mov    $0x0,%esi
  8002be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 6a 10 80 00       	push   $0x80106a
  800303:	6a 23                	push   $0x23
  800305:	68 87 10 80 00       	push   $0x801087
  80030a:	e8 4c 00 00 00       	call   80035b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	57                   	push   %edi
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800322:	b8 0d 00 00 00       	mov    $0xd,%eax
  800327:	8b 55 08             	mov    0x8(%ebp),%edx
  80032a:	89 cb                	mov    %ecx,%ebx
  80032c:	89 cf                	mov    %ecx,%edi
  80032e:	89 ce                	mov    %ecx,%esi
  800330:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800332:	5b                   	pop    %ebx
  800333:	5e                   	pop    %esi
  800334:	5f                   	pop    %edi
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800337:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800338:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80033d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80033f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  800342:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  800346:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  80034b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  80034f:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  800351:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800354:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  800355:	83 c4 04             	add    $0x4,%esp
	popfl
  800358:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800359:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80035a:	c3                   	ret    

0080035b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	56                   	push   %esi
  80035f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800360:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800363:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800369:	e8 bc fd ff ff       	call   80012a <sys_getenvid>
  80036e:	83 ec 0c             	sub    $0xc,%esp
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	56                   	push   %esi
  800378:	50                   	push   %eax
  800379:	68 98 10 80 00       	push   $0x801098
  80037e:	e8 b1 00 00 00       	call   800434 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800383:	83 c4 18             	add    $0x18,%esp
  800386:	53                   	push   %ebx
  800387:	ff 75 10             	pushl  0x10(%ebp)
  80038a:	e8 54 00 00 00       	call   8003e3 <vcprintf>
	cprintf("\n");
  80038f:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  800396:	e8 99 00 00 00       	call   800434 <cprintf>
  80039b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80039e:	cc                   	int3   
  80039f:	eb fd                	jmp    80039e <_panic+0x43>

008003a1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 04             	sub    $0x4,%esp
  8003a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ab:	8b 13                	mov    (%ebx),%edx
  8003ad:	8d 42 01             	lea    0x1(%edx),%eax
  8003b0:	89 03                	mov    %eax,(%ebx)
  8003b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003be:	75 1a                	jne    8003da <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	68 ff 00 00 00       	push   $0xff
  8003c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8003cb:	50                   	push   %eax
  8003cc:	e8 db fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003da:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003f3:	00 00 00 
	b.cnt = 0;
  8003f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800400:	ff 75 0c             	pushl  0xc(%ebp)
  800403:	ff 75 08             	pushl  0x8(%ebp)
  800406:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80040c:	50                   	push   %eax
  80040d:	68 a1 03 80 00       	push   $0x8003a1
  800412:	e8 54 01 00 00       	call   80056b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800417:	83 c4 08             	add    $0x8,%esp
  80041a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800420:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800426:	50                   	push   %eax
  800427:	e8 80 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80042c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80043d:	50                   	push   %eax
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 9d ff ff ff       	call   8003e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800446:	c9                   	leave  
  800447:	c3                   	ret    

00800448 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 1c             	sub    $0x1c,%esp
  800451:	89 c7                	mov    %eax,%edi
  800453:	89 d6                	mov    %edx,%esi
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800461:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800464:	bb 00 00 00 00       	mov    $0x0,%ebx
  800469:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80046c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80046f:	39 d3                	cmp    %edx,%ebx
  800471:	72 05                	jb     800478 <printnum+0x30>
  800473:	39 45 10             	cmp    %eax,0x10(%ebp)
  800476:	77 45                	ja     8004bd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800478:	83 ec 0c             	sub    $0xc,%esp
  80047b:	ff 75 18             	pushl  0x18(%ebp)
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800484:	53                   	push   %ebx
  800485:	ff 75 10             	pushl  0x10(%ebp)
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048e:	ff 75 e0             	pushl  -0x20(%ebp)
  800491:	ff 75 dc             	pushl  -0x24(%ebp)
  800494:	ff 75 d8             	pushl  -0x28(%ebp)
  800497:	e8 24 09 00 00       	call   800dc0 <__udivdi3>
  80049c:	83 c4 18             	add    $0x18,%esp
  80049f:	52                   	push   %edx
  8004a0:	50                   	push   %eax
  8004a1:	89 f2                	mov    %esi,%edx
  8004a3:	89 f8                	mov    %edi,%eax
  8004a5:	e8 9e ff ff ff       	call   800448 <printnum>
  8004aa:	83 c4 20             	add    $0x20,%esp
  8004ad:	eb 18                	jmp    8004c7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	ff 75 18             	pushl  0x18(%ebp)
  8004b6:	ff d7                	call   *%edi
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb 03                	jmp    8004c0 <printnum+0x78>
  8004bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c0:	83 eb 01             	sub    $0x1,%ebx
  8004c3:	85 db                	test   %ebx,%ebx
  8004c5:	7f e8                	jg     8004af <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	56                   	push   %esi
  8004cb:	83 ec 04             	sub    $0x4,%esp
  8004ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004da:	e8 11 0a 00 00       	call   800ef0 <__umoddi3>
  8004df:	83 c4 14             	add    $0x14,%esp
  8004e2:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  8004e9:	50                   	push   %eax
  8004ea:	ff d7                	call   *%edi
}
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004f2:	5b                   	pop    %ebx
  8004f3:	5e                   	pop    %esi
  8004f4:	5f                   	pop    %edi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004fa:	83 fa 01             	cmp    $0x1,%edx
  8004fd:	7e 0e                	jle    80050d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ff:	8b 10                	mov    (%eax),%edx
  800501:	8d 4a 08             	lea    0x8(%edx),%ecx
  800504:	89 08                	mov    %ecx,(%eax)
  800506:	8b 02                	mov    (%edx),%eax
  800508:	8b 52 04             	mov    0x4(%edx),%edx
  80050b:	eb 22                	jmp    80052f <getuint+0x38>
	else if (lflag)
  80050d:	85 d2                	test   %edx,%edx
  80050f:	74 10                	je     800521 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800511:	8b 10                	mov    (%eax),%edx
  800513:	8d 4a 04             	lea    0x4(%edx),%ecx
  800516:	89 08                	mov    %ecx,(%eax)
  800518:	8b 02                	mov    (%edx),%eax
  80051a:	ba 00 00 00 00       	mov    $0x0,%edx
  80051f:	eb 0e                	jmp    80052f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800521:	8b 10                	mov    (%eax),%edx
  800523:	8d 4a 04             	lea    0x4(%edx),%ecx
  800526:	89 08                	mov    %ecx,(%eax)
  800528:	8b 02                	mov    (%edx),%eax
  80052a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800537:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80053b:	8b 10                	mov    (%eax),%edx
  80053d:	3b 50 04             	cmp    0x4(%eax),%edx
  800540:	73 0a                	jae    80054c <sprintputch+0x1b>
		*b->buf++ = ch;
  800542:	8d 4a 01             	lea    0x1(%edx),%ecx
  800545:	89 08                	mov    %ecx,(%eax)
  800547:	8b 45 08             	mov    0x8(%ebp),%eax
  80054a:	88 02                	mov    %al,(%edx)
}
  80054c:	5d                   	pop    %ebp
  80054d:	c3                   	ret    

0080054e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800554:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800557:	50                   	push   %eax
  800558:	ff 75 10             	pushl  0x10(%ebp)
  80055b:	ff 75 0c             	pushl  0xc(%ebp)
  80055e:	ff 75 08             	pushl  0x8(%ebp)
  800561:	e8 05 00 00 00       	call   80056b <vprintfmt>
	va_end(ap);
}
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	c9                   	leave  
  80056a:	c3                   	ret    

0080056b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80056b:	55                   	push   %ebp
  80056c:	89 e5                	mov    %esp,%ebp
  80056e:	57                   	push   %edi
  80056f:	56                   	push   %esi
  800570:	53                   	push   %ebx
  800571:	83 ec 2c             	sub    $0x2c,%esp
  800574:	8b 75 08             	mov    0x8(%ebp),%esi
  800577:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80057d:	eb 1d                	jmp    80059c <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80057f:	85 c0                	test   %eax,%eax
  800581:	75 0f                	jne    800592 <vprintfmt+0x27>
				csa = 0x0700;
  800583:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80058a:	07 00 00 
				return;
  80058d:	e9 c4 03 00 00       	jmp    800956 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	50                   	push   %eax
  800597:	ff d6                	call   *%esi
  800599:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	83 f8 25             	cmp    $0x25,%eax
  8005a6:	75 d7                	jne    80057f <vprintfmt+0x14>
  8005a8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c6:	eb 07                	jmp    8005cf <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005cb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8d 47 01             	lea    0x1(%edi),%eax
  8005d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d5:	0f b6 07             	movzbl (%edi),%eax
  8005d8:	0f b6 c8             	movzbl %al,%ecx
  8005db:	83 e8 23             	sub    $0x23,%eax
  8005de:	3c 55                	cmp    $0x55,%al
  8005e0:	0f 87 55 03 00 00    	ja     80093b <vprintfmt+0x3d0>
  8005e6:	0f b6 c0             	movzbl %al,%eax
  8005e9:	ff 24 85 80 11 80 00 	jmp    *0x801180(,%eax,4)
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005f3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005f7:	eb d6                	jmp    8005cf <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800601:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800604:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800607:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80060b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80060e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800611:	83 fa 09             	cmp    $0x9,%edx
  800614:	77 39                	ja     80064f <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800616:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800619:	eb e9                	jmp    800604 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 48 04             	lea    0x4(%eax),%ecx
  800621:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80062c:	eb 27                	jmp    800655 <vprintfmt+0xea>
  80062e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800631:	85 c0                	test   %eax,%eax
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
  800638:	0f 49 c8             	cmovns %eax,%ecx
  80063b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	eb 8c                	jmp    8005cf <vprintfmt+0x64>
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800646:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80064d:	eb 80                	jmp    8005cf <vprintfmt+0x64>
  80064f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800652:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800655:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800659:	0f 89 70 ff ff ff    	jns    8005cf <vprintfmt+0x64>
				width = precision, precision = -1;
  80065f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800662:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800665:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80066c:	e9 5e ff ff ff       	jmp    8005cf <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800671:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800677:	e9 53 ff ff ff       	jmp    8005cf <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	ff 30                	pushl  (%eax)
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
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800693:	e9 04 ff ff ff       	jmp    80059c <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	99                   	cltd   
  8006a4:	31 d0                	xor    %edx,%eax
  8006a6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a8:	83 f8 08             	cmp    $0x8,%eax
  8006ab:	7f 0b                	jg     8006b8 <vprintfmt+0x14d>
  8006ad:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  8006b4:	85 d2                	test   %edx,%edx
  8006b6:	75 18                	jne    8006d0 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8006b8:	50                   	push   %eax
  8006b9:	68 d5 10 80 00       	push   $0x8010d5
  8006be:	53                   	push   %ebx
  8006bf:	56                   	push   %esi
  8006c0:	e8 89 fe ff ff       	call   80054e <printfmt>
  8006c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006cb:	e9 cc fe ff ff       	jmp    80059c <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8006d0:	52                   	push   %edx
  8006d1:	68 de 10 80 00       	push   $0x8010de
  8006d6:	53                   	push   %ebx
  8006d7:	56                   	push   %esi
  8006d8:	e8 71 fe ff ff       	call   80054e <printfmt>
  8006dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e3:	e9 b4 fe ff ff       	jmp    80059c <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006f3:	85 ff                	test   %edi,%edi
  8006f5:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  8006fa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800701:	0f 8e 94 00 00 00    	jle    80079b <vprintfmt+0x230>
  800707:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80070b:	0f 84 98 00 00 00    	je     8007a9 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	ff 75 d0             	pushl  -0x30(%ebp)
  800717:	57                   	push   %edi
  800718:	e8 c1 02 00 00       	call   8009de <strnlen>
  80071d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800720:	29 c1                	sub    %eax,%ecx
  800722:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800725:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800728:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80072c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80072f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800732:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800734:	eb 0f                	jmp    800745 <vprintfmt+0x1da>
					putch(padc, putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	ff 75 e0             	pushl  -0x20(%ebp)
  80073d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80073f:	83 ef 01             	sub    $0x1,%edi
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	85 ff                	test   %edi,%edi
  800747:	7f ed                	jg     800736 <vprintfmt+0x1cb>
  800749:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80074c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80074f:	85 c9                	test   %ecx,%ecx
  800751:	b8 00 00 00 00       	mov    $0x0,%eax
  800756:	0f 49 c1             	cmovns %ecx,%eax
  800759:	29 c1                	sub    %eax,%ecx
  80075b:	89 75 08             	mov    %esi,0x8(%ebp)
  80075e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800761:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800764:	89 cb                	mov    %ecx,%ebx
  800766:	eb 4d                	jmp    8007b5 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800768:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80076c:	74 1b                	je     800789 <vprintfmt+0x21e>
  80076e:	0f be c0             	movsbl %al,%eax
  800771:	83 e8 20             	sub    $0x20,%eax
  800774:	83 f8 5e             	cmp    $0x5e,%eax
  800777:	76 10                	jbe    800789 <vprintfmt+0x21e>
					putch('?', putdat);
  800779:	83 ec 08             	sub    $0x8,%esp
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	6a 3f                	push   $0x3f
  800781:	ff 55 08             	call   *0x8(%ebp)
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 0d                	jmp    800796 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	52                   	push   %edx
  800790:	ff 55 08             	call   *0x8(%ebp)
  800793:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800796:	83 eb 01             	sub    $0x1,%ebx
  800799:	eb 1a                	jmp    8007b5 <vprintfmt+0x24a>
  80079b:	89 75 08             	mov    %esi,0x8(%ebp)
  80079e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007a7:	eb 0c                	jmp    8007b5 <vprintfmt+0x24a>
  8007a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8007ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007b5:	83 c7 01             	add    $0x1,%edi
  8007b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007bc:	0f be d0             	movsbl %al,%edx
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	74 23                	je     8007e6 <vprintfmt+0x27b>
  8007c3:	85 f6                	test   %esi,%esi
  8007c5:	78 a1                	js     800768 <vprintfmt+0x1fd>
  8007c7:	83 ee 01             	sub    $0x1,%esi
  8007ca:	79 9c                	jns    800768 <vprintfmt+0x1fd>
  8007cc:	89 df                	mov    %ebx,%edi
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d4:	eb 18                	jmp    8007ee <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	53                   	push   %ebx
  8007da:	6a 20                	push   $0x20
  8007dc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007de:	83 ef 01             	sub    $0x1,%edi
  8007e1:	83 c4 10             	add    $0x10,%esp
  8007e4:	eb 08                	jmp    8007ee <vprintfmt+0x283>
  8007e6:	89 df                	mov    %ebx,%edi
  8007e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ee:	85 ff                	test   %edi,%edi
  8007f0:	7f e4                	jg     8007d6 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f5:	e9 a2 fd ff ff       	jmp    80059c <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007fa:	83 fa 01             	cmp    $0x1,%edx
  8007fd:	7e 16                	jle    800815 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8d 50 08             	lea    0x8(%eax),%edx
  800805:	89 55 14             	mov    %edx,0x14(%ebp)
  800808:	8b 50 04             	mov    0x4(%eax),%edx
  80080b:	8b 00                	mov    (%eax),%eax
  80080d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800810:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800813:	eb 32                	jmp    800847 <vprintfmt+0x2dc>
	else if (lflag)
  800815:	85 d2                	test   %edx,%edx
  800817:	74 18                	je     800831 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8d 50 04             	lea    0x4(%eax),%edx
  80081f:	89 55 14             	mov    %edx,0x14(%ebp)
  800822:	8b 00                	mov    (%eax),%eax
  800824:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800827:	89 c1                	mov    %eax,%ecx
  800829:	c1 f9 1f             	sar    $0x1f,%ecx
  80082c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80082f:	eb 16                	jmp    800847 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8d 50 04             	lea    0x4(%eax),%edx
  800837:	89 55 14             	mov    %edx,0x14(%ebp)
  80083a:	8b 00                	mov    (%eax),%eax
  80083c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083f:	89 c1                	mov    %eax,%ecx
  800841:	c1 f9 1f             	sar    $0x1f,%ecx
  800844:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800847:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80084a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80084d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800852:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800856:	79 74                	jns    8008cc <vprintfmt+0x361>
				putch('-', putdat);
  800858:	83 ec 08             	sub    $0x8,%esp
  80085b:	53                   	push   %ebx
  80085c:	6a 2d                	push   $0x2d
  80085e:	ff d6                	call   *%esi
				num = -(long long) num;
  800860:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800863:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800866:	f7 d8                	neg    %eax
  800868:	83 d2 00             	adc    $0x0,%edx
  80086b:	f7 da                	neg    %edx
  80086d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800870:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800875:	eb 55                	jmp    8008cc <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800877:	8d 45 14             	lea    0x14(%ebp),%eax
  80087a:	e8 78 fc ff ff       	call   8004f7 <getuint>
			base = 10;
  80087f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800884:	eb 46                	jmp    8008cc <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800886:	8d 45 14             	lea    0x14(%ebp),%eax
  800889:	e8 69 fc ff ff       	call   8004f7 <getuint>
      base = 8;
  80088e:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800893:	eb 37                	jmp    8008cc <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	6a 30                	push   $0x30
  80089b:	ff d6                	call   *%esi
			putch('x', putdat);
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	6a 78                	push   $0x78
  8008a3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	8d 50 04             	lea    0x4(%eax),%edx
  8008ab:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ae:	8b 00                	mov    (%eax),%eax
  8008b0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008bd:	eb 0d                	jmp    8008cc <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c2:	e8 30 fc ff ff       	call   8004f7 <getuint>
			base = 16;
  8008c7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008cc:	83 ec 0c             	sub    $0xc,%esp
  8008cf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d3:	57                   	push   %edi
  8008d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d7:	51                   	push   %ecx
  8008d8:	52                   	push   %edx
  8008d9:	50                   	push   %eax
  8008da:	89 da                	mov    %ebx,%edx
  8008dc:	89 f0                	mov    %esi,%eax
  8008de:	e8 65 fb ff ff       	call   800448 <printnum>
			break;
  8008e3:	83 c4 20             	add    $0x20,%esp
  8008e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008e9:	e9 ae fc ff ff       	jmp    80059c <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ee:	83 ec 08             	sub    $0x8,%esp
  8008f1:	53                   	push   %ebx
  8008f2:	51                   	push   %ecx
  8008f3:	ff d6                	call   *%esi
			break;
  8008f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008fb:	e9 9c fc ff ff       	jmp    80059c <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800900:	83 fa 01             	cmp    $0x1,%edx
  800903:	7e 0d                	jle    800912 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8d 50 08             	lea    0x8(%eax),%edx
  80090b:	89 55 14             	mov    %edx,0x14(%ebp)
  80090e:	8b 00                	mov    (%eax),%eax
  800910:	eb 1c                	jmp    80092e <vprintfmt+0x3c3>
	else if (lflag)
  800912:	85 d2                	test   %edx,%edx
  800914:	74 0d                	je     800923 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  800916:	8b 45 14             	mov    0x14(%ebp),%eax
  800919:	8d 50 04             	lea    0x4(%eax),%edx
  80091c:	89 55 14             	mov    %edx,0x14(%ebp)
  80091f:	8b 00                	mov    (%eax),%eax
  800921:	eb 0b                	jmp    80092e <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8d 50 04             	lea    0x4(%eax),%edx
  800929:	89 55 14             	mov    %edx,0x14(%ebp)
  80092c:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  80092e:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800933:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800936:	e9 61 fc ff ff       	jmp    80059c <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	53                   	push   %ebx
  80093f:	6a 25                	push   $0x25
  800941:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800943:	83 c4 10             	add    $0x10,%esp
  800946:	eb 03                	jmp    80094b <vprintfmt+0x3e0>
  800948:	83 ef 01             	sub    $0x1,%edi
  80094b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80094f:	75 f7                	jne    800948 <vprintfmt+0x3dd>
  800951:	e9 46 fc ff ff       	jmp    80059c <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800956:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800959:	5b                   	pop    %ebx
  80095a:	5e                   	pop    %esi
  80095b:	5f                   	pop    %edi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 18             	sub    $0x18,%esp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80096a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80096d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800971:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800974:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80097b:	85 c0                	test   %eax,%eax
  80097d:	74 26                	je     8009a5 <vsnprintf+0x47>
  80097f:	85 d2                	test   %edx,%edx
  800981:	7e 22                	jle    8009a5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800983:	ff 75 14             	pushl  0x14(%ebp)
  800986:	ff 75 10             	pushl  0x10(%ebp)
  800989:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80098c:	50                   	push   %eax
  80098d:	68 31 05 80 00       	push   $0x800531
  800992:	e8 d4 fb ff ff       	call   80056b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800997:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80099a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80099d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a0:	83 c4 10             	add    $0x10,%esp
  8009a3:	eb 05                	jmp    8009aa <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b5:	50                   	push   %eax
  8009b6:	ff 75 10             	pushl  0x10(%ebp)
  8009b9:	ff 75 0c             	pushl  0xc(%ebp)
  8009bc:	ff 75 08             	pushl  0x8(%ebp)
  8009bf:	e8 9a ff ff ff       	call   80095e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d1:	eb 03                	jmp    8009d6 <strlen+0x10>
		n++;
  8009d3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009da:	75 f7                	jne    8009d3 <strlen+0xd>
		n++;
	return n;
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ec:	eb 03                	jmp    8009f1 <strnlen+0x13>
		n++;
  8009ee:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f1:	39 c2                	cmp    %eax,%edx
  8009f3:	74 08                	je     8009fd <strnlen+0x1f>
  8009f5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009f9:	75 f3                	jne    8009ee <strnlen+0x10>
  8009fb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a09:	89 c2                	mov    %eax,%edx
  800a0b:	83 c2 01             	add    $0x1,%edx
  800a0e:	83 c1 01             	add    $0x1,%ecx
  800a11:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a15:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a18:	84 db                	test   %bl,%bl
  800a1a:	75 ef                	jne    800a0b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	53                   	push   %ebx
  800a23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a26:	53                   	push   %ebx
  800a27:	e8 9a ff ff ff       	call   8009c6 <strlen>
  800a2c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a2f:	ff 75 0c             	pushl  0xc(%ebp)
  800a32:	01 d8                	add    %ebx,%eax
  800a34:	50                   	push   %eax
  800a35:	e8 c5 ff ff ff       	call   8009ff <strcpy>
	return dst;
}
  800a3a:	89 d8                	mov    %ebx,%eax
  800a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    

00800a41 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 75 08             	mov    0x8(%ebp),%esi
  800a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4c:	89 f3                	mov    %esi,%ebx
  800a4e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a51:	89 f2                	mov    %esi,%edx
  800a53:	eb 0f                	jmp    800a64 <strncpy+0x23>
		*dst++ = *src;
  800a55:	83 c2 01             	add    $0x1,%edx
  800a58:	0f b6 01             	movzbl (%ecx),%eax
  800a5b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a5e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a61:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a64:	39 da                	cmp    %ebx,%edx
  800a66:	75 ed                	jne    800a55 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a68:	89 f0                	mov    %esi,%eax
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 75 08             	mov    0x8(%ebp),%esi
  800a76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a79:	8b 55 10             	mov    0x10(%ebp),%edx
  800a7c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a7e:	85 d2                	test   %edx,%edx
  800a80:	74 21                	je     800aa3 <strlcpy+0x35>
  800a82:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a86:	89 f2                	mov    %esi,%edx
  800a88:	eb 09                	jmp    800a93 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a8a:	83 c2 01             	add    $0x1,%edx
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a93:	39 c2                	cmp    %eax,%edx
  800a95:	74 09                	je     800aa0 <strlcpy+0x32>
  800a97:	0f b6 19             	movzbl (%ecx),%ebx
  800a9a:	84 db                	test   %bl,%bl
  800a9c:	75 ec                	jne    800a8a <strlcpy+0x1c>
  800a9e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800aa0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa3:	29 f0                	sub    %esi,%eax
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ab2:	eb 06                	jmp    800aba <strcmp+0x11>
		p++, q++;
  800ab4:	83 c1 01             	add    $0x1,%ecx
  800ab7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aba:	0f b6 01             	movzbl (%ecx),%eax
  800abd:	84 c0                	test   %al,%al
  800abf:	74 04                	je     800ac5 <strcmp+0x1c>
  800ac1:	3a 02                	cmp    (%edx),%al
  800ac3:	74 ef                	je     800ab4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac5:	0f b6 c0             	movzbl %al,%eax
  800ac8:	0f b6 12             	movzbl (%edx),%edx
  800acb:	29 d0                	sub    %edx,%eax
}
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	53                   	push   %ebx
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad9:	89 c3                	mov    %eax,%ebx
  800adb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ade:	eb 06                	jmp    800ae6 <strncmp+0x17>
		n--, p++, q++;
  800ae0:	83 c0 01             	add    $0x1,%eax
  800ae3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ae6:	39 d8                	cmp    %ebx,%eax
  800ae8:	74 15                	je     800aff <strncmp+0x30>
  800aea:	0f b6 08             	movzbl (%eax),%ecx
  800aed:	84 c9                	test   %cl,%cl
  800aef:	74 04                	je     800af5 <strncmp+0x26>
  800af1:	3a 0a                	cmp    (%edx),%cl
  800af3:	74 eb                	je     800ae0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af5:	0f b6 00             	movzbl (%eax),%eax
  800af8:	0f b6 12             	movzbl (%edx),%edx
  800afb:	29 d0                	sub    %edx,%eax
  800afd:	eb 05                	jmp    800b04 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b11:	eb 07                	jmp    800b1a <strchr+0x13>
		if (*s == c)
  800b13:	38 ca                	cmp    %cl,%dl
  800b15:	74 0f                	je     800b26 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b17:	83 c0 01             	add    $0x1,%eax
  800b1a:	0f b6 10             	movzbl (%eax),%edx
  800b1d:	84 d2                	test   %dl,%dl
  800b1f:	75 f2                	jne    800b13 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b32:	eb 03                	jmp    800b37 <strfind+0xf>
  800b34:	83 c0 01             	add    $0x1,%eax
  800b37:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b3a:	38 ca                	cmp    %cl,%dl
  800b3c:	74 04                	je     800b42 <strfind+0x1a>
  800b3e:	84 d2                	test   %dl,%dl
  800b40:	75 f2                	jne    800b34 <strfind+0xc>
			break;
	return (char *) s;
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b50:	85 c9                	test   %ecx,%ecx
  800b52:	74 36                	je     800b8a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5a:	75 28                	jne    800b84 <memset+0x40>
  800b5c:	f6 c1 03             	test   $0x3,%cl
  800b5f:	75 23                	jne    800b84 <memset+0x40>
		c &= 0xFF;
  800b61:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	c1 e3 08             	shl    $0x8,%ebx
  800b6a:	89 d6                	mov    %edx,%esi
  800b6c:	c1 e6 18             	shl    $0x18,%esi
  800b6f:	89 d0                	mov    %edx,%eax
  800b71:	c1 e0 10             	shl    $0x10,%eax
  800b74:	09 f0                	or     %esi,%eax
  800b76:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b78:	89 d8                	mov    %ebx,%eax
  800b7a:	09 d0                	or     %edx,%eax
  800b7c:	c1 e9 02             	shr    $0x2,%ecx
  800b7f:	fc                   	cld    
  800b80:	f3 ab                	rep stos %eax,%es:(%edi)
  800b82:	eb 06                	jmp    800b8a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	fc                   	cld    
  800b88:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b8a:	89 f8                	mov    %edi,%eax
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	8b 45 08             	mov    0x8(%ebp),%eax
  800b99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b9f:	39 c6                	cmp    %eax,%esi
  800ba1:	73 35                	jae    800bd8 <memmove+0x47>
  800ba3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba6:	39 d0                	cmp    %edx,%eax
  800ba8:	73 2e                	jae    800bd8 <memmove+0x47>
		s += n;
		d += n;
  800baa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	09 fe                	or     %edi,%esi
  800bb1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb7:	75 13                	jne    800bcc <memmove+0x3b>
  800bb9:	f6 c1 03             	test   $0x3,%cl
  800bbc:	75 0e                	jne    800bcc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bbe:	83 ef 04             	sub    $0x4,%edi
  800bc1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc4:	c1 e9 02             	shr    $0x2,%ecx
  800bc7:	fd                   	std    
  800bc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bca:	eb 09                	jmp    800bd5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bcc:	83 ef 01             	sub    $0x1,%edi
  800bcf:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bd2:	fd                   	std    
  800bd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd5:	fc                   	cld    
  800bd6:	eb 1d                	jmp    800bf5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd8:	89 f2                	mov    %esi,%edx
  800bda:	09 c2                	or     %eax,%edx
  800bdc:	f6 c2 03             	test   $0x3,%dl
  800bdf:	75 0f                	jne    800bf0 <memmove+0x5f>
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 0a                	jne    800bf0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800be6:	c1 e9 02             	shr    $0x2,%ecx
  800be9:	89 c7                	mov    %eax,%edi
  800beb:	fc                   	cld    
  800bec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bee:	eb 05                	jmp    800bf5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf0:	89 c7                	mov    %eax,%edi
  800bf2:	fc                   	cld    
  800bf3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bfc:	ff 75 10             	pushl  0x10(%ebp)
  800bff:	ff 75 0c             	pushl  0xc(%ebp)
  800c02:	ff 75 08             	pushl  0x8(%ebp)
  800c05:	e8 87 ff ff ff       	call   800b91 <memmove>
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c17:	89 c6                	mov    %eax,%esi
  800c19:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1c:	eb 1a                	jmp    800c38 <memcmp+0x2c>
		if (*s1 != *s2)
  800c1e:	0f b6 08             	movzbl (%eax),%ecx
  800c21:	0f b6 1a             	movzbl (%edx),%ebx
  800c24:	38 d9                	cmp    %bl,%cl
  800c26:	74 0a                	je     800c32 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c28:	0f b6 c1             	movzbl %cl,%eax
  800c2b:	0f b6 db             	movzbl %bl,%ebx
  800c2e:	29 d8                	sub    %ebx,%eax
  800c30:	eb 0f                	jmp    800c41 <memcmp+0x35>
		s1++, s2++;
  800c32:	83 c0 01             	add    $0x1,%eax
  800c35:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c38:	39 f0                	cmp    %esi,%eax
  800c3a:	75 e2                	jne    800c1e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	53                   	push   %ebx
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c4c:	89 c1                	mov    %eax,%ecx
  800c4e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c51:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c55:	eb 0a                	jmp    800c61 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c57:	0f b6 10             	movzbl (%eax),%edx
  800c5a:	39 da                	cmp    %ebx,%edx
  800c5c:	74 07                	je     800c65 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c5e:	83 c0 01             	add    $0x1,%eax
  800c61:	39 c8                	cmp    %ecx,%eax
  800c63:	72 f2                	jb     800c57 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c65:	5b                   	pop    %ebx
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c74:	eb 03                	jmp    800c79 <strtol+0x11>
		s++;
  800c76:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c79:	0f b6 01             	movzbl (%ecx),%eax
  800c7c:	3c 20                	cmp    $0x20,%al
  800c7e:	74 f6                	je     800c76 <strtol+0xe>
  800c80:	3c 09                	cmp    $0x9,%al
  800c82:	74 f2                	je     800c76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c84:	3c 2b                	cmp    $0x2b,%al
  800c86:	75 0a                	jne    800c92 <strtol+0x2a>
		s++;
  800c88:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c90:	eb 11                	jmp    800ca3 <strtol+0x3b>
  800c92:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c97:	3c 2d                	cmp    $0x2d,%al
  800c99:	75 08                	jne    800ca3 <strtol+0x3b>
		s++, neg = 1;
  800c9b:	83 c1 01             	add    $0x1,%ecx
  800c9e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ca9:	75 15                	jne    800cc0 <strtol+0x58>
  800cab:	80 39 30             	cmpb   $0x30,(%ecx)
  800cae:	75 10                	jne    800cc0 <strtol+0x58>
  800cb0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cb4:	75 7c                	jne    800d32 <strtol+0xca>
		s += 2, base = 16;
  800cb6:	83 c1 02             	add    $0x2,%ecx
  800cb9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cbe:	eb 16                	jmp    800cd6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cc0:	85 db                	test   %ebx,%ebx
  800cc2:	75 12                	jne    800cd6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc9:	80 39 30             	cmpb   $0x30,(%ecx)
  800ccc:	75 08                	jne    800cd6 <strtol+0x6e>
		s++, base = 8;
  800cce:	83 c1 01             	add    $0x1,%ecx
  800cd1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cde:	0f b6 11             	movzbl (%ecx),%edx
  800ce1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ce4:	89 f3                	mov    %esi,%ebx
  800ce6:	80 fb 09             	cmp    $0x9,%bl
  800ce9:	77 08                	ja     800cf3 <strtol+0x8b>
			dig = *s - '0';
  800ceb:	0f be d2             	movsbl %dl,%edx
  800cee:	83 ea 30             	sub    $0x30,%edx
  800cf1:	eb 22                	jmp    800d15 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cf3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cf6:	89 f3                	mov    %esi,%ebx
  800cf8:	80 fb 19             	cmp    $0x19,%bl
  800cfb:	77 08                	ja     800d05 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cfd:	0f be d2             	movsbl %dl,%edx
  800d00:	83 ea 57             	sub    $0x57,%edx
  800d03:	eb 10                	jmp    800d15 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d05:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d08:	89 f3                	mov    %esi,%ebx
  800d0a:	80 fb 19             	cmp    $0x19,%bl
  800d0d:	77 16                	ja     800d25 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d0f:	0f be d2             	movsbl %dl,%edx
  800d12:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d15:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d18:	7d 0b                	jge    800d25 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d1a:	83 c1 01             	add    $0x1,%ecx
  800d1d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d21:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d23:	eb b9                	jmp    800cde <strtol+0x76>

	if (endptr)
  800d25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d29:	74 0d                	je     800d38 <strtol+0xd0>
		*endptr = (char *) s;
  800d2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d2e:	89 0e                	mov    %ecx,(%esi)
  800d30:	eb 06                	jmp    800d38 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d32:	85 db                	test   %ebx,%ebx
  800d34:	74 98                	je     800cce <strtol+0x66>
  800d36:	eb 9e                	jmp    800cd6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d38:	89 c2                	mov    %eax,%edx
  800d3a:	f7 da                	neg    %edx
  800d3c:	85 ff                	test   %edi,%edi
  800d3e:	0f 45 c2             	cmovne %edx,%eax
}
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  800d4c:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800d53:	75 2c                	jne    800d81 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800d55:	83 ec 04             	sub    $0x4,%esp
  800d58:	6a 07                	push   $0x7
  800d5a:	68 00 f0 bf ee       	push   $0xeebff000
  800d5f:	6a 00                	push   $0x0
  800d61:	e8 02 f4 ff ff       	call   800168 <sys_page_alloc>
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	79 14                	jns    800d81 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	68 04 13 80 00       	push   $0x801304
  800d75:	6a 21                	push   $0x21
  800d77:	68 68 13 80 00       	push   $0x801368
  800d7c:	e8 da f5 ff ff       	call   80035b <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d89:	83 ec 08             	sub    $0x8,%esp
  800d8c:	68 37 03 80 00       	push   $0x800337
  800d91:	6a 00                	push   $0x0
  800d93:	e8 d9 f4 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	79 14                	jns    800db3 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	68 30 13 80 00       	push   $0x801330
  800da7:	6a 26                	push   $0x26
  800da9:	68 68 13 80 00       	push   $0x801368
  800dae:	e8 a8 f5 ff ff       	call   80035b <_panic>
}
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    
  800db5:	66 90                	xchg   %ax,%ax
  800db7:	66 90                	xchg   %ax,%ax
  800db9:	66 90                	xchg   %ax,%ax
  800dbb:	66 90                	xchg   %ax,%ax
  800dbd:	66 90                	xchg   %ax,%ax
  800dbf:	90                   	nop

00800dc0 <__udivdi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 f6                	test   %esi,%esi
  800dd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ddd:	89 ca                	mov    %ecx,%edx
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	75 3d                	jne    800e20 <__udivdi3+0x60>
  800de3:	39 cf                	cmp    %ecx,%edi
  800de5:	0f 87 c5 00 00 00    	ja     800eb0 <__udivdi3+0xf0>
  800deb:	85 ff                	test   %edi,%edi
  800ded:	89 fd                	mov    %edi,%ebp
  800def:	75 0b                	jne    800dfc <__udivdi3+0x3c>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	31 d2                	xor    %edx,%edx
  800df8:	f7 f7                	div    %edi
  800dfa:	89 c5                	mov    %eax,%ebp
  800dfc:	89 c8                	mov    %ecx,%eax
  800dfe:	31 d2                	xor    %edx,%edx
  800e00:	f7 f5                	div    %ebp
  800e02:	89 c1                	mov    %eax,%ecx
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	f7 f5                	div    %ebp
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
  800e18:	90                   	nop
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	39 ce                	cmp    %ecx,%esi
  800e22:	77 74                	ja     800e98 <__udivdi3+0xd8>
  800e24:	0f bd fe             	bsr    %esi,%edi
  800e27:	83 f7 1f             	xor    $0x1f,%edi
  800e2a:	0f 84 98 00 00 00    	je     800ec8 <__udivdi3+0x108>
  800e30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	89 c5                	mov    %eax,%ebp
  800e39:	29 fb                	sub    %edi,%ebx
  800e3b:	d3 e6                	shl    %cl,%esi
  800e3d:	89 d9                	mov    %ebx,%ecx
  800e3f:	d3 ed                	shr    %cl,%ebp
  800e41:	89 f9                	mov    %edi,%ecx
  800e43:	d3 e0                	shl    %cl,%eax
  800e45:	09 ee                	or     %ebp,%esi
  800e47:	89 d9                	mov    %ebx,%ecx
  800e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4d:	89 d5                	mov    %edx,%ebp
  800e4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e53:	d3 ed                	shr    %cl,%ebp
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e2                	shl    %cl,%edx
  800e59:	89 d9                	mov    %ebx,%ecx
  800e5b:	d3 e8                	shr    %cl,%eax
  800e5d:	09 c2                	or     %eax,%edx
  800e5f:	89 d0                	mov    %edx,%eax
  800e61:	89 ea                	mov    %ebp,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 d5                	mov    %edx,%ebp
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	f7 64 24 0c          	mull   0xc(%esp)
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	72 10                	jb     800e81 <__udivdi3+0xc1>
  800e71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e6                	shl    %cl,%esi
  800e79:	39 c6                	cmp    %eax,%esi
  800e7b:	73 07                	jae    800e84 <__udivdi3+0xc4>
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	75 03                	jne    800e84 <__udivdi3+0xc4>
  800e81:	83 eb 01             	sub    $0x1,%ebx
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	31 ff                	xor    %edi,%edi
  800e9a:	31 db                	xor    %ebx,%ebx
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	89 fa                	mov    %edi,%edx
  800ea0:	83 c4 1c             	add    $0x1c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
  800ea8:	90                   	nop
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	f7 f7                	div    %edi
  800eb4:	31 ff                	xor    %edi,%edi
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	89 fa                	mov    %edi,%edx
  800ebc:	83 c4 1c             	add    $0x1c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	39 ce                	cmp    %ecx,%esi
  800eca:	72 0c                	jb     800ed8 <__udivdi3+0x118>
  800ecc:	31 db                	xor    %ebx,%ebx
  800ece:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ed2:	0f 87 34 ff ff ff    	ja     800e0c <__udivdi3+0x4c>
  800ed8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800edd:	e9 2a ff ff ff       	jmp    800e0c <__udivdi3+0x4c>
  800ee2:	66 90                	xchg   %ax,%ax
  800ee4:	66 90                	xchg   %ax,%ax
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	66 90                	xchg   %ax,%ax
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800efb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 d2                	test   %edx,%edx
  800f09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f3                	mov    %esi,%ebx
  800f13:	89 3c 24             	mov    %edi,(%esp)
  800f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1a:	75 1c                	jne    800f38 <__umoddi3+0x48>
  800f1c:	39 f7                	cmp    %esi,%edi
  800f1e:	76 50                	jbe    800f70 <__umoddi3+0x80>
  800f20:	89 c8                	mov    %ecx,%eax
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	f7 f7                	div    %edi
  800f26:	89 d0                	mov    %edx,%eax
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	83 c4 1c             	add    $0x1c,%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    
  800f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	89 d0                	mov    %edx,%eax
  800f3c:	77 52                	ja     800f90 <__umoddi3+0xa0>
  800f3e:	0f bd ea             	bsr    %edx,%ebp
  800f41:	83 f5 1f             	xor    $0x1f,%ebp
  800f44:	75 5a                	jne    800fa0 <__umoddi3+0xb0>
  800f46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f4a:	0f 82 e0 00 00 00    	jb     801030 <__umoddi3+0x140>
  800f50:	39 0c 24             	cmp    %ecx,(%esp)
  800f53:	0f 86 d7 00 00 00    	jbe    801030 <__umoddi3+0x140>
  800f59:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f61:	83 c4 1c             	add    $0x1c,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	85 ff                	test   %edi,%edi
  800f72:	89 fd                	mov    %edi,%ebp
  800f74:	75 0b                	jne    800f81 <__umoddi3+0x91>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f7                	div    %edi
  800f7f:	89 c5                	mov    %eax,%ebp
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f5                	div    %ebp
  800f87:	89 c8                	mov    %ecx,%eax
  800f89:	f7 f5                	div    %ebp
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	eb 99                	jmp    800f28 <__umoddi3+0x38>
  800f8f:	90                   	nop
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	83 c4 1c             	add    $0x1c,%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	8b 34 24             	mov    (%esp),%esi
  800fa3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	29 ef                	sub    %ebp,%edi
  800fac:	d3 e0                	shl    %cl,%eax
  800fae:	89 f9                	mov    %edi,%ecx
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	d3 ea                	shr    %cl,%edx
  800fb4:	89 e9                	mov    %ebp,%ecx
  800fb6:	09 c2                	or     %eax,%edx
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	89 14 24             	mov    %edx,(%esp)
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	d3 e2                	shl    %cl,%edx
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	d3 e3                	shl    %cl,%ebx
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	89 d0                	mov    %edx,%eax
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	09 d8                	or     %ebx,%eax
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 f2                	mov    %esi,%edx
  800fe1:	f7 34 24             	divl   (%esp)
  800fe4:	89 d6                	mov    %edx,%esi
  800fe6:	d3 e3                	shl    %cl,%ebx
  800fe8:	f7 64 24 04          	mull   0x4(%esp)
  800fec:	39 d6                	cmp    %edx,%esi
  800fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ff2:	89 d1                	mov    %edx,%ecx
  800ff4:	89 c3                	mov    %eax,%ebx
  800ff6:	72 08                	jb     801000 <__umoddi3+0x110>
  800ff8:	75 11                	jne    80100b <__umoddi3+0x11b>
  800ffa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800ffe:	73 0b                	jae    80100b <__umoddi3+0x11b>
  801000:	2b 44 24 04          	sub    0x4(%esp),%eax
  801004:	1b 14 24             	sbb    (%esp),%edx
  801007:	89 d1                	mov    %edx,%ecx
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80100f:	29 da                	sub    %ebx,%edx
  801011:	19 ce                	sbb    %ecx,%esi
  801013:	89 f9                	mov    %edi,%ecx
  801015:	89 f0                	mov    %esi,%eax
  801017:	d3 e0                	shl    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	d3 ea                	shr    %cl,%edx
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	d3 ee                	shr    %cl,%esi
  801021:	09 d0                	or     %edx,%eax
  801023:	89 f2                	mov    %esi,%edx
  801025:	83 c4 1c             	add    $0x1c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	29 f9                	sub    %edi,%ecx
  801032:	19 d6                	sbb    %edx,%esi
  801034:	89 74 24 04          	mov    %esi,0x4(%esp)
  801038:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103c:	e9 18 ff ff ff       	jmp    800f59 <__umoddi3+0x69>
