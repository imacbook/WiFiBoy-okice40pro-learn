OSS := $(HOME)/.apio/packages/tools-oss-cad-suite/bin
IVERILOG ?= $(OSS)/iverilog
VVP      ?= $(OSS)/vvp

sim:
	$(IVERILOG) -o tb.vvp tb_decoder.v decoder.v
	$(VVP) tb.vvp

clean:
	rm -f *.vvp *.vcd

.PHONY: sim clean
