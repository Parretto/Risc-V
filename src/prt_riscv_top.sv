/*
     __        __   __   ___ ___ ___  __  
    |__)  /\  |__) |__) |__   |   |  /  \ 
    |    /~~\ |  \ |  \ |___  |   |  \__/ 


    Module: RISC-V Top
    (c) 2022 by Parretto B.V.

    History
    =======
    v1.0 - Initial release

    License
    =======
    This License will apply to the use of the IP-core (as defined in the License). 
    Please read the License carefully so that you know what your rights and obligations are when using the IP-core.
    The acceptance of this License constitutes a valid and binding agreement between Parretto and you for the use of the IP-core. 
    If you download and/or make any use of the IP-core you agree to be bound by this License. 
    The License is available for download and print at www.parretto.com/license.html
    Parretto grants you, as the Licensee, a free, non-exclusive, non-transferable, limited right to use the IP-core 
    solely for internal business purposes for the term and conditions of the License. 
    You are also allowed to create Modifications for internal business purposes, but explicitly only under the conditions of art. 3.2.
    You are, however, obliged to pay the License Fees to Parretto for the use of the IP-core, or any Modification, in, or embodied in, 
    a physical or non-tangible product or service that has substantial commercial, industrial or non-consumer uses. 
*/

`default_nettype none

module prt_riscv_top
#(
    parameter P_VENDOR          = "none",
    parameter P_ROM_INIT        = "none",
    parameter P_RAM_INIT        = "none"
)
(
     // Reset and clock
    input wire      RST_IN,
    input wire      CLK_IN,
    input wire      IRQ_IN
);

// Parameters

localparam P_ROM_SIZE = 64 * 1024;                     // ROM size in bytes
localparam P_ROM_ADR = $clog2(P_ROM_SIZE);
localparam P_RAM_SIZE = 64 * 1024;                      // RAM size in bytes
localparam P_RAM_ADR = $clog2(P_RAM_SIZE);

// Interfaces
prt_riscv_rom_if 
#(
     .P_ADR_WIDTH (P_ROM_ADR)
) rom_if();

prt_riscv_ram_if 
#(
     .P_ADR_WIDTH (32)
) ram_if_cpu();

prt_riscv_ram_if 
#(
     .P_ADR_WIDTH (P_RAM_ADR)
) ram_if_ram();

// Signals

// CPU
wire            irq_to_cpu;

// Logic

// CPU
    prt_riscv_cpu
    CPU_INST
    (
        // Clocks and reset
        .RST_IN                 (RST_IN),         // Reset
        .CLK_IN                 (CLK_IN),         // Clock

        // ROM interface
        .ROM_IF                 (rom_if),

        // RAM interface
        .RAM_IF                 (ram_if_cpu),

        // Interrupt
        .IRQ_IN                 (IRQ_IN),
        
        // Status
        .STA_ERR_OUT            ()         // Error
    );

    // RAM mapping
    assign ram_if_ram.adr       = ram_if_cpu.adr[0+:P_RAM_ADR];
    assign ram_if_ram.wr        = (ram_if_cpu.adr[31]) ? 0 : ram_if_cpu.wr;
    assign ram_if_ram.rd        = (ram_if_cpu.adr[31]) ? 0 : ram_if_cpu.rd;
    assign ram_if_ram.wr_dat    = ram_if_cpu.wr_dat;
    assign ram_if_ram.wr_strb   = ram_if_cpu.wr_strb;
    assign ram_if_cpu.rd_vld    = ram_if_ram.rd_vld;
    assign ram_if_cpu.rd_dat    = ram_if_ram.rd_dat;

// ROM
    prt_riscv_rom
    #(
        .P_VENDOR       (P_VENDOR),    // Vendor "xilinx" or "lattice"
        .P_ADR          (P_ROM_ADR),   // Address bits
        .P_INIT_FILE    (P_ROM_INIT)   // Initilization file
    )
    ROM_INST
    (
        // Reset and clock
        .RST_IN         (RST_IN),      // Reset
        .CLK_IN         (CLK_IN),      // Clock

        // ROM interface
        .ROM_IF         (rom_if),

        // Initialization
        .INIT_STR_IN    (1'b0),     // Start
        .INIT_DAT_IN    (32'h0),    // Data
        .INIT_VLD_IN    (1'b0)      // Valid
    );

// RAM
    prt_riscv_ram
    #(
        .P_VENDOR       (P_VENDOR),     // Vendor "xilinx" or "lattice"
        .P_ADR          (P_RAM_ADR),    // Address bits
        .P_INIT_FILE    (P_RAM_INIT)    // Initilization file
    )
    RAM_INST
    (
        // Reset and clock
        .RST_IN         (RST_IN),      // Reset
        .CLK_IN         (CLK_IN),   // Clock

        // RAM interface
        .RAM_IF         (ram_if_ram),

        // Initialization
        .INIT_STR_IN    (1'b0),     // Start
        .INIT_DAT_IN    (32'h0),    // Data
        .INIT_VLD_IN    (1'b0)      // Valid
    );

endmodule

`default_nettype wire
