`include "sm_config.vh"

//hardware top level module
module sm_top
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] clkDevide,
    input           clkEnable,
    output          clk,
    input   [ 4:0 ] regAddr,
    output  [31:0 ] regData,

    input      [`SM_GPIO_WIDTH - 1:0] gpioInput, // GPIO output pins
    output     [`SM_GPIO_WIDTH - 1:0] gpioOutput, // GPIO intput pins
    output                            pwmOutput,  // PWM output pin
    output                            alsCS,      // Ligth Sensor chip select
    output                            alsSCK,     // Light Sensor SPI clock
    input                             alsSDO      // Light Sensor SPI data
);
    //metastability input filters
    wire    [ 3:0 ] devide;
    wire            enable;
    wire    [ 4:0 ] addr;

    sm_debouncer #(.SIZE(4)) f0(clkIn, clkDevide, devide);
    sm_debouncer #(.SIZE(1)) f1(clkIn, clkEnable, enable);
    sm_debouncer #(.SIZE(5)) f2(clkIn, regAddr,   addr  );

    //cores
    //clock devider
    sm_clk_divider sm_clk_divider
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .devide     ( devide    ),
        .enable     ( enable    ),
        .clkOut     ( clk       )
    );

    //instruction memory
    wire    [31:0]  imAddr1;
    wire    [31:0]  imData1;
	wire    [31:0]  imAddr2;
    wire    [31:0]  imData2;
	 
    sm_rom reset_rom1(imAddr1, imData1);
	sm_rom2 reset_rom2(imAddr2, imData2);

    //data bus matrix
    wire    [31:0]  dmAddr1;
    wire            dmWe1;
    wire    [31:0]  dmWData1;
    wire    [31:0]  dmRData1;
	 
	wire    [31:0]  dmAddr2;
    wire            dmWe2;
    wire    [31:0]  dmWData2;
    wire    [31:0]  dmRData2;
	 
    /*sm_matrix matrix
    (
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .bAddr      ( dmAddr     ),
        .bWrite     ( dmWe       ),
        .bWData     ( dmWData    ),
        .bRData     ( dmRData    ),
        .gpioInput  ( gpioInput  ),
        .gpioOutput ( gpioOutput ),
        .pwmOutput  ( pwmOutput  ),
        .alsCS      ( alsCS      ),
        .alsSCK     ( alsSCK     ),
        .alsSDO     ( alsSDO     )
    );*/

	 
	sm_ram data_ram
    (
        .clk  ( clk      ),
        .a1   ( dmAddr1  ),
	    .a2   ( dmAddr2  ),
        .we1  ( dmWe1    ),
		.we2  ( dmWe2    ),
        .wd1  ( dmWData1 ),
		.wd2  ( dmWData2 ),
        .rd1  ( dmRData1 ),
		.rd2  ( dmRData2 )
    );
	 
    //initializing cpu cores
    sm_cpu sm_cpu1
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( addr      ),
        .regData    ( regData   ),
        .imAddr     ( imAddr1    ),
        .imData     ( imData1    ),
        .dmAddr     ( dmAddr1    ),
        .dmWe       ( dmWe1      ),
        .dmWData    ( dmWData1   ),
        .dmRData    ( dmRData1   )
    );
	 
	sm_cpu sm_cpu2
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .imAddr     ( imAddr2    ),
        .imData     ( imData2    ),
        .dmAddr     ( dmAddr2    ),
        .dmWe       ( dmWe2      ),
        .dmWData    ( dmWData2   ),
        .dmRData    ( dmRData2   )
    );

endmodule

//metastability input debouncer module
module sm_debouncer
#(
    parameter SIZE = 1
)
(
    input                    clk,
    input      [ SIZE - 1 : 0] d,
    output reg [ SIZE - 1 : 0] q
);
    reg        [ SIZE - 1 : 0] data;

    always @ (posedge clk) begin
        data <= d;
        q    <= data;
    end

endmodule

//tunable clock devider
module sm_clk_divider
#(
    parameter shift  = 16,
              bypass = 0
)
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] devide,
    input           enable,
    output          clkOut
);
    wire [31:0] cntr;
    wire [31:0] cntrNext = cntr + 1;
    sm_register_we r_cntr(clkIn, rst_n, enable, cntrNext, cntr);

    assign clkOut = bypass ? clkIn 
                           : cntr[shift + devide];
endmodule

module sm_ram
#(
    parameter SIZE = 64
)
(
    input         clk,
    input  [31:0] a1,
	input  [31:0] a2,
    input         we1,
	input         we2,
    input  [31:0] wd1,
	input  [31:0] wd2,
    output [31:0] rd1,
	output [31:0] rd2
);
    reg [31:0] ram [SIZE - 1:0];
    assign rd1 = ram [a1[31:2]];
	assign rd2 = ram [a2[31:2]];

    always @(posedge clk)
	 begin
        if (we1)
            ram[{1'b1, a1[30:2]}] <= wd1;
        if (we2)
            ram[{1'b0, a1[30:2]}] <= wd2;			
    end

endmodule

module sm_rom2
#(
    parameter SIZE = 64
)
(
    input  [31:0] a,
    output [31:0] rd
);
    reg [31:0] rom [SIZE - 1:0];
    assign rd = rom [a];
    
    initial begin
        $readmemh ("program1.hex", rom);
    end
endmodule