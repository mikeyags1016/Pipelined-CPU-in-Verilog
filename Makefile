IVERILOG ?= iverilog
VVP ?= vvp

RTL := rtl/IFU.sv
TB := tb/IFU_tb.sv
SIM := IFU_tb.vvp
WAVEFORM := IFU_tb.vcd

.PHONY: all compile run wave clean

all: run

compile: $(SIM)

$(SIM): $(RTL) $(TB)
	$(IVERILOG) -g2012 -s IFU_tb -o $@ $(RTL) $(TB)

run: $(SIM)
	$(VVP) $(SIM)

wave: run
	@echo Waveform written to $(WAVEFORM)

clean:
	rm -f $(SIM) $(WAVEFORM)

# Legacy Xilinx project structure. Kept for reference; this project currently
# uses Icarus Verilog and does not require the Xilinx build system.
# default: bitfiles
#
# project := exampleproj
# top_module := main
# vendor := xilinx
#
# include ./contrib/xula2/settings.mk
# extra_includes += ./contrib/xula2/targets.mk
#
# board := exampleboard
# family := spartan6
# device := XC6SLX25
# speedgrade := -2
# device_package := ftg256
#
# part := $(device)$(speedgrade)-$(device_package)
# hostbits := 64
# iseenv := /opt/Xilinx/14.3/ISE_DS/
#
# verilog_files += rtl/$(top_module)_$(board).sv
# vhdl_files +=
# extra_prj +=
# tbfiles += tb/*.sv
# alltests := test/rot13_tb
# vgenerics +=
# xilinx_cores +=
# bmm_file := contrib/empty.bmm
#
# include $(extra_includes)
# include ./contrib/xilinx.mk
