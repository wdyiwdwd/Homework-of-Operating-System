
obj/user/buggyhello2：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800059:	e8 c6 00 00 00       	call   800124 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7e 17                	jle    80011c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 d8 0f 80 00       	push   $0x800fd8
  800110:	6a 23                	push   $0x23
  800112:	68 f5 0f 80 00       	push   $0x800ff5
  800117:	e8 15 02 00 00       	call   800331 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 17                	jle    80019d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 d8 0f 80 00       	push   $0x800fd8
  800191:	6a 23                	push   $0x23
  800193:	68 f5 0f 80 00       	push   $0x800ff5
  800198:	e8 94 01 00 00       	call   800331 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7e 17                	jle    8001df <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 d8 0f 80 00       	push   $0x800fd8
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 f5 0f 80 00       	push   $0x800ff5
  8001da:	e8 52 01 00 00       	call   800331 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 17                	jle    800221 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 d8 0f 80 00       	push   $0x800fd8
  800215:	6a 23                	push   $0x23
  800217:	68 f5 0f 80 00       	push   $0x800ff5
  80021c:	e8 10 01 00 00       	call   800331 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	b8 08 00 00 00       	mov    $0x8,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 17                	jle    800263 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 d8 0f 80 00       	push   $0x800fd8
  800257:	6a 23                	push   $0x23
  800259:	68 f5 0f 80 00       	push   $0x800ff5
  80025e:	e8 ce 00 00 00       	call   800331 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 17                	jle    8002a5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 d8 0f 80 00       	push   $0x800fd8
  800299:	6a 23                	push   $0x23
  80029b:	68 f5 0f 80 00       	push   $0x800ff5
  8002a0:	e8 8c 00 00 00       	call   800331 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b3:	be 00 00 00 00       	mov    $0x0,%esi
  8002b8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	89 cb                	mov    %ecx,%ebx
  8002e8:	89 cf                	mov    %ecx,%edi
  8002ea:	89 ce                	mov    %ecx,%esi
  8002ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7e 17                	jle    800309 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	83 ec 0c             	sub    $0xc,%esp
  8002f5:	50                   	push   %eax
  8002f6:	6a 0c                	push   $0xc
  8002f8:	68 d8 0f 80 00       	push   $0x800fd8
  8002fd:	6a 23                	push   $0x23
  8002ff:	68 f5 0f 80 00       	push   $0x800ff5
  800304:	e8 28 00 00 00       	call   800331 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800336:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800339:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80033f:	e8 e0 fd ff ff       	call   800124 <sys_getenvid>
  800344:	83 ec 0c             	sub    $0xc,%esp
  800347:	ff 75 0c             	pushl  0xc(%ebp)
  80034a:	ff 75 08             	pushl  0x8(%ebp)
  80034d:	56                   	push   %esi
  80034e:	50                   	push   %eax
  80034f:	68 04 10 80 00       	push   $0x801004
  800354:	e8 b1 00 00 00       	call   80040a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	53                   	push   %ebx
  80035d:	ff 75 10             	pushl  0x10(%ebp)
  800360:	e8 54 00 00 00       	call   8003b9 <vcprintf>
	cprintf("\n");
  800365:	c7 04 24 cc 0f 80 00 	movl   $0x800fcc,(%esp)
  80036c:	e8 99 00 00 00       	call   80040a <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800374:	cc                   	int3   
  800375:	eb fd                	jmp    800374 <_panic+0x43>

00800377 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	53                   	push   %ebx
  80037b:	83 ec 04             	sub    $0x4,%esp
  80037e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800381:	8b 13                	mov    (%ebx),%edx
  800383:	8d 42 01             	lea    0x1(%edx),%eax
  800386:	89 03                	mov    %eax,(%ebx)
  800388:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80038f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800394:	75 1a                	jne    8003b0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800396:	83 ec 08             	sub    $0x8,%esp
  800399:	68 ff 00 00 00       	push   $0xff
  80039e:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a1:	50                   	push   %eax
  8003a2:	e8 ff fc ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  8003a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ad:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c9:	00 00 00 
	b.cnt = 0;
  8003cc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d6:	ff 75 0c             	pushl  0xc(%ebp)
  8003d9:	ff 75 08             	pushl  0x8(%ebp)
  8003dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e2:	50                   	push   %eax
  8003e3:	68 77 03 80 00       	push   $0x800377
  8003e8:	e8 54 01 00 00       	call   800541 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ed:	83 c4 08             	add    $0x8,%esp
  8003f0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003fc:	50                   	push   %eax
  8003fd:	e8 a4 fc ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  800402:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800408:	c9                   	leave  
  800409:	c3                   	ret    

0080040a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800410:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800413:	50                   	push   %eax
  800414:	ff 75 08             	pushl  0x8(%ebp)
  800417:	e8 9d ff ff ff       	call   8003b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    

0080041e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	57                   	push   %edi
  800422:	56                   	push   %esi
  800423:	53                   	push   %ebx
  800424:	83 ec 1c             	sub    $0x1c,%esp
  800427:	89 c7                	mov    %eax,%edi
  800429:	89 d6                	mov    %edx,%esi
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800431:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800434:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800437:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80043a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800442:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800445:	39 d3                	cmp    %edx,%ebx
  800447:	72 05                	jb     80044e <printnum+0x30>
  800449:	39 45 10             	cmp    %eax,0x10(%ebp)
  80044c:	77 45                	ja     800493 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044e:	83 ec 0c             	sub    $0xc,%esp
  800451:	ff 75 18             	pushl  0x18(%ebp)
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80045a:	53                   	push   %ebx
  80045b:	ff 75 10             	pushl  0x10(%ebp)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	ff 75 e4             	pushl  -0x1c(%ebp)
  800464:	ff 75 e0             	pushl  -0x20(%ebp)
  800467:	ff 75 dc             	pushl  -0x24(%ebp)
  80046a:	ff 75 d8             	pushl  -0x28(%ebp)
  80046d:	e8 ae 08 00 00       	call   800d20 <__udivdi3>
  800472:	83 c4 18             	add    $0x18,%esp
  800475:	52                   	push   %edx
  800476:	50                   	push   %eax
  800477:	89 f2                	mov    %esi,%edx
  800479:	89 f8                	mov    %edi,%eax
  80047b:	e8 9e ff ff ff       	call   80041e <printnum>
  800480:	83 c4 20             	add    $0x20,%esp
  800483:	eb 18                	jmp    80049d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	56                   	push   %esi
  800489:	ff 75 18             	pushl  0x18(%ebp)
  80048c:	ff d7                	call   *%edi
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	eb 03                	jmp    800496 <printnum+0x78>
  800493:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800496:	83 eb 01             	sub    $0x1,%ebx
  800499:	85 db                	test   %ebx,%ebx
  80049b:	7f e8                	jg     800485 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	56                   	push   %esi
  8004a1:	83 ec 04             	sub    $0x4,%esp
  8004a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b0:	e8 9b 09 00 00       	call   800e50 <__umoddi3>
  8004b5:	83 c4 14             	add    $0x14,%esp
  8004b8:	0f be 80 28 10 80 00 	movsbl 0x801028(%eax),%eax
  8004bf:	50                   	push   %eax
  8004c0:	ff d7                	call   *%edi
}
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c8:	5b                   	pop    %ebx
  8004c9:	5e                   	pop    %esi
  8004ca:	5f                   	pop    %edi
  8004cb:	5d                   	pop    %ebp
  8004cc:	c3                   	ret    

008004cd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d0:	83 fa 01             	cmp    $0x1,%edx
  8004d3:	7e 0e                	jle    8004e3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d5:	8b 10                	mov    (%eax),%edx
  8004d7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004da:	89 08                	mov    %ecx,(%eax)
  8004dc:	8b 02                	mov    (%edx),%eax
  8004de:	8b 52 04             	mov    0x4(%edx),%edx
  8004e1:	eb 22                	jmp    800505 <getuint+0x38>
	else if (lflag)
  8004e3:	85 d2                	test   %edx,%edx
  8004e5:	74 10                	je     8004f7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e7:	8b 10                	mov    (%eax),%edx
  8004e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ec:	89 08                	mov    %ecx,(%eax)
  8004ee:	8b 02                	mov    (%edx),%eax
  8004f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f5:	eb 0e                	jmp    800505 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f7:	8b 10                	mov    (%eax),%edx
  8004f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 02                	mov    (%edx),%eax
  800500:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800505:	5d                   	pop    %ebp
  800506:	c3                   	ret    

00800507 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80050d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800511:	8b 10                	mov    (%eax),%edx
  800513:	3b 50 04             	cmp    0x4(%eax),%edx
  800516:	73 0a                	jae    800522 <sprintputch+0x1b>
		*b->buf++ = ch;
  800518:	8d 4a 01             	lea    0x1(%edx),%ecx
  80051b:	89 08                	mov    %ecx,(%eax)
  80051d:	8b 45 08             	mov    0x8(%ebp),%eax
  800520:	88 02                	mov    %al,(%edx)
}
  800522:	5d                   	pop    %ebp
  800523:	c3                   	ret    

00800524 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80052a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80052d:	50                   	push   %eax
  80052e:	ff 75 10             	pushl  0x10(%ebp)
  800531:	ff 75 0c             	pushl  0xc(%ebp)
  800534:	ff 75 08             	pushl  0x8(%ebp)
  800537:	e8 05 00 00 00       	call   800541 <vprintfmt>
	va_end(ap);
}
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	57                   	push   %edi
  800545:	56                   	push   %esi
  800546:	53                   	push   %ebx
  800547:	83 ec 2c             	sub    $0x2c,%esp
  80054a:	8b 75 08             	mov    0x8(%ebp),%esi
  80054d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800550:	8b 7d 10             	mov    0x10(%ebp),%edi
  800553:	eb 1d                	jmp    800572 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800555:	85 c0                	test   %eax,%eax
  800557:	75 0f                	jne    800568 <vprintfmt+0x27>
				csa = 0x0700;
  800559:	c7 05 0c 20 80 00 00 	movl   $0x700,0x80200c
  800560:	07 00 00 
				return;
  800563:	e9 c4 03 00 00       	jmp    80092c <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	53                   	push   %ebx
  80056c:	50                   	push   %eax
  80056d:	ff d6                	call   *%esi
  80056f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800572:	83 c7 01             	add    $0x1,%edi
  800575:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800579:	83 f8 25             	cmp    $0x25,%eax
  80057c:	75 d7                	jne    800555 <vprintfmt+0x14>
  80057e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800582:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800589:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800590:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800597:	ba 00 00 00 00       	mov    $0x0,%edx
  80059c:	eb 07                	jmp    8005a5 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8d 47 01             	lea    0x1(%edi),%eax
  8005a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ab:	0f b6 07             	movzbl (%edi),%eax
  8005ae:	0f b6 c8             	movzbl %al,%ecx
  8005b1:	83 e8 23             	sub    $0x23,%eax
  8005b4:	3c 55                	cmp    $0x55,%al
  8005b6:	0f 87 55 03 00 00    	ja     800911 <vprintfmt+0x3d0>
  8005bc:	0f b6 c0             	movzbl %al,%eax
  8005bf:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005cd:	eb d6                	jmp    8005a5 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005dd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005e1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005e4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005e7:	83 fa 09             	cmp    $0x9,%edx
  8005ea:	77 39                	ja     800625 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ef:	eb e9                	jmp    8005da <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800602:	eb 27                	jmp    80062b <vprintfmt+0xea>
  800604:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800607:	85 c0                	test   %eax,%eax
  800609:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060e:	0f 49 c8             	cmovns %eax,%ecx
  800611:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800617:	eb 8c                	jmp    8005a5 <vprintfmt+0x64>
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80061c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800623:	eb 80                	jmp    8005a5 <vprintfmt+0x64>
  800625:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800628:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80062b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80062f:	0f 89 70 ff ff ff    	jns    8005a5 <vprintfmt+0x64>
				width = precision, precision = -1;
  800635:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800638:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80063b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800642:	e9 5e ff ff ff       	jmp    8005a5 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800647:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80064d:	e9 53 ff ff ff       	jmp    8005a5 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	ff 30                	pushl  (%eax)
  800661:	ff d6                	call   *%esi
			break;
  800663:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800669:	e9 04 ff ff ff       	jmp    800572 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8d 50 04             	lea    0x4(%eax),%edx
  800674:	89 55 14             	mov    %edx,0x14(%ebp)
  800677:	8b 00                	mov    (%eax),%eax
  800679:	99                   	cltd   
  80067a:	31 d0                	xor    %edx,%eax
  80067c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067e:	83 f8 08             	cmp    $0x8,%eax
  800681:	7f 0b                	jg     80068e <vprintfmt+0x14d>
  800683:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  80068a:	85 d2                	test   %edx,%edx
  80068c:	75 18                	jne    8006a6 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80068e:	50                   	push   %eax
  80068f:	68 40 10 80 00       	push   $0x801040
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 89 fe ff ff       	call   800524 <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006a1:	e9 cc fe ff ff       	jmp    800572 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8006a6:	52                   	push   %edx
  8006a7:	68 49 10 80 00       	push   $0x801049
  8006ac:	53                   	push   %ebx
  8006ad:	56                   	push   %esi
  8006ae:	e8 71 fe ff ff       	call   800524 <printfmt>
  8006b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b9:	e9 b4 fe ff ff       	jmp    800572 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 50 04             	lea    0x4(%eax),%edx
  8006c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006c9:	85 ff                	test   %edi,%edi
  8006cb:	b8 39 10 80 00       	mov    $0x801039,%eax
  8006d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d7:	0f 8e 94 00 00 00    	jle    800771 <vprintfmt+0x230>
  8006dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006e1:	0f 84 98 00 00 00    	je     80077f <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	ff 75 d0             	pushl  -0x30(%ebp)
  8006ed:	57                   	push   %edi
  8006ee:	e8 c1 02 00 00       	call   8009b4 <strnlen>
  8006f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f6:	29 c1                	sub    %eax,%ecx
  8006f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800702:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800705:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800708:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070a:	eb 0f                	jmp    80071b <vprintfmt+0x1da>
					putch(padc, putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	ff 75 e0             	pushl  -0x20(%ebp)
  800713:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800715:	83 ef 01             	sub    $0x1,%edi
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	85 ff                	test   %edi,%edi
  80071d:	7f ed                	jg     80070c <vprintfmt+0x1cb>
  80071f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800722:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800725:	85 c9                	test   %ecx,%ecx
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	0f 49 c1             	cmovns %ecx,%eax
  80072f:	29 c1                	sub    %eax,%ecx
  800731:	89 75 08             	mov    %esi,0x8(%ebp)
  800734:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800737:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073a:	89 cb                	mov    %ecx,%ebx
  80073c:	eb 4d                	jmp    80078b <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80073e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800742:	74 1b                	je     80075f <vprintfmt+0x21e>
  800744:	0f be c0             	movsbl %al,%eax
  800747:	83 e8 20             	sub    $0x20,%eax
  80074a:	83 f8 5e             	cmp    $0x5e,%eax
  80074d:	76 10                	jbe    80075f <vprintfmt+0x21e>
					putch('?', putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	6a 3f                	push   $0x3f
  800757:	ff 55 08             	call   *0x8(%ebp)
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	eb 0d                	jmp    80076c <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	ff 75 0c             	pushl  0xc(%ebp)
  800765:	52                   	push   %edx
  800766:	ff 55 08             	call   *0x8(%ebp)
  800769:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076c:	83 eb 01             	sub    $0x1,%ebx
  80076f:	eb 1a                	jmp    80078b <vprintfmt+0x24a>
  800771:	89 75 08             	mov    %esi,0x8(%ebp)
  800774:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800777:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077d:	eb 0c                	jmp    80078b <vprintfmt+0x24a>
  80077f:	89 75 08             	mov    %esi,0x8(%ebp)
  800782:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800785:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800788:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80078b:	83 c7 01             	add    $0x1,%edi
  80078e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800792:	0f be d0             	movsbl %al,%edx
  800795:	85 d2                	test   %edx,%edx
  800797:	74 23                	je     8007bc <vprintfmt+0x27b>
  800799:	85 f6                	test   %esi,%esi
  80079b:	78 a1                	js     80073e <vprintfmt+0x1fd>
  80079d:	83 ee 01             	sub    $0x1,%esi
  8007a0:	79 9c                	jns    80073e <vprintfmt+0x1fd>
  8007a2:	89 df                	mov    %ebx,%edi
  8007a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007aa:	eb 18                	jmp    8007c4 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	53                   	push   %ebx
  8007b0:	6a 20                	push   $0x20
  8007b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b4:	83 ef 01             	sub    $0x1,%edi
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	eb 08                	jmp    8007c4 <vprintfmt+0x283>
  8007bc:	89 df                	mov    %ebx,%edi
  8007be:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c4:	85 ff                	test   %edi,%edi
  8007c6:	7f e4                	jg     8007ac <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007cb:	e9 a2 fd ff ff       	jmp    800572 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d0:	83 fa 01             	cmp    $0x1,%edx
  8007d3:	7e 16                	jle    8007eb <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 50 08             	lea    0x8(%eax),%edx
  8007db:	89 55 14             	mov    %edx,0x14(%ebp)
  8007de:	8b 50 04             	mov    0x4(%eax),%edx
  8007e1:	8b 00                	mov    (%eax),%eax
  8007e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e9:	eb 32                	jmp    80081d <vprintfmt+0x2dc>
	else if (lflag)
  8007eb:	85 d2                	test   %edx,%edx
  8007ed:	74 18                	je     800807 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fd:	89 c1                	mov    %eax,%ecx
  8007ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800805:	eb 16                	jmp    80081d <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8d 50 04             	lea    0x4(%eax),%edx
  80080d:	89 55 14             	mov    %edx,0x14(%ebp)
  800810:	8b 00                	mov    (%eax),%eax
  800812:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800815:	89 c1                	mov    %eax,%ecx
  800817:	c1 f9 1f             	sar    $0x1f,%ecx
  80081a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80081d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800820:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800823:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800828:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80082c:	79 74                	jns    8008a2 <vprintfmt+0x361>
				putch('-', putdat);
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	53                   	push   %ebx
  800832:	6a 2d                	push   $0x2d
  800834:	ff d6                	call   *%esi
				num = -(long long) num;
  800836:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800839:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80083c:	f7 d8                	neg    %eax
  80083e:	83 d2 00             	adc    $0x0,%edx
  800841:	f7 da                	neg    %edx
  800843:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800846:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80084b:	eb 55                	jmp    8008a2 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084d:	8d 45 14             	lea    0x14(%ebp),%eax
  800850:	e8 78 fc ff ff       	call   8004cd <getuint>
			base = 10;
  800855:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80085a:	eb 46                	jmp    8008a2 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80085c:	8d 45 14             	lea    0x14(%ebp),%eax
  80085f:	e8 69 fc ff ff       	call   8004cd <getuint>
      base = 8;
  800864:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800869:	eb 37                	jmp    8008a2 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	53                   	push   %ebx
  80086f:	6a 30                	push   $0x30
  800871:	ff d6                	call   *%esi
			putch('x', putdat);
  800873:	83 c4 08             	add    $0x8,%esp
  800876:	53                   	push   %ebx
  800877:	6a 78                	push   $0x78
  800879:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087b:	8b 45 14             	mov    0x14(%ebp),%eax
  80087e:	8d 50 04             	lea    0x4(%eax),%edx
  800881:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800884:	8b 00                	mov    (%eax),%eax
  800886:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800893:	eb 0d                	jmp    8008a2 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800895:	8d 45 14             	lea    0x14(%ebp),%eax
  800898:	e8 30 fc ff ff       	call   8004cd <getuint>
			base = 16;
  80089d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a2:	83 ec 0c             	sub    $0xc,%esp
  8008a5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008a9:	57                   	push   %edi
  8008aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ad:	51                   	push   %ecx
  8008ae:	52                   	push   %edx
  8008af:	50                   	push   %eax
  8008b0:	89 da                	mov    %ebx,%edx
  8008b2:	89 f0                	mov    %esi,%eax
  8008b4:	e8 65 fb ff ff       	call   80041e <printnum>
			break;
  8008b9:	83 c4 20             	add    $0x20,%esp
  8008bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008bf:	e9 ae fc ff ff       	jmp    800572 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	53                   	push   %ebx
  8008c8:	51                   	push   %ecx
  8008c9:	ff d6                	call   *%esi
			break;
  8008cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d1:	e9 9c fc ff ff       	jmp    800572 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d6:	83 fa 01             	cmp    $0x1,%edx
  8008d9:	7e 0d                	jle    8008e8 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008db:	8b 45 14             	mov    0x14(%ebp),%eax
  8008de:	8d 50 08             	lea    0x8(%eax),%edx
  8008e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e4:	8b 00                	mov    (%eax),%eax
  8008e6:	eb 1c                	jmp    800904 <vprintfmt+0x3c3>
	else if (lflag)
  8008e8:	85 d2                	test   %edx,%edx
  8008ea:	74 0d                	je     8008f9 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ef:	8d 50 04             	lea    0x4(%eax),%edx
  8008f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f5:	8b 00                	mov    (%eax),%eax
  8008f7:	eb 0b                	jmp    800904 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fc:	8d 50 04             	lea    0x4(%eax),%edx
  8008ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800902:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800904:	a3 0c 20 80 00       	mov    %eax,0x80200c
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800909:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80090c:	e9 61 fc ff ff       	jmp    800572 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	53                   	push   %ebx
  800915:	6a 25                	push   $0x25
  800917:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	eb 03                	jmp    800921 <vprintfmt+0x3e0>
  80091e:	83 ef 01             	sub    $0x1,%edi
  800921:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800925:	75 f7                	jne    80091e <vprintfmt+0x3dd>
  800927:	e9 46 fc ff ff       	jmp    800572 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80092c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	83 ec 18             	sub    $0x18,%esp
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800940:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800943:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800947:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80094a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800951:	85 c0                	test   %eax,%eax
  800953:	74 26                	je     80097b <vsnprintf+0x47>
  800955:	85 d2                	test   %edx,%edx
  800957:	7e 22                	jle    80097b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800959:	ff 75 14             	pushl  0x14(%ebp)
  80095c:	ff 75 10             	pushl  0x10(%ebp)
  80095f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800962:	50                   	push   %eax
  800963:	68 07 05 80 00       	push   $0x800507
  800968:	e8 d4 fb ff ff       	call   800541 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80096d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800970:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800973:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800976:	83 c4 10             	add    $0x10,%esp
  800979:	eb 05                	jmp    800980 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80097b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800988:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80098b:	50                   	push   %eax
  80098c:	ff 75 10             	pushl  0x10(%ebp)
  80098f:	ff 75 0c             	pushl  0xc(%ebp)
  800992:	ff 75 08             	pushl  0x8(%ebp)
  800995:	e8 9a ff ff ff       	call   800934 <vsnprintf>
	va_end(ap);

	return rc;
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a7:	eb 03                	jmp    8009ac <strlen+0x10>
		n++;
  8009a9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b0:	75 f7                	jne    8009a9 <strlen+0xd>
		n++;
	return n;
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c2:	eb 03                	jmp    8009c7 <strnlen+0x13>
		n++;
  8009c4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c7:	39 c2                	cmp    %eax,%edx
  8009c9:	74 08                	je     8009d3 <strnlen+0x1f>
  8009cb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009cf:	75 f3                	jne    8009c4 <strnlen+0x10>
  8009d1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	53                   	push   %ebx
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	83 c2 01             	add    $0x1,%edx
  8009e4:	83 c1 01             	add    $0x1,%ecx
  8009e7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009eb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ee:	84 db                	test   %bl,%bl
  8009f0:	75 ef                	jne    8009e1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	53                   	push   %ebx
  8009f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009fc:	53                   	push   %ebx
  8009fd:	e8 9a ff ff ff       	call   80099c <strlen>
  800a02:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a05:	ff 75 0c             	pushl  0xc(%ebp)
  800a08:	01 d8                	add    %ebx,%eax
  800a0a:	50                   	push   %eax
  800a0b:	e8 c5 ff ff ff       	call   8009d5 <strcpy>
	return dst;
}
  800a10:	89 d8                	mov    %ebx,%eax
  800a12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a27:	89 f2                	mov    %esi,%edx
  800a29:	eb 0f                	jmp    800a3a <strncpy+0x23>
		*dst++ = *src;
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	0f b6 01             	movzbl (%ecx),%eax
  800a31:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a34:	80 39 01             	cmpb   $0x1,(%ecx)
  800a37:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3a:	39 da                	cmp    %ebx,%edx
  800a3c:	75 ed                	jne    800a2b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a3e:	89 f0                	mov    %esi,%eax
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4f:	8b 55 10             	mov    0x10(%ebp),%edx
  800a52:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a54:	85 d2                	test   %edx,%edx
  800a56:	74 21                	je     800a79 <strlcpy+0x35>
  800a58:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a5c:	89 f2                	mov    %esi,%edx
  800a5e:	eb 09                	jmp    800a69 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a60:	83 c2 01             	add    $0x1,%edx
  800a63:	83 c1 01             	add    $0x1,%ecx
  800a66:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a69:	39 c2                	cmp    %eax,%edx
  800a6b:	74 09                	je     800a76 <strlcpy+0x32>
  800a6d:	0f b6 19             	movzbl (%ecx),%ebx
  800a70:	84 db                	test   %bl,%bl
  800a72:	75 ec                	jne    800a60 <strlcpy+0x1c>
  800a74:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a76:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a79:	29 f0                	sub    %esi,%eax
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a85:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a88:	eb 06                	jmp    800a90 <strcmp+0x11>
		p++, q++;
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a90:	0f b6 01             	movzbl (%ecx),%eax
  800a93:	84 c0                	test   %al,%al
  800a95:	74 04                	je     800a9b <strcmp+0x1c>
  800a97:	3a 02                	cmp    (%edx),%al
  800a99:	74 ef                	je     800a8a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9b:	0f b6 c0             	movzbl %al,%eax
  800a9e:	0f b6 12             	movzbl (%edx),%edx
  800aa1:	29 d0                	sub    %edx,%eax
}
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	53                   	push   %ebx
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaf:	89 c3                	mov    %eax,%ebx
  800ab1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ab4:	eb 06                	jmp    800abc <strncmp+0x17>
		n--, p++, q++;
  800ab6:	83 c0 01             	add    $0x1,%eax
  800ab9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800abc:	39 d8                	cmp    %ebx,%eax
  800abe:	74 15                	je     800ad5 <strncmp+0x30>
  800ac0:	0f b6 08             	movzbl (%eax),%ecx
  800ac3:	84 c9                	test   %cl,%cl
  800ac5:	74 04                	je     800acb <strncmp+0x26>
  800ac7:	3a 0a                	cmp    (%edx),%cl
  800ac9:	74 eb                	je     800ab6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800acb:	0f b6 00             	movzbl (%eax),%eax
  800ace:	0f b6 12             	movzbl (%edx),%edx
  800ad1:	29 d0                	sub    %edx,%eax
  800ad3:	eb 05                	jmp    800ada <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ada:	5b                   	pop    %ebx
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae7:	eb 07                	jmp    800af0 <strchr+0x13>
		if (*s == c)
  800ae9:	38 ca                	cmp    %cl,%dl
  800aeb:	74 0f                	je     800afc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	0f b6 10             	movzbl (%eax),%edx
  800af3:	84 d2                	test   %dl,%dl
  800af5:	75 f2                	jne    800ae9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	8b 45 08             	mov    0x8(%ebp),%eax
  800b04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b08:	eb 03                	jmp    800b0d <strfind+0xf>
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b10:	38 ca                	cmp    %cl,%dl
  800b12:	74 04                	je     800b18 <strfind+0x1a>
  800b14:	84 d2                	test   %dl,%dl
  800b16:	75 f2                	jne    800b0a <strfind+0xc>
			break;
	return (char *) s;
}
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
  800b20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b26:	85 c9                	test   %ecx,%ecx
  800b28:	74 36                	je     800b60 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b30:	75 28                	jne    800b5a <memset+0x40>
  800b32:	f6 c1 03             	test   $0x3,%cl
  800b35:	75 23                	jne    800b5a <memset+0x40>
		c &= 0xFF;
  800b37:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b3b:	89 d3                	mov    %edx,%ebx
  800b3d:	c1 e3 08             	shl    $0x8,%ebx
  800b40:	89 d6                	mov    %edx,%esi
  800b42:	c1 e6 18             	shl    $0x18,%esi
  800b45:	89 d0                	mov    %edx,%eax
  800b47:	c1 e0 10             	shl    $0x10,%eax
  800b4a:	09 f0                	or     %esi,%eax
  800b4c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b4e:	89 d8                	mov    %ebx,%eax
  800b50:	09 d0                	or     %edx,%eax
  800b52:	c1 e9 02             	shr    $0x2,%ecx
  800b55:	fc                   	cld    
  800b56:	f3 ab                	rep stos %eax,%es:(%edi)
  800b58:	eb 06                	jmp    800b60 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5d:	fc                   	cld    
  800b5e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b60:	89 f8                	mov    %edi,%eax
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b72:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b75:	39 c6                	cmp    %eax,%esi
  800b77:	73 35                	jae    800bae <memmove+0x47>
  800b79:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b7c:	39 d0                	cmp    %edx,%eax
  800b7e:	73 2e                	jae    800bae <memmove+0x47>
		s += n;
		d += n;
  800b80:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b83:	89 d6                	mov    %edx,%esi
  800b85:	09 fe                	or     %edi,%esi
  800b87:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8d:	75 13                	jne    800ba2 <memmove+0x3b>
  800b8f:	f6 c1 03             	test   $0x3,%cl
  800b92:	75 0e                	jne    800ba2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b94:	83 ef 04             	sub    $0x4,%edi
  800b97:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b9a:	c1 e9 02             	shr    $0x2,%ecx
  800b9d:	fd                   	std    
  800b9e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba0:	eb 09                	jmp    800bab <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ba2:	83 ef 01             	sub    $0x1,%edi
  800ba5:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba8:	fd                   	std    
  800ba9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bab:	fc                   	cld    
  800bac:	eb 1d                	jmp    800bcb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bae:	89 f2                	mov    %esi,%edx
  800bb0:	09 c2                	or     %eax,%edx
  800bb2:	f6 c2 03             	test   $0x3,%dl
  800bb5:	75 0f                	jne    800bc6 <memmove+0x5f>
  800bb7:	f6 c1 03             	test   $0x3,%cl
  800bba:	75 0a                	jne    800bc6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bbc:	c1 e9 02             	shr    $0x2,%ecx
  800bbf:	89 c7                	mov    %eax,%edi
  800bc1:	fc                   	cld    
  800bc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc4:	eb 05                	jmp    800bcb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc6:	89 c7                	mov    %eax,%edi
  800bc8:	fc                   	cld    
  800bc9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bd2:	ff 75 10             	pushl  0x10(%ebp)
  800bd5:	ff 75 0c             	pushl  0xc(%ebp)
  800bd8:	ff 75 08             	pushl  0x8(%ebp)
  800bdb:	e8 87 ff ff ff       	call   800b67 <memmove>
}
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bed:	89 c6                	mov    %eax,%esi
  800bef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf2:	eb 1a                	jmp    800c0e <memcmp+0x2c>
		if (*s1 != *s2)
  800bf4:	0f b6 08             	movzbl (%eax),%ecx
  800bf7:	0f b6 1a             	movzbl (%edx),%ebx
  800bfa:	38 d9                	cmp    %bl,%cl
  800bfc:	74 0a                	je     800c08 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bfe:	0f b6 c1             	movzbl %cl,%eax
  800c01:	0f b6 db             	movzbl %bl,%ebx
  800c04:	29 d8                	sub    %ebx,%eax
  800c06:	eb 0f                	jmp    800c17 <memcmp+0x35>
		s1++, s2++;
  800c08:	83 c0 01             	add    $0x1,%eax
  800c0b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0e:	39 f0                	cmp    %esi,%eax
  800c10:	75 e2                	jne    800bf4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	53                   	push   %ebx
  800c1f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c22:	89 c1                	mov    %eax,%ecx
  800c24:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c27:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2b:	eb 0a                	jmp    800c37 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2d:	0f b6 10             	movzbl (%eax),%edx
  800c30:	39 da                	cmp    %ebx,%edx
  800c32:	74 07                	je     800c3b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c34:	83 c0 01             	add    $0x1,%eax
  800c37:	39 c8                	cmp    %ecx,%eax
  800c39:	72 f2                	jb     800c2d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c3b:	5b                   	pop    %ebx
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4a:	eb 03                	jmp    800c4f <strtol+0x11>
		s++;
  800c4c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4f:	0f b6 01             	movzbl (%ecx),%eax
  800c52:	3c 20                	cmp    $0x20,%al
  800c54:	74 f6                	je     800c4c <strtol+0xe>
  800c56:	3c 09                	cmp    $0x9,%al
  800c58:	74 f2                	je     800c4c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c5a:	3c 2b                	cmp    $0x2b,%al
  800c5c:	75 0a                	jne    800c68 <strtol+0x2a>
		s++;
  800c5e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c61:	bf 00 00 00 00       	mov    $0x0,%edi
  800c66:	eb 11                	jmp    800c79 <strtol+0x3b>
  800c68:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c6d:	3c 2d                	cmp    $0x2d,%al
  800c6f:	75 08                	jne    800c79 <strtol+0x3b>
		s++, neg = 1;
  800c71:	83 c1 01             	add    $0x1,%ecx
  800c74:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c79:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c7f:	75 15                	jne    800c96 <strtol+0x58>
  800c81:	80 39 30             	cmpb   $0x30,(%ecx)
  800c84:	75 10                	jne    800c96 <strtol+0x58>
  800c86:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c8a:	75 7c                	jne    800d08 <strtol+0xca>
		s += 2, base = 16;
  800c8c:	83 c1 02             	add    $0x2,%ecx
  800c8f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c94:	eb 16                	jmp    800cac <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c96:	85 db                	test   %ebx,%ebx
  800c98:	75 12                	jne    800cac <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c9a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9f:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca2:	75 08                	jne    800cac <strtol+0x6e>
		s++, base = 8;
  800ca4:	83 c1 01             	add    $0x1,%ecx
  800ca7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cac:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb4:	0f b6 11             	movzbl (%ecx),%edx
  800cb7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cba:	89 f3                	mov    %esi,%ebx
  800cbc:	80 fb 09             	cmp    $0x9,%bl
  800cbf:	77 08                	ja     800cc9 <strtol+0x8b>
			dig = *s - '0';
  800cc1:	0f be d2             	movsbl %dl,%edx
  800cc4:	83 ea 30             	sub    $0x30,%edx
  800cc7:	eb 22                	jmp    800ceb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ccc:	89 f3                	mov    %esi,%ebx
  800cce:	80 fb 19             	cmp    $0x19,%bl
  800cd1:	77 08                	ja     800cdb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cd3:	0f be d2             	movsbl %dl,%edx
  800cd6:	83 ea 57             	sub    $0x57,%edx
  800cd9:	eb 10                	jmp    800ceb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cdb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cde:	89 f3                	mov    %esi,%ebx
  800ce0:	80 fb 19             	cmp    $0x19,%bl
  800ce3:	77 16                	ja     800cfb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ce5:	0f be d2             	movsbl %dl,%edx
  800ce8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ceb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cee:	7d 0b                	jge    800cfb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cf0:	83 c1 01             	add    $0x1,%ecx
  800cf3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf9:	eb b9                	jmp    800cb4 <strtol+0x76>

	if (endptr)
  800cfb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cff:	74 0d                	je     800d0e <strtol+0xd0>
		*endptr = (char *) s;
  800d01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d04:	89 0e                	mov    %ecx,(%esi)
  800d06:	eb 06                	jmp    800d0e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d08:	85 db                	test   %ebx,%ebx
  800d0a:	74 98                	je     800ca4 <strtol+0x66>
  800d0c:	eb 9e                	jmp    800cac <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d0e:	89 c2                	mov    %eax,%edx
  800d10:	f7 da                	neg    %edx
  800d12:	85 ff                	test   %edi,%edi
  800d14:	0f 45 c2             	cmovne %edx,%eax
}
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
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
