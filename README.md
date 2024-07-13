# RTL_Test_Script

## Introduction

本仓库旨在个人在Linux端快速进行Verilog RTL功能验证，仓库内包含使用教程以及MAKEFILE脚本文件。

## Requirements

需要安装的软件有:
* 开源verilog编译器: iverilog
* 开源逻辑信号查看器: gtkwave
* 自动化编译工具: make

## Tutorial

1. 修改testbench

首先在verilog的testbench中加入用于记录信号值变化的代码:
```verilog
initial begin
    $dumpfile("name.lxt");
    $dumpvars(0, tb);
end
```
* 这里的name指代具体testbench的名字，例如adder_tb.v对应adder.lxt，需要**自行替换**。
* 实际这里生成的vcd文件，但由于后续我们要通过vvp转化为lxt文件，因此文件后缀提前改为lxt。

dumpvars使用举例：
```verilog
$dumpvars; // Dump所有层次的信号
$dumpvars(0, top); // Dump top及其以下所有信号
$dumpvars(1, top); // Dump top模块中的所有信号
$dumpvars(2, top.u1); // Dump实例top.u1及其下一层的信号
$dumpvars(3, top.u2, top.u1); // Dump top.u1和top.u2及其下两层中的所有信号
```

2. 调整项目框架

按下面的框架调整项目文件，并将本仓库内的Makefile文件加入项目目录内:

```
|-- Project
    |-- module
        |-- module1.v
        |-- module_dir1
            |-- module2.v
        |-- module_dir2
            |-- module_dir3
                |-- module3.v
    |-- include
        |-- include1.v
        |-- include2.vh
        |-- include_dir1
            |-- include3.v
        |-- include_dir2
            |-- include_dir3
                |-- include4.v
    |-- testbench
        |-- test1_tb.v
        |-- test_dir1
            |-- test2_tb.v
        |-- test_dir2
            |-- test_dir3
                |-- test3_tb.v
    |-- module4.v (not recommend but support)
    |-- test4_tb.v (not recommend but support)
    |-- other_dir
        |-- module5.v (not recommend but support)
        |-- test5_tb.v (not recommend but support)
    |-- Makefile
```

3. 开始验证

在项目目录下执行``make``命令，即可执行Makefile脚本自动完成编译、格式转化以及波形显示三个流程。该Makefile可以对满足依赖条件的所有testbench进行验证。

4. 清除中间文件

在项目目录下执行``make clean``命令。
