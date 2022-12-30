/*
     __        __   __   ___ ___ ___  __  
    |__)  /\  |__) |__) |__   |   |  /  \ 
    |    /~~\ |  \ |  \ |___  |   |  \__/ 

    RISC-V testbench
    Written by Marco Groeneveld
    (c) 2022 by Parretto B.V.

    History
    =======
    v1.0 - Initial release
*/

`timescale 1ns / 1ps
`default_nettype none

module prt_riscv_tst ();

// Parameters
localparam P_VENDOR = "xilinx";     
localparam P_ROM_INIT = "../tst/tst_rom.mem";
localparam P_RAM_INIT = "../tst/tst_ram.mem";

// Signals
logic rst;
logic clk;
logic irq;

// Clock 100 MHz
initial
begin
    clk <= 0;
    forever
        #5ns clk <= ~clk;
end

// Reset
initial
begin
    rst <= 1;
    #500ns
    rst <= 0;
end

// Interrupt
initial
begin
    irq <= 0;
    #1.435us
    irq <= 1;
    #100ns
    irq <= 0;
end

// DUT
     prt_riscv_top
     #(
         .P_VENDOR       (P_VENDOR),
         .P_ROM_INIT     (P_ROM_INIT),
         .P_RAM_INIT     (P_RAM_INIT)
     )
     DUT_INST
     (
          // Reset and clock
         .RST_IN    (rst),
         .CLK_IN    (clk),
         .IRQ_IN    (irq)
     );

endmodule
