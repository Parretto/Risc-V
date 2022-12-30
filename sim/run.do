###
# ModelSim simulation script
#
# Written by Marco Groeneveld
###


# Modules

# Application
set top			2
set cpu			2
set cpu_reg		2
set rom			1
set ram			2

# Colors
set color_signal "Gold"
set color_internal "White"
set color_wave "Turquoise"

# Tools
set vivado "/home/marco/tools/Xilinx/Vivado/2022.1"

# Functions

proc add2wave {name path level} {
	if {$level > 0} {
		add wave -divider $name
		add wave -noupdate -color "Turquoise" -itemcolor "Gold" -ports $path

		if {$level > 1} {
			add wave -divider __INTERNALS__
			add wave -noupdate -color "Turquoise" -itemcolor "White" -internals $path
		}
	}
}


# Libraries
global env;

if [file exists work] {
	vdel -all
}
vlib work

# Xilinx
vlog -quiet $vivado/data/verilog/src/glbl.v
#vlog -quiet $vivado/data/verilog/src/unisims/IBUFDS.v
#vlog -quiet $vivado/data/verilog/src/unisims/BUFGCE.v
vlog -quiet $vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv

# Risc-V
vlog -quiet ../src/prt_riscv_lib.sv
vlog -quiet ../src/prt_riscv_cpu_reg.sv
vlog -quiet ../src/prt_riscv_cpu.sv
vlog -quiet ../src/prt_riscv_rom.sv
vlog -quiet ../src/prt_riscv_ram.sv
vlog -quiet ../src/prt_riscv_top.sv

# Testbench
vlog -quiet prt_riscv_tst.sv 

vsim -voptargs=+acc -t ps prt_riscv_tst glbl
view wave
set wavecolor "Gold"

# simulation

###
# Top
###
if {$top > 0} {
	set path "sim:/DUT_INST/"

	set object [concat $path "*"]
	add2wave "__TOP__" $object 1

	if {$top > 1} {
		add wave -divider __INTERNALS__
		set object [concat $path "*"]
		add wave -noupdate -color $color_wave -itemcolor $color_internal -internals $object
	}
}

###
# CPU
###
if {$cpu > 0} {
	set path "sim:/DUT_INST/CPU_INST"

	set object [concat $path "*"]
	add2wave "__CPU_INST__" $object 1

	if {$cpu > 1} {
		add wave -divider __INTERNALS__
		set object [concat $path "*"]
		add wave -noupdate -color $color_wave -itemcolor $color_internal -internals $object
	}

	if {$cpu_reg > 1} {
		add wave -divider __INTERNALS__
		set object [concat $path "/REG_INST/*"]
		add wave -noupdate -color $color_wave -itemcolor $color_internal -internals $object
		add wave -position insertpoint sim:/prt_riscv_tst/DUT_INST/CPU_INST/REG_INST/clk_reg
	}
}

###
# ROM
###
if {$rom > 0} {
	set path "sim:/DUT_INST/ROM_INST"

	set object [concat $path "*"]
	add2wave "__ROM_INST__" $object 1

	set object [concat $path "ROM_IF/*"]
	add wave -divider __ROM_IF__
	add wave -noupdate -itemcolor $color_signal $object

	if {$rom > 1} {
		add wave -divider __INTERNALS__
		set object [concat $path "*"]
		add wave -noupdate -color $color_wave -itemcolor $color_internal -internals $object
	}
}

###
# RAM
###
if {$ram > 0} {
	set path "sim:/DUT_INST/RAM_INST"

	set object [concat $path "*"]
	add2wave "__RAM_INST__" $object 1

	set object [concat $path "RAM_IF/*"]
	add wave -divider __RAM_IF__
	add wave -noupdate -itemcolor $color_signal $object

	if {$ram > 1} {
		add wave -divider __INTERNALS__
		set object [concat $path "*"]
		add wave -noupdate -color $color_wave -itemcolor $color_internal -internals $object
	}
}

configure wave -signalnamewidth 1
configure wave -timelineunits us
configure wave -namecolwidth 250
configure wave -valuecolwidth 200
configure wave -waveselectenable 1
configure wave -vectorcolor "Yellow"
set DefaultRadix hexadecimal
update
