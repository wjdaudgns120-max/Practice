#vcs Makefile

RTL_DIR		= ./rtl
TB_DIR		= ./tb
BUILD_DIR	= ./build
INC_DIR		= +incdir+$(RTL_DIR)
SIMV_DIR	= ./build/simv
VCS_OPT     = -full64 -sverilog -debug_access+all -kdb -lca \
              -timescale=1ns/1ps +define+FSDB \
              $(INC_DIR) \
              -o $(SIMV_DIR)

SRCS		= $(RTL_DIR)/uart.v \
              $(RTL_DIR)/uart_v1_0_S00_AXI.v \
              $(RTL_DIR)/uart_v1_0.v \
              $(TB_DIR)/tb_AXI_UART.sv

all: run simv

run:
	mkdir -p	$(BUILD_DIR)
	vcs			$(VCS_OPT) $(SRCS)

simv:
	$(SIMV_DIR)

verdi:
	verdi -dbdir $(BUILD_DIR)/simv.daidir -ssf wave.fsdb &

clean:
	rm -rf $(BUILD_DIR) csrc novas* ucli.key verdiLog *.fsdb .inter.fsdb* sys*

.PHONY:	all run simv verdi clean
