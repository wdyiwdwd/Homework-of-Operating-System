# 操作系统课程第三次作业 MiniShell
+ 一个MiniShell,支持单个通道。
+ 编译方式如下：
  +   进入cmake-build-debug文件夹，输入make命令，会重新生成可执行程序。
  +   或者直接通过gcc编译main.c文件，生成可执行程序
  + 使用方式如下：
  + 运行可执行程序即可。

+ 运行结果事例如下

  + ls -l
  - -rw-r--r-- 1 gongyansong gongyansong 34329 11月 15 14:39 CMakeCache.txt
  - drwxr-xr-x 5 gongyansong gongyansong  4096 11月 17 19:33 CMakeFiles
  - -rw-r--r-- 1 gongyansong gongyansong  1416 11月 15 14:39 cmake_install.cmake
  - drwxr-xr-x 2 gongyansong gongyansong  4096 11月 17 16:41 H=????s1?H????n??
  - -rw-r--r-- 1 gongyansong gongyansong  5117 11月 15 14:39 Makefile
  - -rwxr-xr-x 1 gongyansong gongyansong 17480 11月 17 19:33 MiniShell
  - -rw-r--r-- 1 gongyansong gongyansong  5798 11月 15 14:39 MiniShell.cbp
  - drwxr-xr-x 2 gongyansong gongyansong  4096 11月 17 16:39 mkdir

  + ls -l |grep Mini
  - -rwxr-xr-x 1 gongyansong gongyansong 17480 11月 17 19:33 MiniShell
  - -rw-r--r-- 1 gongyansong gongyansong  5798 11月 15 14:39 MiniShell.cbp


+ 另附.pdf的实验报告
