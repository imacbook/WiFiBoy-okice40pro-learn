OSS := $(HOME)/.apio/packages/tools-oss-cad-suite/bin
YOSYS   ?= $(OSS)/yosys
NEXTPNR ?= $(OSS)/nextpnr-ice40
ICEPACK ?= $(OSS)/icepack
ICEPROG ?= $(OSS)/iceprog

TOP     := ws_two
SRC     := $(TOP).v
PIN_DEF := okice40pro.pcf

all: $(TOP).bin
$(TOP).json: $(SRC)
	$(YOSYS) -p 'synth_ice40 -top $(TOP) -json $@' $(SRC)
$(TOP).asc: $(TOP).json $(PIN_DEF)
	$(NEXTPNR) --up5k --package sg48 --json $< --pcf $(PIN_DEF) --asc $@
$(TOP).bin: $(TOP).asc
	$(ICEPACK) $< $@
prog: $(TOP).bin
	$(ICEPROG) $<
clean:
	rm -f *.json *.asc *.bin
.PHONY: all prog clean
