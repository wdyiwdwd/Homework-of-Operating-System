
obj/user/buggyhello：     文件格式 elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 5d 00 00 00       	call   80009f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800052:	e8 c6 00 00 00       	call   80011d <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	c1 e0 07             	shl    $0x7,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 42 00 00 00       	call   8000dc <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
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
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	89 cb                	mov    %ecx,%ebx
  8000f4:	89 cf                	mov    %ecx,%edi
  8000f6:	89 ce                	mov    %ecx,%esi
  8000f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7e 17                	jle    800115 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	50                   	push   %eax
  800102:	6a 03                	push   $0x3
  800104:	68 ca 0f 80 00       	push   $0x800fca
  800109:	6a 23                	push   $0x23
  80010b:	68 e7 0f 80 00       	push   $0x800fe7
  800110:	e8 15 02 00 00       	call   80032a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 02 00 00 00       	mov    $0x2,%eax
  80012d:	89 d1                	mov    %edx,%ecx
  80012f:	89 d3                	mov    %edx,%ebx
  800131:	89 d7                	mov    %edx,%edi
  800133:	89 d6                	mov    %edx,%esi
  800135:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_yield>:

void
sys_yield(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	be 00 00 00 00       	mov    $0x0,%esi
  800169:	b8 04 00 00 00       	mov    $0x4,%eax
  80016e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800177:	89 f7                	mov    %esi,%edi
  800179:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017b:	85 c0                	test   %eax,%eax
  80017d:	7e 17                	jle    800196 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	50                   	push   %eax
  800183:	6a 04                	push   $0x4
  800185:	68 ca 0f 80 00       	push   $0x800fca
  80018a:	6a 23                	push   $0x23
  80018c:	68 e7 0f 80 00       	push   $0x800fe7
  800191:	e8 94 01 00 00       	call   80032a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7e 17                	jle    8001d8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	50                   	push   %eax
  8001c5:	6a 05                	push   $0x5
  8001c7:	68 ca 0f 80 00       	push   $0x800fca
  8001cc:	6a 23                	push   $0x23
  8001ce:	68 e7 0f 80 00       	push   $0x800fe7
  8001d3:	e8 52 01 00 00       	call   80032a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	89 df                	mov    %ebx,%edi
  8001fb:	89 de                	mov    %ebx,%esi
  8001fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ff:	85 c0                	test   %eax,%eax
  800201:	7e 17                	jle    80021a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	50                   	push   %eax
  800207:	6a 06                	push   $0x6
  800209:	68 ca 0f 80 00       	push   $0x800fca
  80020e:	6a 23                	push   $0x23
  800210:	68 e7 0f 80 00       	push   $0x800fe7
  800215:	e8 10 01 00 00       	call   80032a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	57                   	push   %edi
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	89 df                	mov    %ebx,%edi
  80023d:	89 de                	mov    %ebx,%esi
  80023f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	7e 17                	jle    80025c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	50                   	push   %eax
  800249:	6a 08                	push   $0x8
  80024b:	68 ca 0f 80 00       	push   $0x800fca
  800250:	6a 23                	push   $0x23
  800252:	68 e7 0f 80 00       	push   $0x800fe7
  800257:	e8 ce 00 00 00       	call   80032a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	89 df                	mov    %ebx,%edi
  80027f:	89 de                	mov    %ebx,%esi
  800281:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7e 17                	jle    80029e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	50                   	push   %eax
  80028b:	6a 09                	push   $0x9
  80028d:	68 ca 0f 80 00       	push   $0x800fca
  800292:	6a 23                	push   $0x23
  800294:	68 e7 0f 80 00       	push   $0x800fe7
  800299:	e8 8c 00 00 00       	call   80032a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80029e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ac:	be 00 00 00 00       	mov    $0x0,%esi
  8002b1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 cb                	mov    %ecx,%ebx
  8002e1:	89 cf                	mov    %ecx,%edi
  8002e3:	89 ce                	mov    %ecx,%esi
  8002e5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	7e 17                	jle    800302 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002eb:	83 ec 0c             	sub    $0xc,%esp
  8002ee:	50                   	push   %eax
  8002ef:	6a 0c                	push   $0xc
  8002f1:	68 ca 0f 80 00       	push   $0x800fca
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 e7 0f 80 00       	push   $0x800fe7
  8002fd:	e8 28 00 00 00       	call   80032a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_change_pr>:

int
sys_change_pr(int pr)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800310:	b9 00 00 00 00       	mov    $0x0,%ecx
  800315:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031a:	8b 55 08             	mov    0x8(%ebp),%edx
  80031d:	89 cb                	mov    %ecx,%ebx
  80031f:	89 cf                	mov    %ecx,%edi
  800321:	89 ce                	mov    %ecx,%esi
  800323:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80032f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800332:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800338:	e8 e0 fd ff ff       	call   80011d <sys_getenvid>
  80033d:	83 ec 0c             	sub    $0xc,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	ff 75 08             	pushl  0x8(%ebp)
  800346:	56                   	push   %esi
  800347:	50                   	push   %eax
  800348:	68 f8 0f 80 00       	push   $0x800ff8
  80034d:	e8 b1 00 00 00       	call   800403 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800352:	83 c4 18             	add    $0x18,%esp
  800355:	53                   	push   %ebx
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	e8 54 00 00 00       	call   8003b2 <vcprintf>
	cprintf("\n");
  80035e:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  800365:	e8 99 00 00 00       	call   800403 <cprintf>
  80036a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036d:	cc                   	int3   
  80036e:	eb fd                	jmp    80036d <_panic+0x43>

00800370 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	53                   	push   %ebx
  800374:	83 ec 04             	sub    $0x4,%esp
  800377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037a:	8b 13                	mov    (%ebx),%edx
  80037c:	8d 42 01             	lea    0x1(%edx),%eax
  80037f:	89 03                	mov    %eax,(%ebx)
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800388:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038d:	75 1a                	jne    8003a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	68 ff 00 00 00       	push   $0xff
  800397:	8d 43 08             	lea    0x8(%ebx),%eax
  80039a:	50                   	push   %eax
  80039b:	e8 ff fc ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  8003a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c2:	00 00 00 
	b.cnt = 0;
  8003c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	ff 75 08             	pushl  0x8(%ebp)
  8003d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003db:	50                   	push   %eax
  8003dc:	68 70 03 80 00       	push   $0x800370
  8003e1:	e8 54 01 00 00       	call   80053a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e6:	83 c4 08             	add    $0x8,%esp
  8003e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f5:	50                   	push   %eax
  8003f6:	e8 a4 fc ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  8003fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800409:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040c:	50                   	push   %eax
  80040d:	ff 75 08             	pushl  0x8(%ebp)
  800410:	e8 9d ff ff ff       	call   8003b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800415:	c9                   	leave  
  800416:	c3                   	ret    

00800417 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	57                   	push   %edi
  80041b:	56                   	push   %esi
  80041c:	53                   	push   %ebx
  80041d:	83 ec 1c             	sub    $0x1c,%esp
  800420:	89 c7                	mov    %eax,%edi
  800422:	89 d6                	mov    %edx,%esi
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800430:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800433:	bb 00 00 00 00       	mov    $0x0,%ebx
  800438:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80043b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80043e:	39 d3                	cmp    %edx,%ebx
  800440:	72 05                	jb     800447 <printnum+0x30>
  800442:	39 45 10             	cmp    %eax,0x10(%ebp)
  800445:	77 45                	ja     80048c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800447:	83 ec 0c             	sub    $0xc,%esp
  80044a:	ff 75 18             	pushl  0x18(%ebp)
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800453:	53                   	push   %ebx
  800454:	ff 75 10             	pushl  0x10(%ebp)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80045d:	ff 75 e0             	pushl  -0x20(%ebp)
  800460:	ff 75 dc             	pushl  -0x24(%ebp)
  800463:	ff 75 d8             	pushl  -0x28(%ebp)
  800466:	e8 b5 08 00 00       	call   800d20 <__udivdi3>
  80046b:	83 c4 18             	add    $0x18,%esp
  80046e:	52                   	push   %edx
  80046f:	50                   	push   %eax
  800470:	89 f2                	mov    %esi,%edx
  800472:	89 f8                	mov    %edi,%eax
  800474:	e8 9e ff ff ff       	call   800417 <printnum>
  800479:	83 c4 20             	add    $0x20,%esp
  80047c:	eb 18                	jmp    800496 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	ff 75 18             	pushl  0x18(%ebp)
  800485:	ff d7                	call   *%edi
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	eb 03                	jmp    80048f <printnum+0x78>
  80048c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80048f:	83 eb 01             	sub    $0x1,%ebx
  800492:	85 db                	test   %ebx,%ebx
  800494:	7f e8                	jg     80047e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800496:	83 ec 08             	sub    $0x8,%esp
  800499:	56                   	push   %esi
  80049a:	83 ec 04             	sub    $0x4,%esp
  80049d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a9:	e8 a2 09 00 00       	call   800e50 <__umoddi3>
  8004ae:	83 c4 14             	add    $0x14,%esp
  8004b1:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  8004b8:	50                   	push   %eax
  8004b9:	ff d7                	call   *%edi
}
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c1:	5b                   	pop    %ebx
  8004c2:	5e                   	pop    %esi
  8004c3:	5f                   	pop    %edi
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c9:	83 fa 01             	cmp    $0x1,%edx
  8004cc:	7e 0e                	jle    8004dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ce:	8b 10                	mov    (%eax),%edx
  8004d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d3:	89 08                	mov    %ecx,(%eax)
  8004d5:	8b 02                	mov    (%edx),%eax
  8004d7:	8b 52 04             	mov    0x4(%edx),%edx
  8004da:	eb 22                	jmp    8004fe <getuint+0x38>
	else if (lflag)
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	74 10                	je     8004f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e0:	8b 10                	mov    (%eax),%edx
  8004e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e5:	89 08                	mov    %ecx,(%eax)
  8004e7:	8b 02                	mov    (%edx),%eax
  8004e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ee:	eb 0e                	jmp    8004fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f0:	8b 10                	mov    (%eax),%edx
  8004f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 02                	mov    (%edx),%eax
  8004f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800506:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80050a:	8b 10                	mov    (%eax),%edx
  80050c:	3b 50 04             	cmp    0x4(%eax),%edx
  80050f:	73 0a                	jae    80051b <sprintputch+0x1b>
		*b->buf++ = ch;
  800511:	8d 4a 01             	lea    0x1(%edx),%ecx
  800514:	89 08                	mov    %ecx,(%eax)
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	88 02                	mov    %al,(%edx)
}
  80051b:	5d                   	pop    %ebp
  80051c:	c3                   	ret    

0080051d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800523:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800526:	50                   	push   %eax
  800527:	ff 75 10             	pushl  0x10(%ebp)
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	ff 75 08             	pushl  0x8(%ebp)
  800530:	e8 05 00 00 00       	call   80053a <vprintfmt>
	va_end(ap);
}
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	c9                   	leave  
  800539:	c3                   	ret    

0080053a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	57                   	push   %edi
  80053e:	56                   	push   %esi
  80053f:	53                   	push   %ebx
  800540:	83 ec 2c             	sub    $0x2c,%esp
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	8b 7d 10             	mov    0x10(%ebp),%edi
  80054c:	eb 1d                	jmp    80056b <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80054e:	85 c0                	test   %eax,%eax
  800550:	75 0f                	jne    800561 <vprintfmt+0x27>
				csa = 0x0700;
  800552:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800559:	07 00 00 
				return;
  80055c:	e9 c4 03 00 00       	jmp    800925 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	53                   	push   %ebx
  800565:	50                   	push   %eax
  800566:	ff d6                	call   *%esi
  800568:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80056b:	83 c7 01             	add    $0x1,%edi
  80056e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800572:	83 f8 25             	cmp    $0x25,%eax
  800575:	75 d7                	jne    80054e <vprintfmt+0x14>
  800577:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80057b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800582:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800589:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800590:	ba 00 00 00 00       	mov    $0x0,%edx
  800595:	eb 07                	jmp    80059e <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80059a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8d 47 01             	lea    0x1(%edi),%eax
  8005a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a4:	0f b6 07             	movzbl (%edi),%eax
  8005a7:	0f b6 c8             	movzbl %al,%ecx
  8005aa:	83 e8 23             	sub    $0x23,%eax
  8005ad:	3c 55                	cmp    $0x55,%al
  8005af:	0f 87 55 03 00 00    	ja     80090a <vprintfmt+0x3d0>
  8005b5:	0f b6 c0             	movzbl %al,%eax
  8005b8:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005c6:	eb d6                	jmp    80059e <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005d6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005da:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005dd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005e0:	83 fa 09             	cmp    $0x9,%edx
  8005e3:	77 39                	ja     80061e <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e8:	eb e9                	jmp    8005d3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005fb:	eb 27                	jmp    800624 <vprintfmt+0xea>
  8005fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800600:	85 c0                	test   %eax,%eax
  800602:	b9 00 00 00 00       	mov    $0x0,%ecx
  800607:	0f 49 c8             	cmovns %eax,%ecx
  80060a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800610:	eb 8c                	jmp    80059e <vprintfmt+0x64>
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800615:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80061c:	eb 80                	jmp    80059e <vprintfmt+0x64>
  80061e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800621:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800624:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800628:	0f 89 70 ff ff ff    	jns    80059e <vprintfmt+0x64>
				width = precision, precision = -1;
  80062e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800631:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800634:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80063b:	e9 5e ff ff ff       	jmp    80059e <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800640:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800646:	e9 53 ff ff ff       	jmp    80059e <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 50 04             	lea    0x4(%eax),%edx
  800651:	89 55 14             	mov    %edx,0x14(%ebp)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	ff 30                	pushl  (%eax)
  80065a:	ff d6                	call   *%esi
			break;
  80065c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800662:	e9 04 ff ff ff       	jmp    80056b <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8d 50 04             	lea    0x4(%eax),%edx
  80066d:	89 55 14             	mov    %edx,0x14(%ebp)
  800670:	8b 00                	mov    (%eax),%eax
  800672:	99                   	cltd   
  800673:	31 d0                	xor    %edx,%eax
  800675:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800677:	83 f8 08             	cmp    $0x8,%eax
  80067a:	7f 0b                	jg     800687 <vprintfmt+0x14d>
  80067c:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800683:	85 d2                	test   %edx,%edx
  800685:	75 18                	jne    80069f <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800687:	50                   	push   %eax
  800688:	68 36 10 80 00       	push   $0x801036
  80068d:	53                   	push   %ebx
  80068e:	56                   	push   %esi
  80068f:	e8 89 fe ff ff       	call   80051d <printfmt>
  800694:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80069a:	e9 cc fe ff ff       	jmp    80056b <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80069f:	52                   	push   %edx
  8006a0:	68 3f 10 80 00       	push   $0x80103f
  8006a5:	53                   	push   %ebx
  8006a6:	56                   	push   %esi
  8006a7:	e8 71 fe ff ff       	call   80051d <printfmt>
  8006ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b2:	e9 b4 fe ff ff       	jmp    80056b <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 04             	lea    0x4(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006c2:	85 ff                	test   %edi,%edi
  8006c4:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  8006c9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d0:	0f 8e 94 00 00 00    	jle    80076a <vprintfmt+0x230>
  8006d6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006da:	0f 84 98 00 00 00    	je     800778 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8006e6:	57                   	push   %edi
  8006e7:	e8 c1 02 00 00       	call   8009ad <strnlen>
  8006ec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ef:	29 c1                	sub    %eax,%ecx
  8006f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006f4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006f7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800701:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800703:	eb 0f                	jmp    800714 <vprintfmt+0x1da>
					putch(padc, putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	ff 75 e0             	pushl  -0x20(%ebp)
  80070c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070e:	83 ef 01             	sub    $0x1,%edi
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	85 ff                	test   %edi,%edi
  800716:	7f ed                	jg     800705 <vprintfmt+0x1cb>
  800718:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80071b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80071e:	85 c9                	test   %ecx,%ecx
  800720:	b8 00 00 00 00       	mov    $0x0,%eax
  800725:	0f 49 c1             	cmovns %ecx,%eax
  800728:	29 c1                	sub    %eax,%ecx
  80072a:	89 75 08             	mov    %esi,0x8(%ebp)
  80072d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800730:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800733:	89 cb                	mov    %ecx,%ebx
  800735:	eb 4d                	jmp    800784 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800737:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80073b:	74 1b                	je     800758 <vprintfmt+0x21e>
  80073d:	0f be c0             	movsbl %al,%eax
  800740:	83 e8 20             	sub    $0x20,%eax
  800743:	83 f8 5e             	cmp    $0x5e,%eax
  800746:	76 10                	jbe    800758 <vprintfmt+0x21e>
					putch('?', putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	6a 3f                	push   $0x3f
  800750:	ff 55 08             	call   *0x8(%ebp)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	eb 0d                	jmp    800765 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	ff 75 0c             	pushl  0xc(%ebp)
  80075e:	52                   	push   %edx
  80075f:	ff 55 08             	call   *0x8(%ebp)
  800762:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800765:	83 eb 01             	sub    $0x1,%ebx
  800768:	eb 1a                	jmp    800784 <vprintfmt+0x24a>
  80076a:	89 75 08             	mov    %esi,0x8(%ebp)
  80076d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800770:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800773:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800776:	eb 0c                	jmp    800784 <vprintfmt+0x24a>
  800778:	89 75 08             	mov    %esi,0x8(%ebp)
  80077b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80077e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800781:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800784:	83 c7 01             	add    $0x1,%edi
  800787:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80078b:	0f be d0             	movsbl %al,%edx
  80078e:	85 d2                	test   %edx,%edx
  800790:	74 23                	je     8007b5 <vprintfmt+0x27b>
  800792:	85 f6                	test   %esi,%esi
  800794:	78 a1                	js     800737 <vprintfmt+0x1fd>
  800796:	83 ee 01             	sub    $0x1,%esi
  800799:	79 9c                	jns    800737 <vprintfmt+0x1fd>
  80079b:	89 df                	mov    %ebx,%edi
  80079d:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a3:	eb 18                	jmp    8007bd <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	53                   	push   %ebx
  8007a9:	6a 20                	push   $0x20
  8007ab:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ad:	83 ef 01             	sub    $0x1,%edi
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	eb 08                	jmp    8007bd <vprintfmt+0x283>
  8007b5:	89 df                	mov    %ebx,%edi
  8007b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007bd:	85 ff                	test   %edi,%edi
  8007bf:	7f e4                	jg     8007a5 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c4:	e9 a2 fd ff ff       	jmp    80056b <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c9:	83 fa 01             	cmp    $0x1,%edx
  8007cc:	7e 16                	jle    8007e4 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8d 50 08             	lea    0x8(%eax),%edx
  8007d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d7:	8b 50 04             	mov    0x4(%eax),%edx
  8007da:	8b 00                	mov    (%eax),%eax
  8007dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e2:	eb 32                	jmp    800816 <vprintfmt+0x2dc>
	else if (lflag)
  8007e4:	85 d2                	test   %edx,%edx
  8007e6:	74 18                	je     800800 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f1:	8b 00                	mov    (%eax),%eax
  8007f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f6:	89 c1                	mov    %eax,%ecx
  8007f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007fe:	eb 16                	jmp    800816 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)
  800809:	8b 00                	mov    (%eax),%eax
  80080b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080e:	89 c1                	mov    %eax,%ecx
  800810:	c1 f9 1f             	sar    $0x1f,%ecx
  800813:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800816:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800819:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800821:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800825:	79 74                	jns    80089b <vprintfmt+0x361>
				putch('-', putdat);
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	53                   	push   %ebx
  80082b:	6a 2d                	push   $0x2d
  80082d:	ff d6                	call   *%esi
				num = -(long long) num;
  80082f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800832:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800835:	f7 d8                	neg    %eax
  800837:	83 d2 00             	adc    $0x0,%edx
  80083a:	f7 da                	neg    %edx
  80083c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80083f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800844:	eb 55                	jmp    80089b <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 78 fc ff ff       	call   8004c6 <getuint>
			base = 10;
  80084e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800853:	eb 46                	jmp    80089b <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
  800858:	e8 69 fc ff ff       	call   8004c6 <getuint>
      base = 8;
  80085d:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800862:	eb 37                	jmp    80089b <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	6a 30                	push   $0x30
  80086a:	ff d6                	call   *%esi
			putch('x', putdat);
  80086c:	83 c4 08             	add    $0x8,%esp
  80086f:	53                   	push   %ebx
  800870:	6a 78                	push   $0x78
  800872:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8d 50 04             	lea    0x4(%eax),%edx
  80087a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087d:	8b 00                	mov    (%eax),%eax
  80087f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800884:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800887:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80088c:	eb 0d                	jmp    80089b <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80088e:	8d 45 14             	lea    0x14(%ebp),%eax
  800891:	e8 30 fc ff ff       	call   8004c6 <getuint>
			base = 16;
  800896:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089b:	83 ec 0c             	sub    $0xc,%esp
  80089e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008a2:	57                   	push   %edi
  8008a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a6:	51                   	push   %ecx
  8008a7:	52                   	push   %edx
  8008a8:	50                   	push   %eax
  8008a9:	89 da                	mov    %ebx,%edx
  8008ab:	89 f0                	mov    %esi,%eax
  8008ad:	e8 65 fb ff ff       	call   800417 <printnum>
			break;
  8008b2:	83 c4 20             	add    $0x20,%esp
  8008b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b8:	e9 ae fc ff ff       	jmp    80056b <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	53                   	push   %ebx
  8008c1:	51                   	push   %ecx
  8008c2:	ff d6                	call   *%esi
			break;
  8008c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ca:	e9 9c fc ff ff       	jmp    80056b <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008cf:	83 fa 01             	cmp    $0x1,%edx
  8008d2:	7e 0d                	jle    8008e1 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d7:	8d 50 08             	lea    0x8(%eax),%edx
  8008da:	89 55 14             	mov    %edx,0x14(%ebp)
  8008dd:	8b 00                	mov    (%eax),%eax
  8008df:	eb 1c                	jmp    8008fd <vprintfmt+0x3c3>
	else if (lflag)
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	74 0d                	je     8008f2 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8d 50 04             	lea    0x4(%eax),%edx
  8008eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ee:	8b 00                	mov    (%eax),%eax
  8008f0:	eb 0b                	jmp    8008fd <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8d 50 04             	lea    0x4(%eax),%edx
  8008f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fb:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8008fd:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800902:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800905:	e9 61 fc ff ff       	jmp    80056b <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	53                   	push   %ebx
  80090e:	6a 25                	push   $0x25
  800910:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	eb 03                	jmp    80091a <vprintfmt+0x3e0>
  800917:	83 ef 01             	sub    $0x1,%edi
  80091a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80091e:	75 f7                	jne    800917 <vprintfmt+0x3dd>
  800920:	e9 46 fc ff ff       	jmp    80056b <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800925:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	83 ec 18             	sub    $0x18,%esp
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800939:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800940:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800943:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094a:	85 c0                	test   %eax,%eax
  80094c:	74 26                	je     800974 <vsnprintf+0x47>
  80094e:	85 d2                	test   %edx,%edx
  800950:	7e 22                	jle    800974 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800952:	ff 75 14             	pushl  0x14(%ebp)
  800955:	ff 75 10             	pushl  0x10(%ebp)
  800958:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095b:	50                   	push   %eax
  80095c:	68 00 05 80 00       	push   $0x800500
  800961:	e8 d4 fb ff ff       	call   80053a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800966:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800969:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096f:	83 c4 10             	add    $0x10,%esp
  800972:	eb 05                	jmp    800979 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800974:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800981:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800984:	50                   	push   %eax
  800985:	ff 75 10             	pushl  0x10(%ebp)
  800988:	ff 75 0c             	pushl  0xc(%ebp)
  80098b:	ff 75 08             	pushl  0x8(%ebp)
  80098e:	e8 9a ff ff ff       	call   80092d <vsnprintf>
	va_end(ap);

	return rc;
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a0:	eb 03                	jmp    8009a5 <strlen+0x10>
		n++;
  8009a2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a9:	75 f7                	jne    8009a2 <strlen+0xd>
		n++;
	return n;
}
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	eb 03                	jmp    8009c0 <strnlen+0x13>
		n++;
  8009bd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c0:	39 c2                	cmp    %eax,%edx
  8009c2:	74 08                	je     8009cc <strnlen+0x1f>
  8009c4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c8:	75 f3                	jne    8009bd <strnlen+0x10>
  8009ca:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d8:	89 c2                	mov    %eax,%edx
  8009da:	83 c2 01             	add    $0x1,%edx
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e7:	84 db                	test   %bl,%bl
  8009e9:	75 ef                	jne    8009da <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	53                   	push   %ebx
  8009f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f5:	53                   	push   %ebx
  8009f6:	e8 9a ff ff ff       	call   800995 <strlen>
  8009fb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009fe:	ff 75 0c             	pushl  0xc(%ebp)
  800a01:	01 d8                	add    %ebx,%eax
  800a03:	50                   	push   %eax
  800a04:	e8 c5 ff ff ff       	call   8009ce <strcpy>
	return dst;
}
  800a09:	89 d8                	mov    %ebx,%eax
  800a0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 75 08             	mov    0x8(%ebp),%esi
  800a18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a20:	89 f2                	mov    %esi,%edx
  800a22:	eb 0f                	jmp    800a33 <strncpy+0x23>
		*dst++ = *src;
  800a24:	83 c2 01             	add    $0x1,%edx
  800a27:	0f b6 01             	movzbl (%ecx),%eax
  800a2a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2d:	80 39 01             	cmpb   $0x1,(%ecx)
  800a30:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	75 ed                	jne    800a24 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a37:	89 f0                	mov    %esi,%eax
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 75 08             	mov    0x8(%ebp),%esi
  800a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a48:	8b 55 10             	mov    0x10(%ebp),%edx
  800a4b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4d:	85 d2                	test   %edx,%edx
  800a4f:	74 21                	je     800a72 <strlcpy+0x35>
  800a51:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a55:	89 f2                	mov    %esi,%edx
  800a57:	eb 09                	jmp    800a62 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a59:	83 c2 01             	add    $0x1,%edx
  800a5c:	83 c1 01             	add    $0x1,%ecx
  800a5f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a62:	39 c2                	cmp    %eax,%edx
  800a64:	74 09                	je     800a6f <strlcpy+0x32>
  800a66:	0f b6 19             	movzbl (%ecx),%ebx
  800a69:	84 db                	test   %bl,%bl
  800a6b:	75 ec                	jne    800a59 <strlcpy+0x1c>
  800a6d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a72:	29 f0                	sub    %esi,%eax
}
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a81:	eb 06                	jmp    800a89 <strcmp+0x11>
		p++, q++;
  800a83:	83 c1 01             	add    $0x1,%ecx
  800a86:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a89:	0f b6 01             	movzbl (%ecx),%eax
  800a8c:	84 c0                	test   %al,%al
  800a8e:	74 04                	je     800a94 <strcmp+0x1c>
  800a90:	3a 02                	cmp    (%edx),%al
  800a92:	74 ef                	je     800a83 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a94:	0f b6 c0             	movzbl %al,%eax
  800a97:	0f b6 12             	movzbl (%edx),%edx
  800a9a:	29 d0                	sub    %edx,%eax
}
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	53                   	push   %ebx
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa8:	89 c3                	mov    %eax,%ebx
  800aaa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aad:	eb 06                	jmp    800ab5 <strncmp+0x17>
		n--, p++, q++;
  800aaf:	83 c0 01             	add    $0x1,%eax
  800ab2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab5:	39 d8                	cmp    %ebx,%eax
  800ab7:	74 15                	je     800ace <strncmp+0x30>
  800ab9:	0f b6 08             	movzbl (%eax),%ecx
  800abc:	84 c9                	test   %cl,%cl
  800abe:	74 04                	je     800ac4 <strncmp+0x26>
  800ac0:	3a 0a                	cmp    (%edx),%cl
  800ac2:	74 eb                	je     800aaf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac4:	0f b6 00             	movzbl (%eax),%eax
  800ac7:	0f b6 12             	movzbl (%edx),%edx
  800aca:	29 d0                	sub    %edx,%eax
  800acc:	eb 05                	jmp    800ad3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ace:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae0:	eb 07                	jmp    800ae9 <strchr+0x13>
		if (*s == c)
  800ae2:	38 ca                	cmp    %cl,%dl
  800ae4:	74 0f                	je     800af5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae6:	83 c0 01             	add    $0x1,%eax
  800ae9:	0f b6 10             	movzbl (%eax),%edx
  800aec:	84 d2                	test   %dl,%dl
  800aee:	75 f2                	jne    800ae2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b01:	eb 03                	jmp    800b06 <strfind+0xf>
  800b03:	83 c0 01             	add    $0x1,%eax
  800b06:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b09:	38 ca                	cmp    %cl,%dl
  800b0b:	74 04                	je     800b11 <strfind+0x1a>
  800b0d:	84 d2                	test   %dl,%dl
  800b0f:	75 f2                	jne    800b03 <strfind+0xc>
			break;
	return (char *) s;
}
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1f:	85 c9                	test   %ecx,%ecx
  800b21:	74 36                	je     800b59 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b23:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b29:	75 28                	jne    800b53 <memset+0x40>
  800b2b:	f6 c1 03             	test   $0x3,%cl
  800b2e:	75 23                	jne    800b53 <memset+0x40>
		c &= 0xFF;
  800b30:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	c1 e3 08             	shl    $0x8,%ebx
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	c1 e6 18             	shl    $0x18,%esi
  800b3e:	89 d0                	mov    %edx,%eax
  800b40:	c1 e0 10             	shl    $0x10,%eax
  800b43:	09 f0                	or     %esi,%eax
  800b45:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b47:	89 d8                	mov    %ebx,%eax
  800b49:	09 d0                	or     %edx,%eax
  800b4b:	c1 e9 02             	shr    $0x2,%ecx
  800b4e:	fc                   	cld    
  800b4f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b51:	eb 06                	jmp    800b59 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b56:	fc                   	cld    
  800b57:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b59:	89 f8                	mov    %edi,%eax
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6e:	39 c6                	cmp    %eax,%esi
  800b70:	73 35                	jae    800ba7 <memmove+0x47>
  800b72:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b75:	39 d0                	cmp    %edx,%eax
  800b77:	73 2e                	jae    800ba7 <memmove+0x47>
		s += n;
		d += n;
  800b79:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	09 fe                	or     %edi,%esi
  800b80:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b86:	75 13                	jne    800b9b <memmove+0x3b>
  800b88:	f6 c1 03             	test   $0x3,%cl
  800b8b:	75 0e                	jne    800b9b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b8d:	83 ef 04             	sub    $0x4,%edi
  800b90:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b93:	c1 e9 02             	shr    $0x2,%ecx
  800b96:	fd                   	std    
  800b97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b99:	eb 09                	jmp    800ba4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9b:	83 ef 01             	sub    $0x1,%edi
  800b9e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba1:	fd                   	std    
  800ba2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba4:	fc                   	cld    
  800ba5:	eb 1d                	jmp    800bc4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba7:	89 f2                	mov    %esi,%edx
  800ba9:	09 c2                	or     %eax,%edx
  800bab:	f6 c2 03             	test   $0x3,%dl
  800bae:	75 0f                	jne    800bbf <memmove+0x5f>
  800bb0:	f6 c1 03             	test   $0x3,%cl
  800bb3:	75 0a                	jne    800bbf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb5:	c1 e9 02             	shr    $0x2,%ecx
  800bb8:	89 c7                	mov    %eax,%edi
  800bba:	fc                   	cld    
  800bbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbd:	eb 05                	jmp    800bc4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbf:	89 c7                	mov    %eax,%edi
  800bc1:	fc                   	cld    
  800bc2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bcb:	ff 75 10             	pushl  0x10(%ebp)
  800bce:	ff 75 0c             	pushl  0xc(%ebp)
  800bd1:	ff 75 08             	pushl  0x8(%ebp)
  800bd4:	e8 87 ff ff ff       	call   800b60 <memmove>
}
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
  800be3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be6:	89 c6                	mov    %eax,%esi
  800be8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800beb:	eb 1a                	jmp    800c07 <memcmp+0x2c>
		if (*s1 != *s2)
  800bed:	0f b6 08             	movzbl (%eax),%ecx
  800bf0:	0f b6 1a             	movzbl (%edx),%ebx
  800bf3:	38 d9                	cmp    %bl,%cl
  800bf5:	74 0a                	je     800c01 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf7:	0f b6 c1             	movzbl %cl,%eax
  800bfa:	0f b6 db             	movzbl %bl,%ebx
  800bfd:	29 d8                	sub    %ebx,%eax
  800bff:	eb 0f                	jmp    800c10 <memcmp+0x35>
		s1++, s2++;
  800c01:	83 c0 01             	add    $0x1,%eax
  800c04:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c07:	39 f0                	cmp    %esi,%eax
  800c09:	75 e2                	jne    800bed <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	53                   	push   %ebx
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1b:	89 c1                	mov    %eax,%ecx
  800c1d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c20:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c24:	eb 0a                	jmp    800c30 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c26:	0f b6 10             	movzbl (%eax),%edx
  800c29:	39 da                	cmp    %ebx,%edx
  800c2b:	74 07                	je     800c34 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2d:	83 c0 01             	add    $0x1,%eax
  800c30:	39 c8                	cmp    %ecx,%eax
  800c32:	72 f2                	jb     800c26 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c34:	5b                   	pop    %ebx
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c43:	eb 03                	jmp    800c48 <strtol+0x11>
		s++;
  800c45:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c48:	0f b6 01             	movzbl (%ecx),%eax
  800c4b:	3c 20                	cmp    $0x20,%al
  800c4d:	74 f6                	je     800c45 <strtol+0xe>
  800c4f:	3c 09                	cmp    $0x9,%al
  800c51:	74 f2                	je     800c45 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c53:	3c 2b                	cmp    $0x2b,%al
  800c55:	75 0a                	jne    800c61 <strtol+0x2a>
		s++;
  800c57:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5f:	eb 11                	jmp    800c72 <strtol+0x3b>
  800c61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c66:	3c 2d                	cmp    $0x2d,%al
  800c68:	75 08                	jne    800c72 <strtol+0x3b>
		s++, neg = 1;
  800c6a:	83 c1 01             	add    $0x1,%ecx
  800c6d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c78:	75 15                	jne    800c8f <strtol+0x58>
  800c7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7d:	75 10                	jne    800c8f <strtol+0x58>
  800c7f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c83:	75 7c                	jne    800d01 <strtol+0xca>
		s += 2, base = 16;
  800c85:	83 c1 02             	add    $0x2,%ecx
  800c88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8d:	eb 16                	jmp    800ca5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c8f:	85 db                	test   %ebx,%ebx
  800c91:	75 12                	jne    800ca5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c93:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c98:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9b:	75 08                	jne    800ca5 <strtol+0x6e>
		s++, base = 8;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  800caa:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cad:	0f b6 11             	movzbl (%ecx),%edx
  800cb0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb3:	89 f3                	mov    %esi,%ebx
  800cb5:	80 fb 09             	cmp    $0x9,%bl
  800cb8:	77 08                	ja     800cc2 <strtol+0x8b>
			dig = *s - '0';
  800cba:	0f be d2             	movsbl %dl,%edx
  800cbd:	83 ea 30             	sub    $0x30,%edx
  800cc0:	eb 22                	jmp    800ce4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc5:	89 f3                	mov    %esi,%ebx
  800cc7:	80 fb 19             	cmp    $0x19,%bl
  800cca:	77 08                	ja     800cd4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ccc:	0f be d2             	movsbl %dl,%edx
  800ccf:	83 ea 57             	sub    $0x57,%edx
  800cd2:	eb 10                	jmp    800ce4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd7:	89 f3                	mov    %esi,%ebx
  800cd9:	80 fb 19             	cmp    $0x19,%bl
  800cdc:	77 16                	ja     800cf4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cde:	0f be d2             	movsbl %dl,%edx
  800ce1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce7:	7d 0b                	jge    800cf4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce9:	83 c1 01             	add    $0x1,%ecx
  800cec:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf2:	eb b9                	jmp    800cad <strtol+0x76>

	if (endptr)
  800cf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf8:	74 0d                	je     800d07 <strtol+0xd0>
		*endptr = (char *) s;
  800cfa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cfd:	89 0e                	mov    %ecx,(%esi)
  800cff:	eb 06                	jmp    800d07 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d01:	85 db                	test   %ebx,%ebx
  800d03:	74 98                	je     800c9d <strtol+0x66>
  800d05:	eb 9e                	jmp    800ca5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d07:	89 c2                	mov    %eax,%edx
  800d09:	f7 da                	neg    %edx
  800d0b:	85 ff                	test   %edi,%edi
  800d0d:	0f 45 c2             	cmovne %edx,%eax
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
  800d15:	66 90                	xchg   %ax,%ax
  800d17:	66 90                	xchg   %ax,%ax
  800d19:	66 90                	xchg   %ax,%ax
  800d1b:	66 90                	xchg   %ax,%ax
  800d1d:	66 90                	xchg   %ax,%ax
  800d1f:	90                   	nop

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
