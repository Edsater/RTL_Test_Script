# 定义变量

MODULE_DIR = module # 定义模块目录名为module，位于当前目录下
INCLUDE_DIR = include # 定义头文件目录名为module，位于当前目录下
MODULE_FILES = $(wildcard $(MODULE_DIR)/*.v) # 提取模块目录内所有模块文件
INCLUDE_FILES = $(wildcard $(INCLUDE_DIR)/*.v) $(wildcard $(INCLUDE_DIR)/*.vh) # 提取头文件目录内所有头文件
VVP_TARGETS = $(patsubst %_tb.v,%.vvp,$(wildcard *_tb.v)) # 将同名tb文件转化为vvp文件
LXT_TARGETS = $(patsubst %_tb.v,%.lxt,$(wildcard *_tb.v)) # 将同名tb文件转化为lxt文件
RUN_TARGETS = $(patsubst %_tb.v,%.run,$(wildcard *_tb.v)) # 将同名tb文件转化为run文件（虚拟目标）

.SECONDARY: # 告诉make不要删除之后的中间文件

.PHONY: all clean # 定义伪目标

# 定义整体执行目标，即为处理当前目录下所有仿真
all: $(RUN_TARGETS)

# 编译：将*_tb.v 编译为*.vvp可执行文件
%.vvp: %_tb.v $(MODULE_FILES) $(INCLUDE_FILES)
	iverilog -g2012 -o $@ -y $(MODULE_DIR) -I $(INCLUDE_DIR) $<

# 生成波形：运行*.vvp可执行文件，生成*.lxt波形文件
%.lxt: %.vvp
	vvp -n $< -lxt

# 观察波形：使用gtkwave处理*.lxt波形文件，便于直观观察
%.run: %.lxt
	nohup gtkwave $< &

# 清理中间文件
clean:
	rm -f *.vvp *.lxt nohup.out
