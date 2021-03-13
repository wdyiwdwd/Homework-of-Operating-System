
obj/user/badsegment：     文件格式 elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800049:	e8 c6 00 00 00       	call   800114 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	c1 e0 07             	shl    $0x7,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 17                	jle    80010c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 aa 0f 80 00       	push   $0x800faa
  800100:	6a 23                	push   $0x23
  800102:	68 c7 0f 80 00       	push   $0x800fc7
  800107:	e8 15 02 00 00       	call   800321 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_yield>:

void
sys_yield(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	b8 04 00 00 00       	mov    $0x4,%eax
  800165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7e 17                	jle    80018d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	50                   	push   %eax
  80017a:	6a 04                	push   $0x4
  80017c:	68 aa 0f 80 00       	push   $0x800faa
  800181:	6a 23                	push   $0x23
  800183:	68 c7 0f 80 00       	push   $0x800fc7
  800188:	e8 94 01 00 00       	call   800321 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019e:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001af:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7e 17                	jle    8001cf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 05                	push   $0x5
  8001be:	68 aa 0f 80 00       	push   $0x800faa
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 c7 0f 80 00       	push   $0x800fc7
  8001ca:	e8 52 01 00 00       	call   800321 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	89 df                	mov    %ebx,%edi
  8001f2:	89 de                	mov    %ebx,%esi
  8001f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 17                	jle    800211 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 06                	push   $0x6
  800200:	68 aa 0f 80 00       	push   $0x800faa
  800205:	6a 23                	push   $0x23
  800207:	68 c7 0f 80 00       	push   $0x800fc7
  80020c:	e8 10 01 00 00       	call   800321 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	b8 08 00 00 00       	mov    $0x8,%eax
  80022c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7e 17                	jle    800253 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 08                	push   $0x8
  800242:	68 aa 0f 80 00       	push   $0x800faa
  800247:	6a 23                	push   $0x23
  800249:	68 c7 0f 80 00       	push   $0x800fc7
  80024e:	e8 ce 00 00 00       	call   800321 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	b8 09 00 00 00       	mov    $0x9,%eax
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7e 17                	jle    800295 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 09                	push   $0x9
  800284:	68 aa 0f 80 00       	push   $0x800faa
  800289:	6a 23                	push   $0x23
  80028b:	68 c7 0f 80 00       	push   $0x800fc7
  800290:	e8 8c 00 00 00       	call   800321 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a3:	be 00 00 00 00       	mov    $0x0,%esi
  8002a8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ce:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	89 cb                	mov    %ecx,%ebx
  8002d8:	89 cf                	mov    %ecx,%edi
  8002da:	89 ce                	mov    %ecx,%esi
  8002dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7e 17                	jle    8002f9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 0c                	push   $0xc
  8002e8:	68 aa 0f 80 00       	push   $0x800faa
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 c7 0f 80 00       	push   $0x800fc7
  8002f4:	e8 28 00 00 00       	call   800321 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	57                   	push   %edi
  800305:	56                   	push   %esi
  800306:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800307:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800311:	8b 55 08             	mov    0x8(%ebp),%edx
  800314:	89 cb                	mov    %ecx,%ebx
  800316:	89 cf                	mov    %ecx,%edi
  800318:	89 ce                	mov    %ecx,%esi
  80031a:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800326:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800329:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80032f:	e8 e0 fd ff ff       	call   800114 <sys_getenvid>
  800334:	83 ec 0c             	sub    $0xc,%esp
  800337:	ff 75 0c             	pushl  0xc(%ebp)
  80033a:	ff 75 08             	pushl  0x8(%ebp)
  80033d:	56                   	push   %esi
  80033e:	50                   	push   %eax
  80033f:	68 d8 0f 80 00       	push   $0x800fd8
  800344:	e8 b1 00 00 00       	call   8003fa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800349:	83 c4 18             	add    $0x18,%esp
  80034c:	53                   	push   %ebx
  80034d:	ff 75 10             	pushl  0x10(%ebp)
  800350:	e8 54 00 00 00       	call   8003a9 <vcprintf>
	cprintf("\n");
  800355:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  80035c:	e8 99 00 00 00       	call   8003fa <cprintf>
  800361:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800364:	cc                   	int3   
  800365:	eb fd                	jmp    800364 <_panic+0x43>

00800367 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	53                   	push   %ebx
  80036b:	83 ec 04             	sub    $0x4,%esp
  80036e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800371:	8b 13                	mov    (%ebx),%edx
  800373:	8d 42 01             	lea    0x1(%edx),%eax
  800376:	89 03                	mov    %eax,(%ebx)
  800378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80037f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800384:	75 1a                	jne    8003a0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	68 ff 00 00 00       	push   $0xff
  80038e:	8d 43 08             	lea    0x8(%ebx),%eax
  800391:	50                   	push   %eax
  800392:	e8 ff fc ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800397:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80039d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a7:	c9                   	leave  
  8003a8:	c3                   	ret    

008003a9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b9:	00 00 00 
	b.cnt = 0;
  8003bc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c6:	ff 75 0c             	pushl  0xc(%ebp)
  8003c9:	ff 75 08             	pushl  0x8(%ebp)
  8003cc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	68 67 03 80 00       	push   $0x800367
  8003d8:	e8 54 01 00 00       	call   800531 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003dd:	83 c4 08             	add    $0x8,%esp
  8003e0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ec:	50                   	push   %eax
  8003ed:	e8 a4 fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8003f2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    

008003fa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800400:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800403:	50                   	push   %eax
  800404:	ff 75 08             	pushl  0x8(%ebp)
  800407:	e8 9d ff ff ff       	call   8003a9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80040c:	c9                   	leave  
  80040d:	c3                   	ret    

0080040e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	57                   	push   %edi
  800412:	56                   	push   %esi
  800413:	53                   	push   %ebx
  800414:	83 ec 1c             	sub    $0x1c,%esp
  800417:	89 c7                	mov    %eax,%edi
  800419:	89 d6                	mov    %edx,%esi
  80041b:	8b 45 08             	mov    0x8(%ebp),%eax
  80041e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800421:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800424:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800427:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800432:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800435:	39 d3                	cmp    %edx,%ebx
  800437:	72 05                	jb     80043e <printnum+0x30>
  800439:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043c:	77 45                	ja     800483 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80043e:	83 ec 0c             	sub    $0xc,%esp
  800441:	ff 75 18             	pushl  0x18(%ebp)
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044a:	53                   	push   %ebx
  80044b:	ff 75 10             	pushl  0x10(%ebp)
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	ff 75 e4             	pushl  -0x1c(%ebp)
  800454:	ff 75 e0             	pushl  -0x20(%ebp)
  800457:	ff 75 dc             	pushl  -0x24(%ebp)
  80045a:	ff 75 d8             	pushl  -0x28(%ebp)
  80045d:	e8 ae 08 00 00       	call   800d10 <__udivdi3>
  800462:	83 c4 18             	add    $0x18,%esp
  800465:	52                   	push   %edx
  800466:	50                   	push   %eax
  800467:	89 f2                	mov    %esi,%edx
  800469:	89 f8                	mov    %edi,%eax
  80046b:	e8 9e ff ff ff       	call   80040e <printnum>
  800470:	83 c4 20             	add    $0x20,%esp
  800473:	eb 18                	jmp    80048d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	56                   	push   %esi
  800479:	ff 75 18             	pushl  0x18(%ebp)
  80047c:	ff d7                	call   *%edi
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	eb 03                	jmp    800486 <printnum+0x78>
  800483:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800486:	83 eb 01             	sub    $0x1,%ebx
  800489:	85 db                	test   %ebx,%ebx
  80048b:	7f e8                	jg     800475 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	56                   	push   %esi
  800491:	83 ec 04             	sub    $0x4,%esp
  800494:	ff 75 e4             	pushl  -0x1c(%ebp)
  800497:	ff 75 e0             	pushl  -0x20(%ebp)
  80049a:	ff 75 dc             	pushl  -0x24(%ebp)
  80049d:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a0:	e8 9b 09 00 00       	call   800e40 <__umoddi3>
  8004a5:	83 c4 14             	add    $0x14,%esp
  8004a8:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  8004af:	50                   	push   %eax
  8004b0:	ff d7                	call   *%edi
}
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b8:	5b                   	pop    %ebx
  8004b9:	5e                   	pop    %esi
  8004ba:	5f                   	pop    %edi
  8004bb:	5d                   	pop    %ebp
  8004bc:	c3                   	ret    

008004bd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c0:	83 fa 01             	cmp    $0x1,%edx
  8004c3:	7e 0e                	jle    8004d3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c5:	8b 10                	mov    (%eax),%edx
  8004c7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ca:	89 08                	mov    %ecx,(%eax)
  8004cc:	8b 02                	mov    (%edx),%eax
  8004ce:	8b 52 04             	mov    0x4(%edx),%edx
  8004d1:	eb 22                	jmp    8004f5 <getuint+0x38>
	else if (lflag)
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	74 10                	je     8004e7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dc:	89 08                	mov    %ecx,(%eax)
  8004de:	8b 02                	mov    (%edx),%eax
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e5:	eb 0e                	jmp    8004f5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e7:	8b 10                	mov    (%eax),%edx
  8004e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ec:	89 08                	mov    %ecx,(%eax)
  8004ee:	8b 02                	mov    (%edx),%eax
  8004f0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004fd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800501:	8b 10                	mov    (%eax),%edx
  800503:	3b 50 04             	cmp    0x4(%eax),%edx
  800506:	73 0a                	jae    800512 <sprintputch+0x1b>
		*b->buf++ = ch;
  800508:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050b:	89 08                	mov    %ecx,(%eax)
  80050d:	8b 45 08             	mov    0x8(%ebp),%eax
  800510:	88 02                	mov    %al,(%edx)
}
  800512:	5d                   	pop    %ebp
  800513:	c3                   	ret    

00800514 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051d:	50                   	push   %eax
  80051e:	ff 75 10             	pushl  0x10(%ebp)
  800521:	ff 75 0c             	pushl  0xc(%ebp)
  800524:	ff 75 08             	pushl  0x8(%ebp)
  800527:	e8 05 00 00 00       	call   800531 <vprintfmt>
	va_end(ap);
}
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	57                   	push   %edi
  800535:	56                   	push   %esi
  800536:	53                   	push   %ebx
  800537:	83 ec 2c             	sub    $0x2c,%esp
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800540:	8b 7d 10             	mov    0x10(%ebp),%edi
  800543:	eb 1d                	jmp    800562 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800545:	85 c0                	test   %eax,%eax
  800547:	75 0f                	jne    800558 <vprintfmt+0x27>
				csa = 0x0700;
  800549:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800550:	07 00 00 
				return;
  800553:	e9 c4 03 00 00       	jmp    80091c <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	53                   	push   %ebx
  80055c:	50                   	push   %eax
  80055d:	ff d6                	call   *%esi
  80055f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800562:	83 c7 01             	add    $0x1,%edi
  800565:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800569:	83 f8 25             	cmp    $0x25,%eax
  80056c:	75 d7                	jne    800545 <vprintfmt+0x14>
  80056e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800572:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800579:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800580:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800587:	ba 00 00 00 00       	mov    $0x0,%edx
  80058c:	eb 07                	jmp    800595 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800591:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8d 47 01             	lea    0x1(%edi),%eax
  800598:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059b:	0f b6 07             	movzbl (%edi),%eax
  80059e:	0f b6 c8             	movzbl %al,%ecx
  8005a1:	83 e8 23             	sub    $0x23,%eax
  8005a4:	3c 55                	cmp    $0x55,%al
  8005a6:	0f 87 55 03 00 00    	ja     800901 <vprintfmt+0x3d0>
  8005ac:	0f b6 c0             	movzbl %al,%eax
  8005af:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005bd:	eb d6                	jmp    800595 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005d7:	83 fa 09             	cmp    $0x9,%edx
  8005da:	77 39                	ja     800615 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005df:	eb e9                	jmp    8005ca <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8005e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f2:	eb 27                	jmp    80061b <vprintfmt+0xea>
  8005f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fe:	0f 49 c8             	cmovns %eax,%ecx
  800601:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800607:	eb 8c                	jmp    800595 <vprintfmt+0x64>
  800609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80060c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800613:	eb 80                	jmp    800595 <vprintfmt+0x64>
  800615:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800618:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80061b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061f:	0f 89 70 ff ff ff    	jns    800595 <vprintfmt+0x64>
				width = precision, precision = -1;
  800625:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800628:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800632:	e9 5e ff ff ff       	jmp    800595 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800637:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80063d:	e9 53 ff ff ff       	jmp    800595 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	ff 30                	pushl  (%eax)
  800651:	ff d6                	call   *%esi
			break;
  800653:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800659:	e9 04 ff ff ff       	jmp    800562 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	99                   	cltd   
  80066a:	31 d0                	xor    %edx,%eax
  80066c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066e:	83 f8 08             	cmp    $0x8,%eax
  800671:	7f 0b                	jg     80067e <vprintfmt+0x14d>
  800673:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80067a:	85 d2                	test   %edx,%edx
  80067c:	75 18                	jne    800696 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80067e:	50                   	push   %eax
  80067f:	68 16 10 80 00       	push   $0x801016
  800684:	53                   	push   %ebx
  800685:	56                   	push   %esi
  800686:	e8 89 fe ff ff       	call   800514 <printfmt>
  80068b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800691:	e9 cc fe ff ff       	jmp    800562 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800696:	52                   	push   %edx
  800697:	68 1f 10 80 00       	push   $0x80101f
  80069c:	53                   	push   %ebx
  80069d:	56                   	push   %esi
  80069e:	e8 71 fe ff ff       	call   800514 <printfmt>
  8006a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a9:	e9 b4 fe ff ff       	jmp    800562 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b9:	85 ff                	test   %edi,%edi
  8006bb:	b8 0f 10 80 00       	mov    $0x80100f,%eax
  8006c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c7:	0f 8e 94 00 00 00    	jle    800761 <vprintfmt+0x230>
  8006cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006d1:	0f 84 98 00 00 00    	je     80076f <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	ff 75 d0             	pushl  -0x30(%ebp)
  8006dd:	57                   	push   %edi
  8006de:	e8 c1 02 00 00       	call   8009a4 <strnlen>
  8006e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e6:	29 c1                	sub    %eax,%ecx
  8006e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fa:	eb 0f                	jmp    80070b <vprintfmt+0x1da>
					putch(padc, putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	ff 75 e0             	pushl  -0x20(%ebp)
  800703:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800705:	83 ef 01             	sub    $0x1,%edi
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	85 ff                	test   %edi,%edi
  80070d:	7f ed                	jg     8006fc <vprintfmt+0x1cb>
  80070f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800712:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800715:	85 c9                	test   %ecx,%ecx
  800717:	b8 00 00 00 00       	mov    $0x0,%eax
  80071c:	0f 49 c1             	cmovns %ecx,%eax
  80071f:	29 c1                	sub    %eax,%ecx
  800721:	89 75 08             	mov    %esi,0x8(%ebp)
  800724:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800727:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072a:	89 cb                	mov    %ecx,%ebx
  80072c:	eb 4d                	jmp    80077b <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800732:	74 1b                	je     80074f <vprintfmt+0x21e>
  800734:	0f be c0             	movsbl %al,%eax
  800737:	83 e8 20             	sub    $0x20,%eax
  80073a:	83 f8 5e             	cmp    $0x5e,%eax
  80073d:	76 10                	jbe    80074f <vprintfmt+0x21e>
					putch('?', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	6a 3f                	push   $0x3f
  800747:	ff 55 08             	call   *0x8(%ebp)
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb 0d                	jmp    80075c <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	52                   	push   %edx
  800756:	ff 55 08             	call   *0x8(%ebp)
  800759:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	eb 1a                	jmp    80077b <vprintfmt+0x24a>
  800761:	89 75 08             	mov    %esi,0x8(%ebp)
  800764:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800767:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076d:	eb 0c                	jmp    80077b <vprintfmt+0x24a>
  80076f:	89 75 08             	mov    %esi,0x8(%ebp)
  800772:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800775:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800778:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077b:	83 c7 01             	add    $0x1,%edi
  80077e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800782:	0f be d0             	movsbl %al,%edx
  800785:	85 d2                	test   %edx,%edx
  800787:	74 23                	je     8007ac <vprintfmt+0x27b>
  800789:	85 f6                	test   %esi,%esi
  80078b:	78 a1                	js     80072e <vprintfmt+0x1fd>
  80078d:	83 ee 01             	sub    $0x1,%esi
  800790:	79 9c                	jns    80072e <vprintfmt+0x1fd>
  800792:	89 df                	mov    %ebx,%edi
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	eb 18                	jmp    8007b4 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	6a 20                	push   $0x20
  8007a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a4:	83 ef 01             	sub    $0x1,%edi
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb 08                	jmp    8007b4 <vprintfmt+0x283>
  8007ac:	89 df                	mov    %ebx,%edi
  8007ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b4:	85 ff                	test   %edi,%edi
  8007b6:	7f e4                	jg     80079c <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bb:	e9 a2 fd ff ff       	jmp    800562 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c0:	83 fa 01             	cmp    $0x1,%edx
  8007c3:	7e 16                	jle    8007db <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 08             	lea    0x8(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 50 04             	mov    0x4(%eax),%edx
  8007d1:	8b 00                	mov    (%eax),%eax
  8007d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d9:	eb 32                	jmp    80080d <vprintfmt+0x2dc>
	else if (lflag)
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	74 18                	je     8007f7 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ed:	89 c1                	mov    %eax,%ecx
  8007ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f5:	eb 16                	jmp    80080d <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8d 50 04             	lea    0x4(%eax),%edx
  8007fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800800:	8b 00                	mov    (%eax),%eax
  800802:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800805:	89 c1                	mov    %eax,%ecx
  800807:	c1 f9 1f             	sar    $0x1f,%ecx
  80080a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800810:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800813:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800818:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80081c:	79 74                	jns    800892 <vprintfmt+0x361>
				putch('-', putdat);
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	53                   	push   %ebx
  800822:	6a 2d                	push   $0x2d
  800824:	ff d6                	call   *%esi
				num = -(long long) num;
  800826:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800829:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80082c:	f7 d8                	neg    %eax
  80082e:	83 d2 00             	adc    $0x0,%edx
  800831:	f7 da                	neg    %edx
  800833:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800836:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80083b:	eb 55                	jmp    800892 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083d:	8d 45 14             	lea    0x14(%ebp),%eax
  800840:	e8 78 fc ff ff       	call   8004bd <getuint>
			base = 10;
  800845:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80084a:	eb 46                	jmp    800892 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
  80084f:	e8 69 fc ff ff       	call   8004bd <getuint>
      base = 8;
  800854:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800859:	eb 37                	jmp    800892 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 30                	push   $0x30
  800861:	ff d6                	call   *%esi
			putch('x', putdat);
  800863:	83 c4 08             	add    $0x8,%esp
  800866:	53                   	push   %ebx
  800867:	6a 78                	push   $0x78
  800869:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80086b:	8b 45 14             	mov    0x14(%ebp),%eax
  80086e:	8d 50 04             	lea    0x4(%eax),%edx
  800871:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800874:	8b 00                	mov    (%eax),%eax
  800876:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80087e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800883:	eb 0d                	jmp    800892 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800885:	8d 45 14             	lea    0x14(%ebp),%eax
  800888:	e8 30 fc ff ff       	call   8004bd <getuint>
			base = 16;
  80088d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800892:	83 ec 0c             	sub    $0xc,%esp
  800895:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800899:	57                   	push   %edi
  80089a:	ff 75 e0             	pushl  -0x20(%ebp)
  80089d:	51                   	push   %ecx
  80089e:	52                   	push   %edx
  80089f:	50                   	push   %eax
  8008a0:	89 da                	mov    %ebx,%edx
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	e8 65 fb ff ff       	call   80040e <printnum>
			break;
  8008a9:	83 c4 20             	add    $0x20,%esp
  8008ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008af:	e9 ae fc ff ff       	jmp    800562 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	51                   	push   %ecx
  8008b9:	ff d6                	call   *%esi
			break;
  8008bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c1:	e9 9c fc ff ff       	jmp    800562 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c6:	83 fa 01             	cmp    $0x1,%edx
  8008c9:	7e 0d                	jle    8008d8 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8d 50 08             	lea    0x8(%eax),%edx
  8008d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d4:	8b 00                	mov    (%eax),%eax
  8008d6:	eb 1c                	jmp    8008f4 <vprintfmt+0x3c3>
	else if (lflag)
  8008d8:	85 d2                	test   %edx,%edx
  8008da:	74 0d                	je     8008e9 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008df:	8d 50 04             	lea    0x4(%eax),%edx
  8008e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e5:	8b 00                	mov    (%eax),%eax
  8008e7:	eb 0b                	jmp    8008f4 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ec:	8d 50 04             	lea    0x4(%eax),%edx
  8008ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f2:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8008f4:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8008fc:	e9 61 fc ff ff       	jmp    800562 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	53                   	push   %ebx
  800905:	6a 25                	push   $0x25
  800907:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800909:	83 c4 10             	add    $0x10,%esp
  80090c:	eb 03                	jmp    800911 <vprintfmt+0x3e0>
  80090e:	83 ef 01             	sub    $0x1,%edi
  800911:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800915:	75 f7                	jne    80090e <vprintfmt+0x3dd>
  800917:	e9 46 fc ff ff       	jmp    800562 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80091c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	83 ec 18             	sub    $0x18,%esp
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800930:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800933:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800937:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80093a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800941:	85 c0                	test   %eax,%eax
  800943:	74 26                	je     80096b <vsnprintf+0x47>
  800945:	85 d2                	test   %edx,%edx
  800947:	7e 22                	jle    80096b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800949:	ff 75 14             	pushl  0x14(%ebp)
  80094c:	ff 75 10             	pushl  0x10(%ebp)
  80094f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800952:	50                   	push   %eax
  800953:	68 f7 04 80 00       	push   $0x8004f7
  800958:	e8 d4 fb ff ff       	call   800531 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80095d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800960:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800963:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800966:	83 c4 10             	add    $0x10,%esp
  800969:	eb 05                	jmp    800970 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80096b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800978:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097b:	50                   	push   %eax
  80097c:	ff 75 10             	pushl  0x10(%ebp)
  80097f:	ff 75 0c             	pushl  0xc(%ebp)
  800982:	ff 75 08             	pushl  0x8(%ebp)
  800985:	e8 9a ff ff ff       	call   800924 <vsnprintf>
	va_end(ap);

	return rc;
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
  800997:	eb 03                	jmp    80099c <strlen+0x10>
		n++;
  800999:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80099c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a0:	75 f7                	jne    800999 <strlen+0xd>
		n++;
	return n;
}
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009aa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b2:	eb 03                	jmp    8009b7 <strnlen+0x13>
		n++;
  8009b4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b7:	39 c2                	cmp    %eax,%edx
  8009b9:	74 08                	je     8009c3 <strnlen+0x1f>
  8009bb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009bf:	75 f3                	jne    8009b4 <strnlen+0x10>
  8009c1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009cf:	89 c2                	mov    %eax,%edx
  8009d1:	83 c2 01             	add    $0x1,%edx
  8009d4:	83 c1 01             	add    $0x1,%ecx
  8009d7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009db:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009de:	84 db                	test   %bl,%bl
  8009e0:	75 ef                	jne    8009d1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	53                   	push   %ebx
  8009e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009ec:	53                   	push   %ebx
  8009ed:	e8 9a ff ff ff       	call   80098c <strlen>
  8009f2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009f5:	ff 75 0c             	pushl  0xc(%ebp)
  8009f8:	01 d8                	add    %ebx,%eax
  8009fa:	50                   	push   %eax
  8009fb:	e8 c5 ff ff ff       	call   8009c5 <strcpy>
	return dst;
}
  800a00:	89 d8                	mov    %ebx,%eax
  800a02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a12:	89 f3                	mov    %esi,%ebx
  800a14:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a17:	89 f2                	mov    %esi,%edx
  800a19:	eb 0f                	jmp    800a2a <strncpy+0x23>
		*dst++ = *src;
  800a1b:	83 c2 01             	add    $0x1,%edx
  800a1e:	0f b6 01             	movzbl (%ecx),%eax
  800a21:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a24:	80 39 01             	cmpb   $0x1,(%ecx)
  800a27:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2a:	39 da                	cmp    %ebx,%edx
  800a2c:	75 ed                	jne    800a1b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a2e:	89 f0                	mov    %esi,%eax
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3f:	8b 55 10             	mov    0x10(%ebp),%edx
  800a42:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a44:	85 d2                	test   %edx,%edx
  800a46:	74 21                	je     800a69 <strlcpy+0x35>
  800a48:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a4c:	89 f2                	mov    %esi,%edx
  800a4e:	eb 09                	jmp    800a59 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a50:	83 c2 01             	add    $0x1,%edx
  800a53:	83 c1 01             	add    $0x1,%ecx
  800a56:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a59:	39 c2                	cmp    %eax,%edx
  800a5b:	74 09                	je     800a66 <strlcpy+0x32>
  800a5d:	0f b6 19             	movzbl (%ecx),%ebx
  800a60:	84 db                	test   %bl,%bl
  800a62:	75 ec                	jne    800a50 <strlcpy+0x1c>
  800a64:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a66:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a69:	29 f0                	sub    %esi,%eax
}
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a75:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a78:	eb 06                	jmp    800a80 <strcmp+0x11>
		p++, q++;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a80:	0f b6 01             	movzbl (%ecx),%eax
  800a83:	84 c0                	test   %al,%al
  800a85:	74 04                	je     800a8b <strcmp+0x1c>
  800a87:	3a 02                	cmp    (%edx),%al
  800a89:	74 ef                	je     800a7a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8b:	0f b6 c0             	movzbl %al,%eax
  800a8e:	0f b6 12             	movzbl (%edx),%edx
  800a91:	29 d0                	sub    %edx,%eax
}
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	53                   	push   %ebx
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9f:	89 c3                	mov    %eax,%ebx
  800aa1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa4:	eb 06                	jmp    800aac <strncmp+0x17>
		n--, p++, q++;
  800aa6:	83 c0 01             	add    $0x1,%eax
  800aa9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aac:	39 d8                	cmp    %ebx,%eax
  800aae:	74 15                	je     800ac5 <strncmp+0x30>
  800ab0:	0f b6 08             	movzbl (%eax),%ecx
  800ab3:	84 c9                	test   %cl,%cl
  800ab5:	74 04                	je     800abb <strncmp+0x26>
  800ab7:	3a 0a                	cmp    (%edx),%cl
  800ab9:	74 eb                	je     800aa6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800abb:	0f b6 00             	movzbl (%eax),%eax
  800abe:	0f b6 12             	movzbl (%edx),%edx
  800ac1:	29 d0                	sub    %edx,%eax
  800ac3:	eb 05                	jmp    800aca <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aca:	5b                   	pop    %ebx
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad7:	eb 07                	jmp    800ae0 <strchr+0x13>
		if (*s == c)
  800ad9:	38 ca                	cmp    %cl,%dl
  800adb:	74 0f                	je     800aec <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800add:	83 c0 01             	add    $0x1,%eax
  800ae0:	0f b6 10             	movzbl (%eax),%edx
  800ae3:	84 d2                	test   %dl,%dl
  800ae5:	75 f2                	jne    800ad9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af8:	eb 03                	jmp    800afd <strfind+0xf>
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b00:	38 ca                	cmp    %cl,%dl
  800b02:	74 04                	je     800b08 <strfind+0x1a>
  800b04:	84 d2                	test   %dl,%dl
  800b06:	75 f2                	jne    800afa <strfind+0xc>
			break;
	return (char *) s;
}
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b16:	85 c9                	test   %ecx,%ecx
  800b18:	74 36                	je     800b50 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b20:	75 28                	jne    800b4a <memset+0x40>
  800b22:	f6 c1 03             	test   $0x3,%cl
  800b25:	75 23                	jne    800b4a <memset+0x40>
		c &= 0xFF;
  800b27:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b2b:	89 d3                	mov    %edx,%ebx
  800b2d:	c1 e3 08             	shl    $0x8,%ebx
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	c1 e6 18             	shl    $0x18,%esi
  800b35:	89 d0                	mov    %edx,%eax
  800b37:	c1 e0 10             	shl    $0x10,%eax
  800b3a:	09 f0                	or     %esi,%eax
  800b3c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b3e:	89 d8                	mov    %ebx,%eax
  800b40:	09 d0                	or     %edx,%eax
  800b42:	c1 e9 02             	shr    $0x2,%ecx
  800b45:	fc                   	cld    
  800b46:	f3 ab                	rep stos %eax,%es:(%edi)
  800b48:	eb 06                	jmp    800b50 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4d:	fc                   	cld    
  800b4e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b50:	89 f8                	mov    %edi,%eax
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b62:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b65:	39 c6                	cmp    %eax,%esi
  800b67:	73 35                	jae    800b9e <memmove+0x47>
  800b69:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b6c:	39 d0                	cmp    %edx,%eax
  800b6e:	73 2e                	jae    800b9e <memmove+0x47>
		s += n;
		d += n;
  800b70:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	09 fe                	or     %edi,%esi
  800b77:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b7d:	75 13                	jne    800b92 <memmove+0x3b>
  800b7f:	f6 c1 03             	test   $0x3,%cl
  800b82:	75 0e                	jne    800b92 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b84:	83 ef 04             	sub    $0x4,%edi
  800b87:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b8a:	c1 e9 02             	shr    $0x2,%ecx
  800b8d:	fd                   	std    
  800b8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b90:	eb 09                	jmp    800b9b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b92:	83 ef 01             	sub    $0x1,%edi
  800b95:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b98:	fd                   	std    
  800b99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9b:	fc                   	cld    
  800b9c:	eb 1d                	jmp    800bbb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9e:	89 f2                	mov    %esi,%edx
  800ba0:	09 c2                	or     %eax,%edx
  800ba2:	f6 c2 03             	test   $0x3,%dl
  800ba5:	75 0f                	jne    800bb6 <memmove+0x5f>
  800ba7:	f6 c1 03             	test   $0x3,%cl
  800baa:	75 0a                	jne    800bb6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bac:	c1 e9 02             	shr    $0x2,%ecx
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	fc                   	cld    
  800bb2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb4:	eb 05                	jmp    800bbb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb6:	89 c7                	mov    %eax,%edi
  800bb8:	fc                   	cld    
  800bb9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc2:	ff 75 10             	pushl  0x10(%ebp)
  800bc5:	ff 75 0c             	pushl  0xc(%ebp)
  800bc8:	ff 75 08             	pushl  0x8(%ebp)
  800bcb:	e8 87 ff ff ff       	call   800b57 <memmove>
}
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    

00800bd2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdd:	89 c6                	mov    %eax,%esi
  800bdf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be2:	eb 1a                	jmp    800bfe <memcmp+0x2c>
		if (*s1 != *s2)
  800be4:	0f b6 08             	movzbl (%eax),%ecx
  800be7:	0f b6 1a             	movzbl (%edx),%ebx
  800bea:	38 d9                	cmp    %bl,%cl
  800bec:	74 0a                	je     800bf8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bee:	0f b6 c1             	movzbl %cl,%eax
  800bf1:	0f b6 db             	movzbl %bl,%ebx
  800bf4:	29 d8                	sub    %ebx,%eax
  800bf6:	eb 0f                	jmp    800c07 <memcmp+0x35>
		s1++, s2++;
  800bf8:	83 c0 01             	add    $0x1,%eax
  800bfb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfe:	39 f0                	cmp    %esi,%eax
  800c00:	75 e2                	jne    800be4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	53                   	push   %ebx
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c12:	89 c1                	mov    %eax,%ecx
  800c14:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c17:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1b:	eb 0a                	jmp    800c27 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1d:	0f b6 10             	movzbl (%eax),%edx
  800c20:	39 da                	cmp    %ebx,%edx
  800c22:	74 07                	je     800c2b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c24:	83 c0 01             	add    $0x1,%eax
  800c27:	39 c8                	cmp    %ecx,%eax
  800c29:	72 f2                	jb     800c1d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c2b:	5b                   	pop    %ebx
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3a:	eb 03                	jmp    800c3f <strtol+0x11>
		s++;
  800c3c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3f:	0f b6 01             	movzbl (%ecx),%eax
  800c42:	3c 20                	cmp    $0x20,%al
  800c44:	74 f6                	je     800c3c <strtol+0xe>
  800c46:	3c 09                	cmp    $0x9,%al
  800c48:	74 f2                	je     800c3c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4a:	3c 2b                	cmp    $0x2b,%al
  800c4c:	75 0a                	jne    800c58 <strtol+0x2a>
		s++;
  800c4e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c51:	bf 00 00 00 00       	mov    $0x0,%edi
  800c56:	eb 11                	jmp    800c69 <strtol+0x3b>
  800c58:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c5d:	3c 2d                	cmp    $0x2d,%al
  800c5f:	75 08                	jne    800c69 <strtol+0x3b>
		s++, neg = 1;
  800c61:	83 c1 01             	add    $0x1,%ecx
  800c64:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c69:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c6f:	75 15                	jne    800c86 <strtol+0x58>
  800c71:	80 39 30             	cmpb   $0x30,(%ecx)
  800c74:	75 10                	jne    800c86 <strtol+0x58>
  800c76:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c7a:	75 7c                	jne    800cf8 <strtol+0xca>
		s += 2, base = 16;
  800c7c:	83 c1 02             	add    $0x2,%ecx
  800c7f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c84:	eb 16                	jmp    800c9c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c86:	85 db                	test   %ebx,%ebx
  800c88:	75 12                	jne    800c9c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c92:	75 08                	jne    800c9c <strtol+0x6e>
		s++, base = 8;
  800c94:	83 c1 01             	add    $0x1,%ecx
  800c97:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca4:	0f b6 11             	movzbl (%ecx),%edx
  800ca7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800caa:	89 f3                	mov    %esi,%ebx
  800cac:	80 fb 09             	cmp    $0x9,%bl
  800caf:	77 08                	ja     800cb9 <strtol+0x8b>
			dig = *s - '0';
  800cb1:	0f be d2             	movsbl %dl,%edx
  800cb4:	83 ea 30             	sub    $0x30,%edx
  800cb7:	eb 22                	jmp    800cdb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cb9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cbc:	89 f3                	mov    %esi,%ebx
  800cbe:	80 fb 19             	cmp    $0x19,%bl
  800cc1:	77 08                	ja     800ccb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cc3:	0f be d2             	movsbl %dl,%edx
  800cc6:	83 ea 57             	sub    $0x57,%edx
  800cc9:	eb 10                	jmp    800cdb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ccb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cce:	89 f3                	mov    %esi,%ebx
  800cd0:	80 fb 19             	cmp    $0x19,%bl
  800cd3:	77 16                	ja     800ceb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cd5:	0f be d2             	movsbl %dl,%edx
  800cd8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cdb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cde:	7d 0b                	jge    800ceb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce0:	83 c1 01             	add    $0x1,%ecx
  800ce3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ce7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ce9:	eb b9                	jmp    800ca4 <strtol+0x76>

	if (endptr)
  800ceb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cef:	74 0d                	je     800cfe <strtol+0xd0>
		*endptr = (char *) s;
  800cf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf4:	89 0e                	mov    %ecx,(%esi)
  800cf6:	eb 06                	jmp    800cfe <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf8:	85 db                	test   %ebx,%ebx
  800cfa:	74 98                	je     800c94 <strtol+0x66>
  800cfc:	eb 9e                	jmp    800c9c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cfe:	89 c2                	mov    %eax,%edx
  800d00:	f7 da                	neg    %edx
  800d02:	85 ff                	test   %edi,%edi
  800d04:	0f 45 c2             	cmovne %edx,%eax
}
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    
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
