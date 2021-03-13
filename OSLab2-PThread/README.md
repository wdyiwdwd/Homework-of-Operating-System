# 操作系统课程第二次作业 PThread的使用
+ 这是生产者消费者的示例程序。
+ 编译方式如下：
  + 进入cmake-build-debug文件夹，输入make命令，会重新生成可执行程序。
  + 或者直接通过gcc编译main.c文件，生成可执行程序
+ 使用方式如下：
  + 运行可执行程序即可。


+ 初始状态下有两个货物，并且生产者消费者随机睡眠，且平均消费者消费的多于生产者生产的。
+ 运行结果事例如下
  + I am customer and the goods left 1
  + customer unlock
  + producer lock
  + I am producer and the goods left 2
  + producer unlock
  + producer lock
  + I am producer and the goods left 3
  + producer unlock

+ 另附.pdf的实验报告
