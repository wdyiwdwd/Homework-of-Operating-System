
obj/user/evilhello：     文件格式 elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 5d 00 00 00       	call   8000a2 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800055:	e8 c6 00 00 00       	call   800120 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	c1 e0 07             	shl    $0x7,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 ca 0f 80 00       	push   $0x800fca
  80010c:	6a 23                	push   $0x23
  80010e:	68 e7 0f 80 00       	push   $0x800fe7
  800113:	e8 15 02 00 00       	call   80032d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 ca 0f 80 00       	push   $0x800fca
  80018d:	6a 23                	push   $0x23
  80018f:	68 e7 0f 80 00       	push   $0x800fe7
  800194:	e8 94 01 00 00       	call   80032d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 ca 0f 80 00       	push   $0x800fca
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 e7 0f 80 00       	push   $0x800fe7
  8001d6:	e8 52 01 00 00       	call   80032d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 ca 0f 80 00       	push   $0x800fca
  800211:	6a 23                	push   $0x23
  800213:	68 e7 0f 80 00       	push   $0x800fe7
  800218:	e8 10 01 00 00       	call   80032d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 ca 0f 80 00       	push   $0x800fca
  800253:	6a 23                	push   $0x23
  800255:	68 e7 0f 80 00       	push   $0x800fe7
  80025a:	e8 ce 00 00 00       	call   80032d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 ca 0f 80 00       	push   $0x800fca
  800295:	6a 23                	push   $0x23
  800297:	68 e7 0f 80 00       	push   $0x800fe7
  80029c:	e8 8c 00 00 00       	call   80032d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002af:	be 00 00 00 00       	mov    $0x0,%esi
  8002b4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002df:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e2:	89 cb                	mov    %ecx,%ebx
  8002e4:	89 cf                	mov    %ecx,%edi
  8002e6:	89 ce                	mov    %ecx,%esi
  8002e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 17                	jle    800305 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	83 ec 0c             	sub    $0xc,%esp
  8002f1:	50                   	push   %eax
  8002f2:	6a 0c                	push   $0xc
  8002f4:	68 ca 0f 80 00       	push   $0x800fca
  8002f9:	6a 23                	push   $0x23
  8002fb:	68 e7 0f 80 00       	push   $0x800fe7
  800300:	e8 28 00 00 00       	call   80032d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800305:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5f                   	pop    %edi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <sys_change_pr>:

int
sys_change_pr(int pr)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800328:	5b                   	pop    %ebx
  800329:	5e                   	pop    %esi
  80032a:	5f                   	pop    %edi
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	56                   	push   %esi
  800331:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800332:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800335:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80033b:	e8 e0 fd ff ff       	call   800120 <sys_getenvid>
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	ff 75 0c             	pushl  0xc(%ebp)
  800346:	ff 75 08             	pushl  0x8(%ebp)
  800349:	56                   	push   %esi
  80034a:	50                   	push   %eax
  80034b:	68 f8 0f 80 00       	push   $0x800ff8
  800350:	e8 b1 00 00 00       	call   800406 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800355:	83 c4 18             	add    $0x18,%esp
  800358:	53                   	push   %ebx
  800359:	ff 75 10             	pushl  0x10(%ebp)
  80035c:	e8 54 00 00 00       	call   8003b5 <vcprintf>
	cprintf("\n");
  800361:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  800368:	e8 99 00 00 00       	call   800406 <cprintf>
  80036d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800370:	cc                   	int3   
  800371:	eb fd                	jmp    800370 <_panic+0x43>

00800373 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	53                   	push   %ebx
  800377:	83 ec 04             	sub    $0x4,%esp
  80037a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037d:	8b 13                	mov    (%ebx),%edx
  80037f:	8d 42 01             	lea    0x1(%edx),%eax
  800382:	89 03                	mov    %eax,(%ebx)
  800384:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800387:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80038b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800390:	75 1a                	jne    8003ac <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	68 ff 00 00 00       	push   $0xff
  80039a:	8d 43 08             	lea    0x8(%ebx),%eax
  80039d:	50                   	push   %eax
  80039e:	e8 ff fc ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8003a3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ac:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b3:	c9                   	leave  
  8003b4:	c3                   	ret    

008003b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c5:	00 00 00 
	b.cnt = 0;
  8003c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d2:	ff 75 0c             	pushl  0xc(%ebp)
  8003d5:	ff 75 08             	pushl  0x8(%ebp)
  8003d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	68 73 03 80 00       	push   $0x800373
  8003e4:	e8 54 01 00 00       	call   80053d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e9:	83 c4 08             	add    $0x8,%esp
  8003ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f8:	50                   	push   %eax
  8003f9:	e8 a4 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8003fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800404:	c9                   	leave  
  800405:	c3                   	ret    

00800406 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80040c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040f:	50                   	push   %eax
  800410:	ff 75 08             	pushl  0x8(%ebp)
  800413:	e8 9d ff ff ff       	call   8003b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	57                   	push   %edi
  80041e:	56                   	push   %esi
  80041f:	53                   	push   %ebx
  800420:	83 ec 1c             	sub    $0x1c,%esp
  800423:	89 c7                	mov    %eax,%edi
  800425:	89 d6                	mov    %edx,%esi
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800430:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800433:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800436:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80043e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800441:	39 d3                	cmp    %edx,%ebx
  800443:	72 05                	jb     80044a <printnum+0x30>
  800445:	39 45 10             	cmp    %eax,0x10(%ebp)
  800448:	77 45                	ja     80048f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044a:	83 ec 0c             	sub    $0xc,%esp
  80044d:	ff 75 18             	pushl  0x18(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800456:	53                   	push   %ebx
  800457:	ff 75 10             	pushl  0x10(%ebp)
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800460:	ff 75 e0             	pushl  -0x20(%ebp)
  800463:	ff 75 dc             	pushl  -0x24(%ebp)
  800466:	ff 75 d8             	pushl  -0x28(%ebp)
  800469:	e8 b2 08 00 00       	call   800d20 <__udivdi3>
  80046e:	83 c4 18             	add    $0x18,%esp
  800471:	52                   	push   %edx
  800472:	50                   	push   %eax
  800473:	89 f2                	mov    %esi,%edx
  800475:	89 f8                	mov    %edi,%eax
  800477:	e8 9e ff ff ff       	call   80041a <printnum>
  80047c:	83 c4 20             	add    $0x20,%esp
  80047f:	eb 18                	jmp    800499 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	56                   	push   %esi
  800485:	ff 75 18             	pushl  0x18(%ebp)
  800488:	ff d7                	call   *%edi
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	eb 03                	jmp    800492 <printnum+0x78>
  80048f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800492:	83 eb 01             	sub    $0x1,%ebx
  800495:	85 db                	test   %ebx,%ebx
  800497:	7f e8                	jg     800481 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	56                   	push   %esi
  80049d:	83 ec 04             	sub    $0x4,%esp
  8004a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ac:	e8 9f 09 00 00       	call   800e50 <__umoddi3>
  8004b1:	83 c4 14             	add    $0x14,%esp
  8004b4:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  8004bb:	50                   	push   %eax
  8004bc:	ff d7                	call   *%edi
}
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c4:	5b                   	pop    %ebx
  8004c5:	5e                   	pop    %esi
  8004c6:	5f                   	pop    %edi
  8004c7:	5d                   	pop    %ebp
  8004c8:	c3                   	ret    

008004c9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004cc:	83 fa 01             	cmp    $0x1,%edx
  8004cf:	7e 0e                	jle    8004df <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d1:	8b 10                	mov    (%eax),%edx
  8004d3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d6:	89 08                	mov    %ecx,(%eax)
  8004d8:	8b 02                	mov    (%edx),%eax
  8004da:	8b 52 04             	mov    0x4(%edx),%edx
  8004dd:	eb 22                	jmp    800501 <getuint+0x38>
	else if (lflag)
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 10                	je     8004f3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e3:	8b 10                	mov    (%eax),%edx
  8004e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e8:	89 08                	mov    %ecx,(%eax)
  8004ea:	8b 02                	mov    (%edx),%eax
  8004ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f1:	eb 0e                	jmp    800501 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f8:	89 08                	mov    %ecx,(%eax)
  8004fa:	8b 02                	mov    (%edx),%eax
  8004fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800501:	5d                   	pop    %ebp
  800502:	c3                   	ret    

00800503 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800509:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80050d:	8b 10                	mov    (%eax),%edx
  80050f:	3b 50 04             	cmp    0x4(%eax),%edx
  800512:	73 0a                	jae    80051e <sprintputch+0x1b>
		*b->buf++ = ch;
  800514:	8d 4a 01             	lea    0x1(%edx),%ecx
  800517:	89 08                	mov    %ecx,(%eax)
  800519:	8b 45 08             	mov    0x8(%ebp),%eax
  80051c:	88 02                	mov    %al,(%edx)
}
  80051e:	5d                   	pop    %ebp
  80051f:	c3                   	ret    

00800520 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800526:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800529:	50                   	push   %eax
  80052a:	ff 75 10             	pushl  0x10(%ebp)
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	ff 75 08             	pushl  0x8(%ebp)
  800533:	e8 05 00 00 00       	call   80053d <vprintfmt>
	va_end(ap);
}
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	57                   	push   %edi
  800541:	56                   	push   %esi
  800542:	53                   	push   %ebx
  800543:	83 ec 2c             	sub    $0x2c,%esp
  800546:	8b 75 08             	mov    0x8(%ebp),%esi
  800549:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80054f:	eb 1d                	jmp    80056e <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800551:	85 c0                	test   %eax,%eax
  800553:	75 0f                	jne    800564 <vprintfmt+0x27>
				csa = 0x0700;
  800555:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80055c:	07 00 00 
				return;
  80055f:	e9 c4 03 00 00       	jmp    800928 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	50                   	push   %eax
  800569:	ff d6                	call   *%esi
  80056b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800575:	83 f8 25             	cmp    $0x25,%eax
  800578:	75 d7                	jne    800551 <vprintfmt+0x14>
  80057a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80057e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800585:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800593:	ba 00 00 00 00       	mov    $0x0,%edx
  800598:	eb 07                	jmp    8005a1 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80059d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8d 47 01             	lea    0x1(%edi),%eax
  8005a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a7:	0f b6 07             	movzbl (%edi),%eax
  8005aa:	0f b6 c8             	movzbl %al,%ecx
  8005ad:	83 e8 23             	sub    $0x23,%eax
  8005b0:	3c 55                	cmp    $0x55,%al
  8005b2:	0f 87 55 03 00 00    	ja     80090d <vprintfmt+0x3d0>
  8005b8:	0f b6 c0             	movzbl %al,%eax
  8005bb:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005c9:	eb d6                	jmp    8005a1 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005d9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005dd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005e0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005e3:	83 fa 09             	cmp    $0x9,%edx
  8005e6:	77 39                	ja     800621 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005eb:	eb e9                	jmp    8005d6 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005fe:	eb 27                	jmp    800627 <vprintfmt+0xea>
  800600:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800603:	85 c0                	test   %eax,%eax
  800605:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060a:	0f 49 c8             	cmovns %eax,%ecx
  80060d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800613:	eb 8c                	jmp    8005a1 <vprintfmt+0x64>
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800618:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80061f:	eb 80                	jmp    8005a1 <vprintfmt+0x64>
  800621:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800624:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800627:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80062b:	0f 89 70 ff ff ff    	jns    8005a1 <vprintfmt+0x64>
				width = precision, precision = -1;
  800631:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800634:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800637:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80063e:	e9 5e ff ff ff       	jmp    8005a1 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800643:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800649:	e9 53 ff ff ff       	jmp    8005a1 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	ff 30                	pushl  (%eax)
  80065d:	ff d6                	call   *%esi
			break;
  80065f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800665:	e9 04 ff ff ff       	jmp    80056e <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)
  800673:	8b 00                	mov    (%eax),%eax
  800675:	99                   	cltd   
  800676:	31 d0                	xor    %edx,%eax
  800678:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067a:	83 f8 08             	cmp    $0x8,%eax
  80067d:	7f 0b                	jg     80068a <vprintfmt+0x14d>
  80067f:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800686:	85 d2                	test   %edx,%edx
  800688:	75 18                	jne    8006a2 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80068a:	50                   	push   %eax
  80068b:	68 36 10 80 00       	push   $0x801036
  800690:	53                   	push   %ebx
  800691:	56                   	push   %esi
  800692:	e8 89 fe ff ff       	call   800520 <printfmt>
  800697:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80069d:	e9 cc fe ff ff       	jmp    80056e <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8006a2:	52                   	push   %edx
  8006a3:	68 3f 10 80 00       	push   $0x80103f
  8006a8:	53                   	push   %ebx
  8006a9:	56                   	push   %esi
  8006aa:	e8 71 fe ff ff       	call   800520 <printfmt>
  8006af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b5:	e9 b4 fe ff ff       	jmp    80056e <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006c5:	85 ff                	test   %edi,%edi
  8006c7:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  8006cc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d3:	0f 8e 94 00 00 00    	jle    80076d <vprintfmt+0x230>
  8006d9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006dd:	0f 84 98 00 00 00    	je     80077b <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	ff 75 d0             	pushl  -0x30(%ebp)
  8006e9:	57                   	push   %edi
  8006ea:	e8 c1 02 00 00       	call   8009b0 <strnlen>
  8006ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f2:	29 c1                	sub    %eax,%ecx
  8006f4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006fa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800701:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800704:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800706:	eb 0f                	jmp    800717 <vprintfmt+0x1da>
					putch(padc, putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	ff 75 e0             	pushl  -0x20(%ebp)
  80070f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	83 ef 01             	sub    $0x1,%edi
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	85 ff                	test   %edi,%edi
  800719:	7f ed                	jg     800708 <vprintfmt+0x1cb>
  80071b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80071e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800721:	85 c9                	test   %ecx,%ecx
  800723:	b8 00 00 00 00       	mov    $0x0,%eax
  800728:	0f 49 c1             	cmovns %ecx,%eax
  80072b:	29 c1                	sub    %eax,%ecx
  80072d:	89 75 08             	mov    %esi,0x8(%ebp)
  800730:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800733:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800736:	89 cb                	mov    %ecx,%ebx
  800738:	eb 4d                	jmp    800787 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80073a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80073e:	74 1b                	je     80075b <vprintfmt+0x21e>
  800740:	0f be c0             	movsbl %al,%eax
  800743:	83 e8 20             	sub    $0x20,%eax
  800746:	83 f8 5e             	cmp    $0x5e,%eax
  800749:	76 10                	jbe    80075b <vprintfmt+0x21e>
					putch('?', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	6a 3f                	push   $0x3f
  800753:	ff 55 08             	call   *0x8(%ebp)
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 0d                	jmp    800768 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	ff 75 0c             	pushl  0xc(%ebp)
  800761:	52                   	push   %edx
  800762:	ff 55 08             	call   *0x8(%ebp)
  800765:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800768:	83 eb 01             	sub    $0x1,%ebx
  80076b:	eb 1a                	jmp    800787 <vprintfmt+0x24a>
  80076d:	89 75 08             	mov    %esi,0x8(%ebp)
  800770:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800773:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800776:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800779:	eb 0c                	jmp    800787 <vprintfmt+0x24a>
  80077b:	89 75 08             	mov    %esi,0x8(%ebp)
  80077e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800781:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800784:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800787:	83 c7 01             	add    $0x1,%edi
  80078a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80078e:	0f be d0             	movsbl %al,%edx
  800791:	85 d2                	test   %edx,%edx
  800793:	74 23                	je     8007b8 <vprintfmt+0x27b>
  800795:	85 f6                	test   %esi,%esi
  800797:	78 a1                	js     80073a <vprintfmt+0x1fd>
  800799:	83 ee 01             	sub    $0x1,%esi
  80079c:	79 9c                	jns    80073a <vprintfmt+0x1fd>
  80079e:	89 df                	mov    %ebx,%edi
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a6:	eb 18                	jmp    8007c0 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	53                   	push   %ebx
  8007ac:	6a 20                	push   $0x20
  8007ae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b0:	83 ef 01             	sub    $0x1,%edi
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	eb 08                	jmp    8007c0 <vprintfmt+0x283>
  8007b8:	89 df                	mov    %ebx,%edi
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c0:	85 ff                	test   %edi,%edi
  8007c2:	7f e4                	jg     8007a8 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c7:	e9 a2 fd ff ff       	jmp    80056e <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007cc:	83 fa 01             	cmp    $0x1,%edx
  8007cf:	7e 16                	jle    8007e7 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 50 08             	lea    0x8(%eax),%edx
  8007d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007da:	8b 50 04             	mov    0x4(%eax),%edx
  8007dd:	8b 00                	mov    (%eax),%eax
  8007df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e5:	eb 32                	jmp    800819 <vprintfmt+0x2dc>
	else if (lflag)
  8007e7:	85 d2                	test   %edx,%edx
  8007e9:	74 18                	je     800803 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8d 50 04             	lea    0x4(%eax),%edx
  8007f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f4:	8b 00                	mov    (%eax),%eax
  8007f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f9:	89 c1                	mov    %eax,%ecx
  8007fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800801:	eb 16                	jmp    800819 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	8d 50 04             	lea    0x4(%eax),%edx
  800809:	89 55 14             	mov    %edx,0x14(%ebp)
  80080c:	8b 00                	mov    (%eax),%eax
  80080e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800811:	89 c1                	mov    %eax,%ecx
  800813:	c1 f9 1f             	sar    $0x1f,%ecx
  800816:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800819:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80081c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800824:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800828:	79 74                	jns    80089e <vprintfmt+0x361>
				putch('-', putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	53                   	push   %ebx
  80082e:	6a 2d                	push   $0x2d
  800830:	ff d6                	call   *%esi
				num = -(long long) num;
  800832:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800835:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800838:	f7 d8                	neg    %eax
  80083a:	83 d2 00             	adc    $0x0,%edx
  80083d:	f7 da                	neg    %edx
  80083f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800842:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800847:	eb 55                	jmp    80089e <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
  80084c:	e8 78 fc ff ff       	call   8004c9 <getuint>
			base = 10;
  800851:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800856:	eb 46                	jmp    80089e <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800858:	8d 45 14             	lea    0x14(%ebp),%eax
  80085b:	e8 69 fc ff ff       	call   8004c9 <getuint>
      base = 8;
  800860:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800865:	eb 37                	jmp    80089e <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	53                   	push   %ebx
  80086b:	6a 30                	push   $0x30
  80086d:	ff d6                	call   *%esi
			putch('x', putdat);
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 78                	push   $0x78
  800875:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8d 50 04             	lea    0x4(%eax),%edx
  80087d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800880:	8b 00                	mov    (%eax),%eax
  800882:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800887:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80088f:	eb 0d                	jmp    80089e <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800891:	8d 45 14             	lea    0x14(%ebp),%eax
  800894:	e8 30 fc ff ff       	call   8004c9 <getuint>
			base = 16;
  800899:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089e:	83 ec 0c             	sub    $0xc,%esp
  8008a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008a5:	57                   	push   %edi
  8008a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a9:	51                   	push   %ecx
  8008aa:	52                   	push   %edx
  8008ab:	50                   	push   %eax
  8008ac:	89 da                	mov    %ebx,%edx
  8008ae:	89 f0                	mov    %esi,%eax
  8008b0:	e8 65 fb ff ff       	call   80041a <printnum>
			break;
  8008b5:	83 c4 20             	add    $0x20,%esp
  8008b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008bb:	e9 ae fc ff ff       	jmp    80056e <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c0:	83 ec 08             	sub    $0x8,%esp
  8008c3:	53                   	push   %ebx
  8008c4:	51                   	push   %ecx
  8008c5:	ff d6                	call   *%esi
			break;
  8008c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008cd:	e9 9c fc ff ff       	jmp    80056e <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d2:	83 fa 01             	cmp    $0x1,%edx
  8008d5:	7e 0d                	jle    8008e4 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8d 50 08             	lea    0x8(%eax),%edx
  8008dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e0:	8b 00                	mov    (%eax),%eax
  8008e2:	eb 1c                	jmp    800900 <vprintfmt+0x3c3>
	else if (lflag)
  8008e4:	85 d2                	test   %edx,%edx
  8008e6:	74 0d                	je     8008f5 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f1:	8b 00                	mov    (%eax),%eax
  8008f3:	eb 0b                	jmp    800900 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8d 50 04             	lea    0x4(%eax),%edx
  8008fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fe:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800900:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800905:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800908:	e9 61 fc ff ff       	jmp    80056e <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	53                   	push   %ebx
  800911:	6a 25                	push   $0x25
  800913:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	eb 03                	jmp    80091d <vprintfmt+0x3e0>
  80091a:	83 ef 01             	sub    $0x1,%edi
  80091d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800921:	75 f7                	jne    80091a <vprintfmt+0x3dd>
  800923:	e9 46 fc ff ff       	jmp    80056e <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800928:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	83 ec 18             	sub    $0x18,%esp
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800943:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094d:	85 c0                	test   %eax,%eax
  80094f:	74 26                	je     800977 <vsnprintf+0x47>
  800951:	85 d2                	test   %edx,%edx
  800953:	7e 22                	jle    800977 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800955:	ff 75 14             	pushl  0x14(%ebp)
  800958:	ff 75 10             	pushl  0x10(%ebp)
  80095b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095e:	50                   	push   %eax
  80095f:	68 03 05 80 00       	push   $0x800503
  800964:	e8 d4 fb ff ff       	call   80053d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800969:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80096c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800972:	83 c4 10             	add    $0x10,%esp
  800975:	eb 05                	jmp    80097c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800977:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800984:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800987:	50                   	push   %eax
  800988:	ff 75 10             	pushl  0x10(%ebp)
  80098b:	ff 75 0c             	pushl  0xc(%ebp)
  80098e:	ff 75 08             	pushl  0x8(%ebp)
  800991:	e8 9a ff ff ff       	call   800930 <vsnprintf>
	va_end(ap);

	return rc;
}
  800996:	c9                   	leave  
  800997:	c3                   	ret    

00800998 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80099e:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a3:	eb 03                	jmp    8009a8 <strlen+0x10>
		n++;
  8009a5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ac:	75 f7                	jne    8009a5 <strlen+0xd>
		n++;
	return n;
}
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009be:	eb 03                	jmp    8009c3 <strnlen+0x13>
		n++;
  8009c0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c3:	39 c2                	cmp    %eax,%edx
  8009c5:	74 08                	je     8009cf <strnlen+0x1f>
  8009c7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009cb:	75 f3                	jne    8009c0 <strnlen+0x10>
  8009cd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	53                   	push   %ebx
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009db:	89 c2                	mov    %eax,%edx
  8009dd:	83 c2 01             	add    $0x1,%edx
  8009e0:	83 c1 01             	add    $0x1,%ecx
  8009e3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ea:	84 db                	test   %bl,%bl
  8009ec:	75 ef                	jne    8009dd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f8:	53                   	push   %ebx
  8009f9:	e8 9a ff ff ff       	call   800998 <strlen>
  8009fe:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a01:	ff 75 0c             	pushl  0xc(%ebp)
  800a04:	01 d8                	add    %ebx,%eax
  800a06:	50                   	push   %eax
  800a07:	e8 c5 ff ff ff       	call   8009d1 <strcpy>
	return dst;
}
  800a0c:	89 d8                	mov    %ebx,%eax
  800a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a23:	89 f2                	mov    %esi,%edx
  800a25:	eb 0f                	jmp    800a36 <strncpy+0x23>
		*dst++ = *src;
  800a27:	83 c2 01             	add    $0x1,%edx
  800a2a:	0f b6 01             	movzbl (%ecx),%eax
  800a2d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a30:	80 39 01             	cmpb   $0x1,(%ecx)
  800a33:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a36:	39 da                	cmp    %ebx,%edx
  800a38:	75 ed                	jne    800a27 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a3a:	89 f0                	mov    %esi,%eax
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 75 08             	mov    0x8(%ebp),%esi
  800a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4b:	8b 55 10             	mov    0x10(%ebp),%edx
  800a4e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a50:	85 d2                	test   %edx,%edx
  800a52:	74 21                	je     800a75 <strlcpy+0x35>
  800a54:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a58:	89 f2                	mov    %esi,%edx
  800a5a:	eb 09                	jmp    800a65 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a5c:	83 c2 01             	add    $0x1,%edx
  800a5f:	83 c1 01             	add    $0x1,%ecx
  800a62:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a65:	39 c2                	cmp    %eax,%edx
  800a67:	74 09                	je     800a72 <strlcpy+0x32>
  800a69:	0f b6 19             	movzbl (%ecx),%ebx
  800a6c:	84 db                	test   %bl,%bl
  800a6e:	75 ec                	jne    800a5c <strlcpy+0x1c>
  800a70:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a72:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a75:	29 f0                	sub    %esi,%eax
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a81:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a84:	eb 06                	jmp    800a8c <strcmp+0x11>
		p++, q++;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8c:	0f b6 01             	movzbl (%ecx),%eax
  800a8f:	84 c0                	test   %al,%al
  800a91:	74 04                	je     800a97 <strcmp+0x1c>
  800a93:	3a 02                	cmp    (%edx),%al
  800a95:	74 ef                	je     800a86 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a97:	0f b6 c0             	movzbl %al,%eax
  800a9a:	0f b6 12             	movzbl (%edx),%edx
  800a9d:	29 d0                	sub    %edx,%eax
}
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	53                   	push   %ebx
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aab:	89 c3                	mov    %eax,%ebx
  800aad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ab0:	eb 06                	jmp    800ab8 <strncmp+0x17>
		n--, p++, q++;
  800ab2:	83 c0 01             	add    $0x1,%eax
  800ab5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab8:	39 d8                	cmp    %ebx,%eax
  800aba:	74 15                	je     800ad1 <strncmp+0x30>
  800abc:	0f b6 08             	movzbl (%eax),%ecx
  800abf:	84 c9                	test   %cl,%cl
  800ac1:	74 04                	je     800ac7 <strncmp+0x26>
  800ac3:	3a 0a                	cmp    (%edx),%cl
  800ac5:	74 eb                	je     800ab2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac7:	0f b6 00             	movzbl (%eax),%eax
  800aca:	0f b6 12             	movzbl (%edx),%edx
  800acd:	29 d0                	sub    %edx,%eax
  800acf:	eb 05                	jmp    800ad6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae3:	eb 07                	jmp    800aec <strchr+0x13>
		if (*s == c)
  800ae5:	38 ca                	cmp    %cl,%dl
  800ae7:	74 0f                	je     800af8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae9:	83 c0 01             	add    $0x1,%eax
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	84 d2                	test   %dl,%dl
  800af1:	75 f2                	jne    800ae5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b04:	eb 03                	jmp    800b09 <strfind+0xf>
  800b06:	83 c0 01             	add    $0x1,%eax
  800b09:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b0c:	38 ca                	cmp    %cl,%dl
  800b0e:	74 04                	je     800b14 <strfind+0x1a>
  800b10:	84 d2                	test   %dl,%dl
  800b12:	75 f2                	jne    800b06 <strfind+0xc>
			break;
	return (char *) s;
}
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
  800b1c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b22:	85 c9                	test   %ecx,%ecx
  800b24:	74 36                	je     800b5c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b26:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2c:	75 28                	jne    800b56 <memset+0x40>
  800b2e:	f6 c1 03             	test   $0x3,%cl
  800b31:	75 23                	jne    800b56 <memset+0x40>
		c &= 0xFF;
  800b33:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	c1 e3 08             	shl    $0x8,%ebx
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	c1 e6 18             	shl    $0x18,%esi
  800b41:	89 d0                	mov    %edx,%eax
  800b43:	c1 e0 10             	shl    $0x10,%eax
  800b46:	09 f0                	or     %esi,%eax
  800b48:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b4a:	89 d8                	mov    %ebx,%eax
  800b4c:	09 d0                	or     %edx,%eax
  800b4e:	c1 e9 02             	shr    $0x2,%ecx
  800b51:	fc                   	cld    
  800b52:	f3 ab                	rep stos %eax,%es:(%edi)
  800b54:	eb 06                	jmp    800b5c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b59:	fc                   	cld    
  800b5a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5c:	89 f8                	mov    %edi,%eax
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b71:	39 c6                	cmp    %eax,%esi
  800b73:	73 35                	jae    800baa <memmove+0x47>
  800b75:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b78:	39 d0                	cmp    %edx,%eax
  800b7a:	73 2e                	jae    800baa <memmove+0x47>
		s += n;
		d += n;
  800b7c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	09 fe                	or     %edi,%esi
  800b83:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b89:	75 13                	jne    800b9e <memmove+0x3b>
  800b8b:	f6 c1 03             	test   $0x3,%cl
  800b8e:	75 0e                	jne    800b9e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b90:	83 ef 04             	sub    $0x4,%edi
  800b93:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b96:	c1 e9 02             	shr    $0x2,%ecx
  800b99:	fd                   	std    
  800b9a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9c:	eb 09                	jmp    800ba7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9e:	83 ef 01             	sub    $0x1,%edi
  800ba1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba4:	fd                   	std    
  800ba5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba7:	fc                   	cld    
  800ba8:	eb 1d                	jmp    800bc7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baa:	89 f2                	mov    %esi,%edx
  800bac:	09 c2                	or     %eax,%edx
  800bae:	f6 c2 03             	test   $0x3,%dl
  800bb1:	75 0f                	jne    800bc2 <memmove+0x5f>
  800bb3:	f6 c1 03             	test   $0x3,%cl
  800bb6:	75 0a                	jne    800bc2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb8:	c1 e9 02             	shr    $0x2,%ecx
  800bbb:	89 c7                	mov    %eax,%edi
  800bbd:	fc                   	cld    
  800bbe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc0:	eb 05                	jmp    800bc7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc2:	89 c7                	mov    %eax,%edi
  800bc4:	fc                   	cld    
  800bc5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bce:	ff 75 10             	pushl  0x10(%ebp)
  800bd1:	ff 75 0c             	pushl  0xc(%ebp)
  800bd4:	ff 75 08             	pushl  0x8(%ebp)
  800bd7:	e8 87 ff ff ff       	call   800b63 <memmove>
}
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	8b 45 08             	mov    0x8(%ebp),%eax
  800be6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be9:	89 c6                	mov    %eax,%esi
  800beb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bee:	eb 1a                	jmp    800c0a <memcmp+0x2c>
		if (*s1 != *s2)
  800bf0:	0f b6 08             	movzbl (%eax),%ecx
  800bf3:	0f b6 1a             	movzbl (%edx),%ebx
  800bf6:	38 d9                	cmp    %bl,%cl
  800bf8:	74 0a                	je     800c04 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bfa:	0f b6 c1             	movzbl %cl,%eax
  800bfd:	0f b6 db             	movzbl %bl,%ebx
  800c00:	29 d8                	sub    %ebx,%eax
  800c02:	eb 0f                	jmp    800c13 <memcmp+0x35>
		s1++, s2++;
  800c04:	83 c0 01             	add    $0x1,%eax
  800c07:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0a:	39 f0                	cmp    %esi,%eax
  800c0c:	75 e2                	jne    800bf0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	53                   	push   %ebx
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1e:	89 c1                	mov    %eax,%ecx
  800c20:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c23:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c27:	eb 0a                	jmp    800c33 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c29:	0f b6 10             	movzbl (%eax),%edx
  800c2c:	39 da                	cmp    %ebx,%edx
  800c2e:	74 07                	je     800c37 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c30:	83 c0 01             	add    $0x1,%eax
  800c33:	39 c8                	cmp    %ecx,%eax
  800c35:	72 f2                	jb     800c29 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c37:	5b                   	pop    %ebx
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c46:	eb 03                	jmp    800c4b <strtol+0x11>
		s++;
  800c48:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4b:	0f b6 01             	movzbl (%ecx),%eax
  800c4e:	3c 20                	cmp    $0x20,%al
  800c50:	74 f6                	je     800c48 <strtol+0xe>
  800c52:	3c 09                	cmp    $0x9,%al
  800c54:	74 f2                	je     800c48 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c56:	3c 2b                	cmp    $0x2b,%al
  800c58:	75 0a                	jne    800c64 <strtol+0x2a>
		s++;
  800c5a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c62:	eb 11                	jmp    800c75 <strtol+0x3b>
  800c64:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c69:	3c 2d                	cmp    $0x2d,%al
  800c6b:	75 08                	jne    800c75 <strtol+0x3b>
		s++, neg = 1;
  800c6d:	83 c1 01             	add    $0x1,%ecx
  800c70:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c75:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c7b:	75 15                	jne    800c92 <strtol+0x58>
  800c7d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c80:	75 10                	jne    800c92 <strtol+0x58>
  800c82:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c86:	75 7c                	jne    800d04 <strtol+0xca>
		s += 2, base = 16;
  800c88:	83 c1 02             	add    $0x2,%ecx
  800c8b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c90:	eb 16                	jmp    800ca8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c92:	85 db                	test   %ebx,%ebx
  800c94:	75 12                	jne    800ca8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c96:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9e:	75 08                	jne    800ca8 <strtol+0x6e>
		s++, base = 8;
  800ca0:	83 c1 01             	add    $0x1,%ecx
  800ca3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cad:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb0:	0f b6 11             	movzbl (%ecx),%edx
  800cb3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb6:	89 f3                	mov    %esi,%ebx
  800cb8:	80 fb 09             	cmp    $0x9,%bl
  800cbb:	77 08                	ja     800cc5 <strtol+0x8b>
			dig = *s - '0';
  800cbd:	0f be d2             	movsbl %dl,%edx
  800cc0:	83 ea 30             	sub    $0x30,%edx
  800cc3:	eb 22                	jmp    800ce7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc8:	89 f3                	mov    %esi,%ebx
  800cca:	80 fb 19             	cmp    $0x19,%bl
  800ccd:	77 08                	ja     800cd7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ccf:	0f be d2             	movsbl %dl,%edx
  800cd2:	83 ea 57             	sub    $0x57,%edx
  800cd5:	eb 10                	jmp    800ce7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cda:	89 f3                	mov    %esi,%ebx
  800cdc:	80 fb 19             	cmp    $0x19,%bl
  800cdf:	77 16                	ja     800cf7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ce1:	0f be d2             	movsbl %dl,%edx
  800ce4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cea:	7d 0b                	jge    800cf7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cec:	83 c1 01             	add    $0x1,%ecx
  800cef:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf5:	eb b9                	jmp    800cb0 <strtol+0x76>

	if (endptr)
  800cf7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cfb:	74 0d                	je     800d0a <strtol+0xd0>
		*endptr = (char *) s;
  800cfd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d00:	89 0e                	mov    %ecx,(%esi)
  800d02:	eb 06                	jmp    800d0a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d04:	85 db                	test   %ebx,%ebx
  800d06:	74 98                	je     800ca0 <strtol+0x66>
  800d08:	eb 9e                	jmp    800ca8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d0a:	89 c2                	mov    %eax,%edx
  800d0c:	f7 da                	neg    %edx
  800d0e:	85 ff                	test   %edi,%edi
  800d10:	0f 45 c2             	cmovne %edx,%eax
}
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    
  800d18:	66 90                	xchg   %ax,%ax
  800d1a:	66 90                	xchg   %ax,%ax
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

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
