OSS := $(HOME)/.apio/packages/tools-oss-cad-suite/bin
YOSYS   ?= $(OSS)/yosys
NEXTPNR ?= $(OSS)/nextpnr-ice40
ICEPACK ?= $(OSS)/icepack
ICEPROG ?= $(OSS)/iceprog

TOP     := tetris
SRC     := tetris.v st7735.v debounce.v video_timing.v board_render.v vga.v hdmi.v pll.v game.v board_ram.v hud.v sound.v
PIN_DEF := okice40pro.pcf

all: $(TOP).bin

$(TOP).json: $(SRC)
	$(YOSYS) -p 'synth_ice40 -top $(TOP) -json $@' $(SRC)

$(TOP).asc: $(TOP).json $(PIN_DEF)
	$(NEXTPNR) --up5k --package sg48 --json $< --pcf $(PIN_DEF) --asc $@ --timing-allow-fail

$(TOP).bin: $(TOP).asc
	$(ICEPACK) $< $@

prog: $(TOP).bin
	$(ICEPROG) $<

clean:
	rm -f *.json *.asc *.bin

.PHONY: all prog clean
