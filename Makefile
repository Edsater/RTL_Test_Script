# 定义变量

MODULE_DIR = ./module # 定义模块目录名为module，位于当前目录下
INCLUDE_DIR = ./include # 定义头文件目录名为module，位于当前目录下
TESTBENCH_DIR = ./testbench # 定义Testbench目录名为testbench，位于当前目录下

SEL_DIR_MODULE_FILES = $(shell find $(MODULE_DIR) -type f \( -name "*.v" \)) # 提取模块目录内所有verilog文件
CUR_DIR_MODULE_FILES = $(shell find . -type f \( -name "*.v" \)) # 提取当前目录内所有verilog文件
MODULE_V = $(sort $(SEL_DIR_MODULE_FILES) $(CUR_DIR_MODULE_FILES)) # 合并所有verilog文件并用sort去重
MODULE_FILES = $(filter-out %_tb.v, $(MODULE_V)) # 从verilog文件中过滤掉testbench文件，得到模块文件

INCLUDE_FILES = $(shell find $(INCLUDE_DIR) -type f \( -name "*.v" -o -name "*.vh" \)) # 提取头文件目录内所有头文件

SEL_DIR_TESTBENCH_FILES = $(shell find $(TESTBENCH_DIR) -type f \( -name "*_tb.v" \)) # 提取Testbench目录内所有Testbench文件
CUR_DIR_TESTBENCH_FILES = $(shell find . -type f \( -name "*_tb.v" \)) # 提取当前目录内所有testbench文件
TESTBENCH_FILES = $(sort $(SEL_DIR_TESTBENCH_FILES) $(CUR_DIR_TESTBENCH_FILES)) # 合并所有Testbench文件并用sort去重

VVP_TARGETS = $(patsubst %_tb.v,%.vvp,$(TESTBENCH_FILES)) # 将同名tb文件转化为vvp文件
LXT_TARGETS = $(patsubst %_tb.v,%.lxt,$(TESTBENCH_FILES)) # 将同名tb文件转化为lxt文件
RUN_TARGETS = $(patsubst %_tb.v,%.run,$(TESTBENCH_FILES)) # 将同名tb文件转化为run文件（虚拟目标）

# 打印处理的文件列表

$(info -------------------)
$(info | Print File List |)
$(info -------------------)

$(info Module files: $(MODULE_FILES))
$(info Include files: $(INCLUDE_FILES))
$(info Testbench files: $(TESTBENCH_FILES))
$(info VVP targets: $(VVP_TARGETS))
$(info LXT targets: $(LXT_TARGETS))

$(info  )

.SECONDARY: # 告诉make不要删除之后的中间文件

.PHONY: all clean # 定义伪目标

# 定义整体执行目标，即为处理当前目录下所有仿真

all: $(RUN_TARGETS)

# 编译：将*_tb.v 编译为*.vvp可执行文件

%.vvp: %_tb.v $(MODULE_FILES) $(INCLUDE_FILES)
	@echo "----------------------"
	@echo "| IVERILOG Compiling |"
	@echo "----------------------"
	iverilog -g2012 -o $@ -y $(MODULE_DIR) -I $(INCLUDE_DIR) $<
	@echo " "

# 生成波形：运行*.vvp可执行文件，生成*.lxt波形文件

%.lxt: %.vvp
	@echo "---------------"
	@echo "| VVP Running |"
	@echo "---------------"
	vvp -n $< -lxt
	@echo " "

# 观察波形：使用gtkwave处理*.lxt波形文件，便于直观观察

%.run: %.lxt
	@echo "-------------------"
	@echo "| Wave Generating |"
	@echo "-------------------"
	nohup gtkwave $< &
	@echo " "

# 清理中间文件

clean:
	@echo "-----------------"
	@echo "| File Cleaning |"
	@echo "-----------------"
	find . -type f \( -name "*.vvp" -o -name "*.lxt" \) -delete
	rm -f nohup.out
	@echo " "
