# APP_ABI := armeabi-v7a x86
armeabi-v7a 在手机上运行    
x86	在夜神模拟器上运行     

# so无法进入JNI_OnLoad
编译elf需要添加pie，编译so不需要    
```
LOCAL_CFLAGS += -fPIE     
LOCAL_LDFLAGS += -fPIE -pie    
```

# 两种调用方式     
在夜神模拟上面通过so方式ptrace(PTRACE_ATTACH会失败，没找到原因     
在夜神模拟上面通过eof方式ptrace(PTRACE_ATTACH成功     

# Android Studio 利用CMake生成的是ninja
ninja是一个小型的关注速度的构建系统，不需要关心ninja的脚本，知道怎么配置CMake就可以了      

# 安卓通过socket给elf发送命令，修改内存
/data/local/tmp目录下面的elf可以运行（chmod 777），程序入口函数是main    
安卓上层调用so里面的本地方法     
socket都是用c++实现     

# strtoll打印时导致的crash
```c++
char* io_buffer = "W A8F79F30 1222";
int data;
char *ptr;
char *ptr1;

char* cursor = io_buffer;
cursor += 1;
void * addr = (void *)strtoll(cursor, &ptr, 16);
printf("%0x", addr);//打印 A8F79F30
//printf("%s", addr);会崩溃
int value = strtol(ptr, &ptr, 10);
```

# Android studio ndk samples
https://github.com/android/ndk-samples     
ndk-samples\other-builds\ndkbuild\two-libs      
这个例子是ndk还是使用android.mk来编译，但是c++代码是无法调试的，也看不了c++代码      
Android Studio只能写CMakeList.txt，才能调试c++代码？？？     
```
    externalNativeBuild {
        ndkBuild {
            path 'src/main/cpp/Android.mk'
        }
    }
```
使用夜神模拟器只能跑程序，无法调试程序???     



# ndk里面函数如果最后无返回值，Android Studio调试此函数时会崩溃
```
static jint init_native(JNIEnv *env, jobject thiz)
{
	... ...
	//return 0;
}
```

# Android Studio调试c++代码
真机可以进入java和c++断点					
安卓自带的模拟器可以进入java和c++断点					
夜神模拟器可以进入java断点，无法进入c++断点，没有找到原因				
(夜神模拟器应该需要使用x86的so，使用了还是无法进入c++断点)			
```
       ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
        }
```		

# getuid()
```
	使用elf，/data/local/tmp目下调用ptrace：
     root的手机  uid = 2000，用adb shell ps -ef查看，uid是shell
     夜神模拟    uid = 0
	 uid为0时ptrace(PTRACE_DETACH,才会成功
	 
	在Virtual Xposed中使用so调用ptrace，是可以成功的，但是无法看到日志。
```

# linux内存
text、rodata、data、bss、stack、heap     
https://www.cnblogs.com/DataArt/p/9879192.html     

.text (r-x), .rodata (r--), .data (rw-) and .bss (rw-)     

/proc/${pid}/maps，这个文件有内存所有的详细信息     
查找的内存段：     
heap, stack, .data, .bss     

```
 /*
             * get the load address for regions of the same ELF file
             *
             * When the ELF loader loads an executable or a library into
             * memory, there is one region per ELF segment created:
             * .text (r-x), .rodata (r--), .data (rw-) and .bss (rw-). The
             * 'x' permission of .text is used to detect the load address
             * (region start) and the end of the ELF file in memory. All
             * these regions have the same filename. The only exception
             * is the .bss region. Its filename is empty and it is
             * consecutive with the .data region. But the regions .bss and
             * .rodata may not be present with some ELF files. This is why
             * we can't rely on other regions to be consecutive in memory.
             * There should never be more than these four regions.
             * The data regions use their variables relative to the load
             * address. So determining it makes sense as we can get the
             * variable address used within the ELF file with it.
             * But for the executable there is the special case that there
             * is a gap between .text and .rodata. Other regions might be
             * loaded via mmap() to it. So we have to count the number of
             * regions belonging to the exe separately to handle that.
             * References:
             * http://en.wikipedia.org/wiki/Executable_and_Linkable_Format
             * http://wiki.osdev.org/ELF
             * http://lwn.net/Articles/531148/
             */
```

# 连接符
```
##表示连接符
#define DEFINE_INTEGER_MATCHANY_ROUTINE(DATATYPENAME, DATAWIDTH) \
    int scan_routine_##DATATYPENAME##_ANY ()//DATATYPENAME的后面跟的是字符串,所以需要加##
	{
	}

DEFINE_INTEGER_MATCHANY_ROUTINE(INTEGER8, 8)
展开之后就是：
    int scan_routine_INTEGER8_ANY ()
	{
	}

注意下面的区别

#define REGISTER_NATIVE(env, module) { \
	extern int register_##module(JNIEnv *); \
	if (register_##module(env) < 0) \
		return JNI_FALSE; \
}

module后面不是跟的字符串，所以不需要加##

REGISTER_NATIVE(env, Emulator);会替换成
//##表示连接符
{
	extern int register_Emulator(JNIEnv *);//register_Emulator(JNIEnv *)在emulator.cpp中
	if (register_Emulator(env) < 0)
		return JNI_FALSE;
}
```

# (stringType " ")

```
#define FLAG_MACRO_NEW(stringType) true ? (stringType " ") : ""
printf("%s\n", FLAG_MACRO_NEW("I32"));

打印：I32 (注意有一个空格)

#define FLAG_MACRO_NEW(stringType) true ? (stringType " aditext") : ""
printf("%s\n", FLAG_MACRO_NEW("I32"));

打印：I32 aditext

```

