
obj/user/breakpoint：     文件格式 elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800044:	e8 c6 00 00 00       	call   80010f <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	c1 e0 07             	shl    $0x7,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800085:	6a 00                	push   $0x0
  800087:	e8 42 00 00 00       	call   8000ce <sys_env_destroy>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	57                   	push   %edi
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	89 c6                	mov    %eax,%esi
  8000a8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5f                   	pop    %edi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <sys_cgetc>:

int
sys_cgetc(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	89 d1                	mov    %edx,%ecx
  8000c1:	89 d3                	mov    %edx,%ebx
  8000c3:	89 d7                	mov    %edx,%edi
  8000c5:	89 d6                	mov    %edx,%esi
  8000c7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	89 cb                	mov    %ecx,%ebx
  8000e6:	89 cf                	mov    %ecx,%edi
  8000e8:	89 ce                	mov    %ecx,%esi
  8000ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	7e 17                	jle    800107 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	50                   	push   %eax
  8000f4:	6a 03                	push   $0x3
  8000f6:	68 aa 0f 80 00       	push   $0x800faa
  8000fb:	6a 23                	push   $0x23
  8000fd:	68 c7 0f 80 00       	push   $0x800fc7
  800102:	e8 15 02 00 00       	call   80031c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800115:	ba 00 00 00 00       	mov    $0x0,%edx
  80011a:	b8 02 00 00 00       	mov    $0x2,%eax
  80011f:	89 d1                	mov    %edx,%ecx
  800121:	89 d3                	mov    %edx,%ebx
  800123:	89 d7                	mov    %edx,%edi
  800125:	89 d6                	mov    %edx,%esi
  800127:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_yield>:

void
sys_yield(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	be 00 00 00 00       	mov    $0x0,%esi
  80015b:	b8 04 00 00 00       	mov    $0x4,%eax
  800160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800169:	89 f7                	mov    %esi,%edi
  80016b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016d:	85 c0                	test   %eax,%eax
  80016f:	7e 17                	jle    800188 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	50                   	push   %eax
  800175:	6a 04                	push   $0x4
  800177:	68 aa 0f 80 00       	push   $0x800faa
  80017c:	6a 23                	push   $0x23
  80017e:	68 c7 0f 80 00       	push   $0x800fc7
  800183:	e8 94 01 00 00       	call   80031c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5f                   	pop    %edi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800199:	b8 05 00 00 00       	mov    $0x5,%eax
  80019e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001aa:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	7e 17                	jle    8001ca <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	50                   	push   %eax
  8001b7:	6a 05                	push   $0x5
  8001b9:	68 aa 0f 80 00       	push   $0x800faa
  8001be:	6a 23                	push   $0x23
  8001c0:	68 c7 0f 80 00       	push   $0x800fc7
  8001c5:	e8 52 01 00 00       	call   80031c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	89 df                	mov    %ebx,%edi
  8001ed:	89 de                	mov    %ebx,%esi
  8001ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 17                	jle    80020c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	50                   	push   %eax
  8001f9:	6a 06                	push   $0x6
  8001fb:	68 aa 0f 80 00       	push   $0x800faa
  800200:	6a 23                	push   $0x23
  800202:	68 c7 0f 80 00       	push   $0x800fc7
  800207:	e8 10 01 00 00       	call   80031c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	b8 08 00 00 00       	mov    $0x8,%eax
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 17                	jle    80024e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 08                	push   $0x8
  80023d:	68 aa 0f 80 00       	push   $0x800faa
  800242:	6a 23                	push   $0x23
  800244:	68 c7 0f 80 00       	push   $0x800fc7
  800249:	e8 ce 00 00 00       	call   80031c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	57                   	push   %edi
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
  80025c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800264:	b8 09 00 00 00       	mov    $0x9,%eax
  800269:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	89 df                	mov    %ebx,%edi
  800271:	89 de                	mov    %ebx,%esi
  800273:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800275:	85 c0                	test   %eax,%eax
  800277:	7e 17                	jle    800290 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800279:	83 ec 0c             	sub    $0xc,%esp
  80027c:	50                   	push   %eax
  80027d:	6a 09                	push   $0x9
  80027f:	68 aa 0f 80 00       	push   $0x800faa
  800284:	6a 23                	push   $0x23
  800286:	68 c7 0f 80 00       	push   $0x800fc7
  80028b:	e8 8c 00 00 00       	call   80031c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029e:	be 00 00 00 00       	mov    $0x0,%esi
  8002a3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 cb                	mov    %ecx,%ebx
  8002d3:	89 cf                	mov    %ecx,%edi
  8002d5:	89 ce                	mov    %ecx,%esi
  8002d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7e 17                	jle    8002f4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dd:	83 ec 0c             	sub    $0xc,%esp
  8002e0:	50                   	push   %eax
  8002e1:	6a 0c                	push   $0xc
  8002e3:	68 aa 0f 80 00       	push   $0x800faa
  8002e8:	6a 23                	push   $0x23
  8002ea:	68 c7 0f 80 00       	push   $0x800fc7
  8002ef:	e8 28 00 00 00       	call   80031c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <sys_change_pr>:

int
sys_change_pr(int pr)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	57                   	push   %edi
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800302:	b9 00 00 00 00       	mov    $0x0,%ecx
  800307:	b8 0d 00 00 00       	mov    $0xd,%eax
  80030c:	8b 55 08             	mov    0x8(%ebp),%edx
  80030f:	89 cb                	mov    %ecx,%ebx
  800311:	89 cf                	mov    %ecx,%edi
  800313:	89 ce                	mov    %ecx,%esi
  800315:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800317:	5b                   	pop    %ebx
  800318:	5e                   	pop    %esi
  800319:	5f                   	pop    %edi
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800321:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800324:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80032a:	e8 e0 fd ff ff       	call   80010f <sys_getenvid>
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	ff 75 0c             	pushl  0xc(%ebp)
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	56                   	push   %esi
  800339:	50                   	push   %eax
  80033a:	68 d8 0f 80 00       	push   $0x800fd8
  80033f:	e8 b1 00 00 00       	call   8003f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800344:	83 c4 18             	add    $0x18,%esp
  800347:	53                   	push   %ebx
  800348:	ff 75 10             	pushl  0x10(%ebp)
  80034b:	e8 54 00 00 00       	call   8003a4 <vcprintf>
	cprintf("\n");
  800350:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800357:	e8 99 00 00 00       	call   8003f5 <cprintf>
  80035c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035f:	cc                   	int3   
  800360:	eb fd                	jmp    80035f <_panic+0x43>

00800362 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	53                   	push   %ebx
  800366:	83 ec 04             	sub    $0x4,%esp
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80036c:	8b 13                	mov    (%ebx),%edx
  80036e:	8d 42 01             	lea    0x1(%edx),%eax
  800371:	89 03                	mov    %eax,(%ebx)
  800373:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800376:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80037a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037f:	75 1a                	jne    80039b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	68 ff 00 00 00       	push   $0xff
  800389:	8d 43 08             	lea    0x8(%ebx),%eax
  80038c:	50                   	push   %eax
  80038d:	e8 ff fc ff ff       	call   800091 <sys_cputs>
		b->idx = 0;
  800392:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800398:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80039b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ad:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b4:	00 00 00 
	b.cnt = 0;
  8003b7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003be:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c1:	ff 75 0c             	pushl  0xc(%ebp)
  8003c4:	ff 75 08             	pushl  0x8(%ebp)
  8003c7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003cd:	50                   	push   %eax
  8003ce:	68 62 03 80 00       	push   $0x800362
  8003d3:	e8 54 01 00 00       	call   80052c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d8:	83 c4 08             	add    $0x8,%esp
  8003db:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e7:	50                   	push   %eax
  8003e8:	e8 a4 fc ff ff       	call   800091 <sys_cputs>

	return b.cnt;
}
  8003ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003fe:	50                   	push   %eax
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	e8 9d ff ff ff       	call   8003a4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800407:	c9                   	leave  
  800408:	c3                   	ret    

00800409 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	57                   	push   %edi
  80040d:	56                   	push   %esi
  80040e:	53                   	push   %ebx
  80040f:	83 ec 1c             	sub    $0x1c,%esp
  800412:	89 c7                	mov    %eax,%edi
  800414:	89 d6                	mov    %edx,%esi
  800416:	8b 45 08             	mov    0x8(%ebp),%eax
  800419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800422:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800425:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80042d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800430:	39 d3                	cmp    %edx,%ebx
  800432:	72 05                	jb     800439 <printnum+0x30>
  800434:	39 45 10             	cmp    %eax,0x10(%ebp)
  800437:	77 45                	ja     80047e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800439:	83 ec 0c             	sub    $0xc,%esp
  80043c:	ff 75 18             	pushl  0x18(%ebp)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800445:	53                   	push   %ebx
  800446:	ff 75 10             	pushl  0x10(%ebp)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80044f:	ff 75 e0             	pushl  -0x20(%ebp)
  800452:	ff 75 dc             	pushl  -0x24(%ebp)
  800455:	ff 75 d8             	pushl  -0x28(%ebp)
  800458:	e8 b3 08 00 00       	call   800d10 <__udivdi3>
  80045d:	83 c4 18             	add    $0x18,%esp
  800460:	52                   	push   %edx
  800461:	50                   	push   %eax
  800462:	89 f2                	mov    %esi,%edx
  800464:	89 f8                	mov    %edi,%eax
  800466:	e8 9e ff ff ff       	call   800409 <printnum>
  80046b:	83 c4 20             	add    $0x20,%esp
  80046e:	eb 18                	jmp    800488 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	56                   	push   %esi
  800474:	ff 75 18             	pushl  0x18(%ebp)
  800477:	ff d7                	call   *%edi
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	eb 03                	jmp    800481 <printnum+0x78>
  80047e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800481:	83 eb 01             	sub    $0x1,%ebx
  800484:	85 db                	test   %ebx,%ebx
  800486:	7f e8                	jg     800470 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	56                   	push   %esi
  80048c:	83 ec 04             	sub    $0x4,%esp
  80048f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800492:	ff 75 e0             	pushl  -0x20(%ebp)
  800495:	ff 75 dc             	pushl  -0x24(%ebp)
  800498:	ff 75 d8             	pushl  -0x28(%ebp)
  80049b:	e8 a0 09 00 00       	call   800e40 <__umoddi3>
  8004a0:	83 c4 14             	add    $0x14,%esp
  8004a3:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  8004aa:	50                   	push   %eax
  8004ab:	ff d7                	call   *%edi
}
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b3:	5b                   	pop    %ebx
  8004b4:	5e                   	pop    %esi
  8004b5:	5f                   	pop    %edi
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004bb:	83 fa 01             	cmp    $0x1,%edx
  8004be:	7e 0e                	jle    8004ce <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	8b 52 04             	mov    0x4(%edx),%edx
  8004cc:	eb 22                	jmp    8004f0 <getuint+0x38>
	else if (lflag)
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	74 10                	je     8004e2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d7:	89 08                	mov    %ecx,(%eax)
  8004d9:	8b 02                	mov    (%edx),%eax
  8004db:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e0:	eb 0e                	jmp    8004f0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e2:	8b 10                	mov    (%eax),%edx
  8004e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004fc:	8b 10                	mov    (%eax),%edx
  8004fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800501:	73 0a                	jae    80050d <sprintputch+0x1b>
		*b->buf++ = ch;
  800503:	8d 4a 01             	lea    0x1(%edx),%ecx
  800506:	89 08                	mov    %ecx,(%eax)
  800508:	8b 45 08             	mov    0x8(%ebp),%eax
  80050b:	88 02                	mov    %al,(%edx)
}
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    

0080050f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800515:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800518:	50                   	push   %eax
  800519:	ff 75 10             	pushl  0x10(%ebp)
  80051c:	ff 75 0c             	pushl  0xc(%ebp)
  80051f:	ff 75 08             	pushl  0x8(%ebp)
  800522:	e8 05 00 00 00       	call   80052c <vprintfmt>
	va_end(ap);
}
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	57                   	push   %edi
  800530:	56                   	push   %esi
  800531:	53                   	push   %ebx
  800532:	83 ec 2c             	sub    $0x2c,%esp
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053e:	eb 1d                	jmp    80055d <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800540:	85 c0                	test   %eax,%eax
  800542:	75 0f                	jne    800553 <vprintfmt+0x27>
				csa = 0x0700;
  800544:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80054b:	07 00 00 
				return;
  80054e:	e9 c4 03 00 00       	jmp    800917 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	53                   	push   %ebx
  800557:	50                   	push   %eax
  800558:	ff d6                	call   *%esi
  80055a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055d:	83 c7 01             	add    $0x1,%edi
  800560:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800564:	83 f8 25             	cmp    $0x25,%eax
  800567:	75 d7                	jne    800540 <vprintfmt+0x14>
  800569:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800574:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80057b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800582:	ba 00 00 00 00       	mov    $0x0,%edx
  800587:	eb 07                	jmp    800590 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80058c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8d 47 01             	lea    0x1(%edi),%eax
  800593:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800596:	0f b6 07             	movzbl (%edi),%eax
  800599:	0f b6 c8             	movzbl %al,%ecx
  80059c:	83 e8 23             	sub    $0x23,%eax
  80059f:	3c 55                	cmp    $0x55,%al
  8005a1:	0f 87 55 03 00 00    	ja     8008fc <vprintfmt+0x3d0>
  8005a7:	0f b6 c0             	movzbl %al,%eax
  8005aa:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b8:	eb d6                	jmp    800590 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005cc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005cf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005d2:	83 fa 09             	cmp    $0x9,%edx
  8005d5:	77 39                	ja     800610 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005da:	eb e9                	jmp    8005c5 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 48 04             	lea    0x4(%eax),%ecx
  8005e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ed:	eb 27                	jmp    800616 <vprintfmt+0xea>
  8005ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f9:	0f 49 c8             	cmovns %eax,%ecx
  8005fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800602:	eb 8c                	jmp    800590 <vprintfmt+0x64>
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800607:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060e:	eb 80                	jmp    800590 <vprintfmt+0x64>
  800610:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800613:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800616:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061a:	0f 89 70 ff ff ff    	jns    800590 <vprintfmt+0x64>
				width = precision, precision = -1;
  800620:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800623:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800626:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80062d:	e9 5e ff ff ff       	jmp    800590 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800632:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800638:	e9 53 ff ff ff       	jmp    800590 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	ff 30                	pushl  (%eax)
  80064c:	ff d6                	call   *%esi
			break;
  80064e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800654:	e9 04 ff ff ff       	jmp    80055d <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 50 04             	lea    0x4(%eax),%edx
  80065f:	89 55 14             	mov    %edx,0x14(%ebp)
  800662:	8b 00                	mov    (%eax),%eax
  800664:	99                   	cltd   
  800665:	31 d0                	xor    %edx,%eax
  800667:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800669:	83 f8 08             	cmp    $0x8,%eax
  80066c:	7f 0b                	jg     800679 <vprintfmt+0x14d>
  80066e:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800675:	85 d2                	test   %edx,%edx
  800677:	75 18                	jne    800691 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800679:	50                   	push   %eax
  80067a:	68 16 10 80 00       	push   $0x801016
  80067f:	53                   	push   %ebx
  800680:	56                   	push   %esi
  800681:	e8 89 fe ff ff       	call   80050f <printfmt>
  800686:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80068c:	e9 cc fe ff ff       	jmp    80055d <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800691:	52                   	push   %edx
  800692:	68 1f 10 80 00       	push   $0x80101f
  800697:	53                   	push   %ebx
  800698:	56                   	push   %esi
  800699:	e8 71 fe ff ff       	call   80050f <printfmt>
  80069e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a4:	e9 b4 fe ff ff       	jmp    80055d <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 50 04             	lea    0x4(%eax),%edx
  8006af:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b4:	85 ff                	test   %edi,%edi
  8006b6:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  8006bb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c2:	0f 8e 94 00 00 00    	jle    80075c <vprintfmt+0x230>
  8006c8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006cc:	0f 84 98 00 00 00    	je     80076a <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d8:	57                   	push   %edi
  8006d9:	e8 c1 02 00 00       	call   80099f <strnlen>
  8006de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e1:	29 c1                	sub    %eax,%ecx
  8006e3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f5:	eb 0f                	jmp    800706 <vprintfmt+0x1da>
					putch(padc, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800700:	83 ef 01             	sub    $0x1,%edi
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	85 ff                	test   %edi,%edi
  800708:	7f ed                	jg     8006f7 <vprintfmt+0x1cb>
  80070a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800710:	85 c9                	test   %ecx,%ecx
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	0f 49 c1             	cmovns %ecx,%eax
  80071a:	29 c1                	sub    %eax,%ecx
  80071c:	89 75 08             	mov    %esi,0x8(%ebp)
  80071f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800722:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800725:	89 cb                	mov    %ecx,%ebx
  800727:	eb 4d                	jmp    800776 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800729:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072d:	74 1b                	je     80074a <vprintfmt+0x21e>
  80072f:	0f be c0             	movsbl %al,%eax
  800732:	83 e8 20             	sub    $0x20,%eax
  800735:	83 f8 5e             	cmp    $0x5e,%eax
  800738:	76 10                	jbe    80074a <vprintfmt+0x21e>
					putch('?', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	6a 3f                	push   $0x3f
  800742:	ff 55 08             	call   *0x8(%ebp)
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb 0d                	jmp    800757 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	52                   	push   %edx
  800751:	ff 55 08             	call   *0x8(%ebp)
  800754:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800757:	83 eb 01             	sub    $0x1,%ebx
  80075a:	eb 1a                	jmp    800776 <vprintfmt+0x24a>
  80075c:	89 75 08             	mov    %esi,0x8(%ebp)
  80075f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800762:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800765:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800768:	eb 0c                	jmp    800776 <vprintfmt+0x24a>
  80076a:	89 75 08             	mov    %esi,0x8(%ebp)
  80076d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800770:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800773:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800776:	83 c7 01             	add    $0x1,%edi
  800779:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077d:	0f be d0             	movsbl %al,%edx
  800780:	85 d2                	test   %edx,%edx
  800782:	74 23                	je     8007a7 <vprintfmt+0x27b>
  800784:	85 f6                	test   %esi,%esi
  800786:	78 a1                	js     800729 <vprintfmt+0x1fd>
  800788:	83 ee 01             	sub    $0x1,%esi
  80078b:	79 9c                	jns    800729 <vprintfmt+0x1fd>
  80078d:	89 df                	mov    %ebx,%edi
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800795:	eb 18                	jmp    8007af <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 20                	push   $0x20
  80079d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079f:	83 ef 01             	sub    $0x1,%edi
  8007a2:	83 c4 10             	add    $0x10,%esp
  8007a5:	eb 08                	jmp    8007af <vprintfmt+0x283>
  8007a7:	89 df                	mov    %ebx,%edi
  8007a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007af:	85 ff                	test   %edi,%edi
  8007b1:	7f e4                	jg     800797 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b6:	e9 a2 fd ff ff       	jmp    80055d <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007bb:	83 fa 01             	cmp    $0x1,%edx
  8007be:	7e 16                	jle    8007d6 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	8d 50 08             	lea    0x8(%eax),%edx
  8007c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c9:	8b 50 04             	mov    0x4(%eax),%edx
  8007cc:	8b 00                	mov    (%eax),%eax
  8007ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d4:	eb 32                	jmp    800808 <vprintfmt+0x2dc>
	else if (lflag)
  8007d6:	85 d2                	test   %edx,%edx
  8007d8:	74 18                	je     8007f2 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 50 04             	lea    0x4(%eax),%edx
  8007e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e8:	89 c1                	mov    %eax,%ecx
  8007ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f0:	eb 16                	jmp    800808 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800800:	89 c1                	mov    %eax,%ecx
  800802:	c1 f9 1f             	sar    $0x1f,%ecx
  800805:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800808:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800813:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800817:	79 74                	jns    80088d <vprintfmt+0x361>
				putch('-', putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	53                   	push   %ebx
  80081d:	6a 2d                	push   $0x2d
  80081f:	ff d6                	call   *%esi
				num = -(long long) num;
  800821:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800824:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800827:	f7 d8                	neg    %eax
  800829:	83 d2 00             	adc    $0x0,%edx
  80082c:	f7 da                	neg    %edx
  80082e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800831:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800836:	eb 55                	jmp    80088d <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800838:	8d 45 14             	lea    0x14(%ebp),%eax
  80083b:	e8 78 fc ff ff       	call   8004b8 <getuint>
			base = 10;
  800840:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800845:	eb 46                	jmp    80088d <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
  80084a:	e8 69 fc ff ff       	call   8004b8 <getuint>
      base = 8;
  80084f:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800854:	eb 37                	jmp    80088d <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	53                   	push   %ebx
  80085a:	6a 30                	push   $0x30
  80085c:	ff d6                	call   *%esi
			putch('x', putdat);
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	53                   	push   %ebx
  800862:	6a 78                	push   $0x78
  800864:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80086f:	8b 00                	mov    (%eax),%eax
  800871:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800876:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800879:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80087e:	eb 0d                	jmp    80088d <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800880:	8d 45 14             	lea    0x14(%ebp),%eax
  800883:	e8 30 fc ff ff       	call   8004b8 <getuint>
			base = 16;
  800888:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088d:	83 ec 0c             	sub    $0xc,%esp
  800890:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800894:	57                   	push   %edi
  800895:	ff 75 e0             	pushl  -0x20(%ebp)
  800898:	51                   	push   %ecx
  800899:	52                   	push   %edx
  80089a:	50                   	push   %eax
  80089b:	89 da                	mov    %ebx,%edx
  80089d:	89 f0                	mov    %esi,%eax
  80089f:	e8 65 fb ff ff       	call   800409 <printnum>
			break;
  8008a4:	83 c4 20             	add    $0x20,%esp
  8008a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008aa:	e9 ae fc ff ff       	jmp    80055d <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008af:	83 ec 08             	sub    $0x8,%esp
  8008b2:	53                   	push   %ebx
  8008b3:	51                   	push   %ecx
  8008b4:	ff d6                	call   *%esi
			break;
  8008b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008bc:	e9 9c fc ff ff       	jmp    80055d <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c1:	83 fa 01             	cmp    $0x1,%edx
  8008c4:	7e 0d                	jle    8008d3 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c9:	8d 50 08             	lea    0x8(%eax),%edx
  8008cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cf:	8b 00                	mov    (%eax),%eax
  8008d1:	eb 1c                	jmp    8008ef <vprintfmt+0x3c3>
	else if (lflag)
  8008d3:	85 d2                	test   %edx,%edx
  8008d5:	74 0d                	je     8008e4 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8d 50 04             	lea    0x4(%eax),%edx
  8008dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e0:	8b 00                	mov    (%eax),%eax
  8008e2:	eb 0b                	jmp    8008ef <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ed:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8008ef:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8008f7:	e9 61 fc ff ff       	jmp    80055d <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	53                   	push   %ebx
  800900:	6a 25                	push   $0x25
  800902:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb 03                	jmp    80090c <vprintfmt+0x3e0>
  800909:	83 ef 01             	sub    $0x1,%edi
  80090c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800910:	75 f7                	jne    800909 <vprintfmt+0x3dd>
  800912:	e9 46 fc ff ff       	jmp    80055d <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800917:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5f                   	pop    %edi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 18             	sub    $0x18,%esp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800932:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800935:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093c:	85 c0                	test   %eax,%eax
  80093e:	74 26                	je     800966 <vsnprintf+0x47>
  800940:	85 d2                	test   %edx,%edx
  800942:	7e 22                	jle    800966 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800944:	ff 75 14             	pushl  0x14(%ebp)
  800947:	ff 75 10             	pushl  0x10(%ebp)
  80094a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094d:	50                   	push   %eax
  80094e:	68 f2 04 80 00       	push   $0x8004f2
  800953:	e8 d4 fb ff ff       	call   80052c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800958:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	83 c4 10             	add    $0x10,%esp
  800964:	eb 05                	jmp    80096b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800966:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    

0080096d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800973:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800976:	50                   	push   %eax
  800977:	ff 75 10             	pushl  0x10(%ebp)
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	ff 75 08             	pushl  0x8(%ebp)
  800980:	e8 9a ff ff ff       	call   80091f <vsnprintf>
	va_end(ap);

	return rc;
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
  800992:	eb 03                	jmp    800997 <strlen+0x10>
		n++;
  800994:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800997:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80099b:	75 f7                	jne    800994 <strlen+0xd>
		n++;
	return n;
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ad:	eb 03                	jmp    8009b2 <strnlen+0x13>
		n++;
  8009af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b2:	39 c2                	cmp    %eax,%edx
  8009b4:	74 08                	je     8009be <strnlen+0x1f>
  8009b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009ba:	75 f3                	jne    8009af <strnlen+0x10>
  8009bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009ca:	89 c2                	mov    %eax,%edx
  8009cc:	83 c2 01             	add    $0x1,%edx
  8009cf:	83 c1 01             	add    $0x1,%ecx
  8009d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d9:	84 db                	test   %bl,%bl
  8009db:	75 ef                	jne    8009cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	53                   	push   %ebx
  8009e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e7:	53                   	push   %ebx
  8009e8:	e8 9a ff ff ff       	call   800987 <strlen>
  8009ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009f0:	ff 75 0c             	pushl  0xc(%ebp)
  8009f3:	01 d8                	add    %ebx,%eax
  8009f5:	50                   	push   %eax
  8009f6:	e8 c5 ff ff ff       	call   8009c0 <strcpy>
	return dst;
}
  8009fb:	89 d8                	mov    %ebx,%eax
  8009fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a12:	89 f2                	mov    %esi,%edx
  800a14:	eb 0f                	jmp    800a25 <strncpy+0x23>
		*dst++ = *src;
  800a16:	83 c2 01             	add    $0x1,%edx
  800a19:	0f b6 01             	movzbl (%ecx),%eax
  800a1c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a1f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a22:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a25:	39 da                	cmp    %ebx,%edx
  800a27:	75 ed                	jne    800a16 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a29:	89 f0                	mov    %esi,%eax
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 75 08             	mov    0x8(%ebp),%esi
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3a:	8b 55 10             	mov    0x10(%ebp),%edx
  800a3d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a3f:	85 d2                	test   %edx,%edx
  800a41:	74 21                	je     800a64 <strlcpy+0x35>
  800a43:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a47:	89 f2                	mov    %esi,%edx
  800a49:	eb 09                	jmp    800a54 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a4b:	83 c2 01             	add    $0x1,%edx
  800a4e:	83 c1 01             	add    $0x1,%ecx
  800a51:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a54:	39 c2                	cmp    %eax,%edx
  800a56:	74 09                	je     800a61 <strlcpy+0x32>
  800a58:	0f b6 19             	movzbl (%ecx),%ebx
  800a5b:	84 db                	test   %bl,%bl
  800a5d:	75 ec                	jne    800a4b <strlcpy+0x1c>
  800a5f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a61:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a64:	29 f0                	sub    %esi,%eax
}
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a70:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a73:	eb 06                	jmp    800a7b <strcmp+0x11>
		p++, q++;
  800a75:	83 c1 01             	add    $0x1,%ecx
  800a78:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a7b:	0f b6 01             	movzbl (%ecx),%eax
  800a7e:	84 c0                	test   %al,%al
  800a80:	74 04                	je     800a86 <strcmp+0x1c>
  800a82:	3a 02                	cmp    (%edx),%al
  800a84:	74 ef                	je     800a75 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a86:	0f b6 c0             	movzbl %al,%eax
  800a89:	0f b6 12             	movzbl (%edx),%edx
  800a8c:	29 d0                	sub    %edx,%eax
}
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	53                   	push   %ebx
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9a:	89 c3                	mov    %eax,%ebx
  800a9c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a9f:	eb 06                	jmp    800aa7 <strncmp+0x17>
		n--, p++, q++;
  800aa1:	83 c0 01             	add    $0x1,%eax
  800aa4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa7:	39 d8                	cmp    %ebx,%eax
  800aa9:	74 15                	je     800ac0 <strncmp+0x30>
  800aab:	0f b6 08             	movzbl (%eax),%ecx
  800aae:	84 c9                	test   %cl,%cl
  800ab0:	74 04                	je     800ab6 <strncmp+0x26>
  800ab2:	3a 0a                	cmp    (%edx),%cl
  800ab4:	74 eb                	je     800aa1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab6:	0f b6 00             	movzbl (%eax),%eax
  800ab9:	0f b6 12             	movzbl (%edx),%edx
  800abc:	29 d0                	sub    %edx,%eax
  800abe:	eb 05                	jmp    800ac5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad2:	eb 07                	jmp    800adb <strchr+0x13>
		if (*s == c)
  800ad4:	38 ca                	cmp    %cl,%dl
  800ad6:	74 0f                	je     800ae7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad8:	83 c0 01             	add    $0x1,%eax
  800adb:	0f b6 10             	movzbl (%eax),%edx
  800ade:	84 d2                	test   %dl,%dl
  800ae0:	75 f2                	jne    800ad4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af3:	eb 03                	jmp    800af8 <strfind+0xf>
  800af5:	83 c0 01             	add    $0x1,%eax
  800af8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800afb:	38 ca                	cmp    %cl,%dl
  800afd:	74 04                	je     800b03 <strfind+0x1a>
  800aff:	84 d2                	test   %dl,%dl
  800b01:	75 f2                	jne    800af5 <strfind+0xc>
			break;
	return (char *) s;
}
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b11:	85 c9                	test   %ecx,%ecx
  800b13:	74 36                	je     800b4b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1b:	75 28                	jne    800b45 <memset+0x40>
  800b1d:	f6 c1 03             	test   $0x3,%cl
  800b20:	75 23                	jne    800b45 <memset+0x40>
		c &= 0xFF;
  800b22:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b26:	89 d3                	mov    %edx,%ebx
  800b28:	c1 e3 08             	shl    $0x8,%ebx
  800b2b:	89 d6                	mov    %edx,%esi
  800b2d:	c1 e6 18             	shl    $0x18,%esi
  800b30:	89 d0                	mov    %edx,%eax
  800b32:	c1 e0 10             	shl    $0x10,%eax
  800b35:	09 f0                	or     %esi,%eax
  800b37:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b39:	89 d8                	mov    %ebx,%eax
  800b3b:	09 d0                	or     %edx,%eax
  800b3d:	c1 e9 02             	shr    $0x2,%ecx
  800b40:	fc                   	cld    
  800b41:	f3 ab                	rep stos %eax,%es:(%edi)
  800b43:	eb 06                	jmp    800b4b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b48:	fc                   	cld    
  800b49:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b4b:	89 f8                	mov    %edi,%eax
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b60:	39 c6                	cmp    %eax,%esi
  800b62:	73 35                	jae    800b99 <memmove+0x47>
  800b64:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b67:	39 d0                	cmp    %edx,%eax
  800b69:	73 2e                	jae    800b99 <memmove+0x47>
		s += n;
		d += n;
  800b6b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6e:	89 d6                	mov    %edx,%esi
  800b70:	09 fe                	or     %edi,%esi
  800b72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b78:	75 13                	jne    800b8d <memmove+0x3b>
  800b7a:	f6 c1 03             	test   $0x3,%cl
  800b7d:	75 0e                	jne    800b8d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b7f:	83 ef 04             	sub    $0x4,%edi
  800b82:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b85:	c1 e9 02             	shr    $0x2,%ecx
  800b88:	fd                   	std    
  800b89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8b:	eb 09                	jmp    800b96 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8d:	83 ef 01             	sub    $0x1,%edi
  800b90:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b93:	fd                   	std    
  800b94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b96:	fc                   	cld    
  800b97:	eb 1d                	jmp    800bb6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b99:	89 f2                	mov    %esi,%edx
  800b9b:	09 c2                	or     %eax,%edx
  800b9d:	f6 c2 03             	test   $0x3,%dl
  800ba0:	75 0f                	jne    800bb1 <memmove+0x5f>
  800ba2:	f6 c1 03             	test   $0x3,%cl
  800ba5:	75 0a                	jne    800bb1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ba7:	c1 e9 02             	shr    $0x2,%ecx
  800baa:	89 c7                	mov    %eax,%edi
  800bac:	fc                   	cld    
  800bad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800baf:	eb 05                	jmp    800bb6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb1:	89 c7                	mov    %eax,%edi
  800bb3:	fc                   	cld    
  800bb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bbd:	ff 75 10             	pushl  0x10(%ebp)
  800bc0:	ff 75 0c             	pushl  0xc(%ebp)
  800bc3:	ff 75 08             	pushl  0x8(%ebp)
  800bc6:	e8 87 ff ff ff       	call   800b52 <memmove>
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd8:	89 c6                	mov    %eax,%esi
  800bda:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdd:	eb 1a                	jmp    800bf9 <memcmp+0x2c>
		if (*s1 != *s2)
  800bdf:	0f b6 08             	movzbl (%eax),%ecx
  800be2:	0f b6 1a             	movzbl (%edx),%ebx
  800be5:	38 d9                	cmp    %bl,%cl
  800be7:	74 0a                	je     800bf3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800be9:	0f b6 c1             	movzbl %cl,%eax
  800bec:	0f b6 db             	movzbl %bl,%ebx
  800bef:	29 d8                	sub    %ebx,%eax
  800bf1:	eb 0f                	jmp    800c02 <memcmp+0x35>
		s1++, s2++;
  800bf3:	83 c0 01             	add    $0x1,%eax
  800bf6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf9:	39 f0                	cmp    %esi,%eax
  800bfb:	75 e2                	jne    800bdf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	53                   	push   %ebx
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c0d:	89 c1                	mov    %eax,%ecx
  800c0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c12:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c16:	eb 0a                	jmp    800c22 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c18:	0f b6 10             	movzbl (%eax),%edx
  800c1b:	39 da                	cmp    %ebx,%edx
  800c1d:	74 07                	je     800c26 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1f:	83 c0 01             	add    $0x1,%eax
  800c22:	39 c8                	cmp    %ecx,%eax
  800c24:	72 f2                	jb     800c18 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c26:	5b                   	pop    %ebx
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c35:	eb 03                	jmp    800c3a <strtol+0x11>
		s++;
  800c37:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3a:	0f b6 01             	movzbl (%ecx),%eax
  800c3d:	3c 20                	cmp    $0x20,%al
  800c3f:	74 f6                	je     800c37 <strtol+0xe>
  800c41:	3c 09                	cmp    $0x9,%al
  800c43:	74 f2                	je     800c37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c45:	3c 2b                	cmp    $0x2b,%al
  800c47:	75 0a                	jne    800c53 <strtol+0x2a>
		s++;
  800c49:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c51:	eb 11                	jmp    800c64 <strtol+0x3b>
  800c53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c58:	3c 2d                	cmp    $0x2d,%al
  800c5a:	75 08                	jne    800c64 <strtol+0x3b>
		s++, neg = 1;
  800c5c:	83 c1 01             	add    $0x1,%ecx
  800c5f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c6a:	75 15                	jne    800c81 <strtol+0x58>
  800c6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6f:	75 10                	jne    800c81 <strtol+0x58>
  800c71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c75:	75 7c                	jne    800cf3 <strtol+0xca>
		s += 2, base = 16;
  800c77:	83 c1 02             	add    $0x2,%ecx
  800c7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c7f:	eb 16                	jmp    800c97 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c81:	85 db                	test   %ebx,%ebx
  800c83:	75 12                	jne    800c97 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c8d:	75 08                	jne    800c97 <strtol+0x6e>
		s++, base = 8;
  800c8f:	83 c1 01             	add    $0x1,%ecx
  800c92:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c97:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c9f:	0f b6 11             	movzbl (%ecx),%edx
  800ca2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ca5:	89 f3                	mov    %esi,%ebx
  800ca7:	80 fb 09             	cmp    $0x9,%bl
  800caa:	77 08                	ja     800cb4 <strtol+0x8b>
			dig = *s - '0';
  800cac:	0f be d2             	movsbl %dl,%edx
  800caf:	83 ea 30             	sub    $0x30,%edx
  800cb2:	eb 22                	jmp    800cd6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cb4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb7:	89 f3                	mov    %esi,%ebx
  800cb9:	80 fb 19             	cmp    $0x19,%bl
  800cbc:	77 08                	ja     800cc6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cbe:	0f be d2             	movsbl %dl,%edx
  800cc1:	83 ea 57             	sub    $0x57,%edx
  800cc4:	eb 10                	jmp    800cd6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cc6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cc9:	89 f3                	mov    %esi,%ebx
  800ccb:	80 fb 19             	cmp    $0x19,%bl
  800cce:	77 16                	ja     800ce6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cd0:	0f be d2             	movsbl %dl,%edx
  800cd3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cd6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cd9:	7d 0b                	jge    800ce6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cdb:	83 c1 01             	add    $0x1,%ecx
  800cde:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ce2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ce4:	eb b9                	jmp    800c9f <strtol+0x76>

	if (endptr)
  800ce6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cea:	74 0d                	je     800cf9 <strtol+0xd0>
		*endptr = (char *) s;
  800cec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cef:	89 0e                	mov    %ecx,(%esi)
  800cf1:	eb 06                	jmp    800cf9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf3:	85 db                	test   %ebx,%ebx
  800cf5:	74 98                	je     800c8f <strtol+0x66>
  800cf7:	eb 9e                	jmp    800c97 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cf9:	89 c2                	mov    %eax,%edx
  800cfb:	f7 da                	neg    %edx
  800cfd:	85 ff                	test   %edi,%edi
  800cff:	0f 45 c2             	cmovne %edx,%eax
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    
  800d07:	66 90                	xchg   %ax,%ax
  800d09:	66 90                	xchg   %ax,%ax
  800d0b:	66 90                	xchg   %ax,%ax
  800d0d:	66 90                	xchg   %ax,%ax
  800d0f:	90                   	nop

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
