// Name: register_file_tb.v
// Module: DA_VINCI_TB
// 
//
// Monitors:  DATA_W : Data to be written at address ADDR_W
//         ADDR_W : Address of the memory location to be written
//         ADDR_R1 : Address of the memory location to be read for DATA_R1
//         ADDR_R2 : Address of the memory location to be read for DATA_R2
//         READ    : Read signal
//         WRITE   : Write signal
//
// Input:   DATA_R1 : Data at ADDR_R1 address
//         DATA_R2 : Data at ADDR_R1 address
//          CLK  : Clock signal
//          RST  : Reset signal
//
// Notes: - Testbench for register file system
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "prj_definition.v"
module REG_FILE_TB;
// Storage list
reg [`REG_ADDR_INDEX_LIMIT:0] ADDR_R1;
reg [`REG_ADDR_INDEX_LIMIT:0] ADDR_R2;
reg [`REG_ADDR_INDEX_LIMIT:0] ADDR_W;
// reset
reg READ, WRITE, RST;
// data register
reg [`DATA_INDEX_LIMIT:0] DATA_R1;
reg [`DATA_INDEX_LIMIT:0] DATA_R2;
reg [`DATA_INDEX_LIMIT:0] DATA_W;
integer i; // index for memory operation
integer no_of_test, no_of_pass;
integer load_data;

// wire lists
wire  CLK;
wire [`DATA_INDEX_LIMIT:0] DATA_ret1;
wire [`DATA_INDEX_LIMIT:0] DATA_ret2;

assign DATA_ret1 = ((READ===1'b0)&&(WRITE===1'b1))?DATA_R1:{`DATA_WIDTH{1'bz} };
assign DATA_ret2 = ((READ===1'b0)&&(WRITE===1'b1))?DATA_R2:{`DATA_WIDTH{1'bz} };


// Clock generator instance
CLK_GENERATOR clk_gen_inst(.CLK(CLK));
REGISTER_FILE_32x32 reg_inst(.DATA_R1(DATA_ret1), .DATA_R2(DATA_ret2), .ADDR_R1(ADDR_R1),.ADDR_R2(ADDR_R2), .DATA_W(DATA_W), 
		.ADDR_W(ADDR_W),.READ(READ), .WRITE(WRITE), .CLK(CLK), .RST(RST));

initial
begin
RST=1'b1;
READ=1'b0;
WRITE=1'b0;
DATA_R1 = {`DATA_WIDTH{1'b0} };
DATA_R2 = {`DATA_WIDTH{1'b0} };
DATA_W = {`DATA_WIDTH{1'b0} };
no_of_test = 0;
no_of_pass = 0;

// Start the operation
#10    RST=1'b0;
#10    RST=1'b1;
// Write cycle
for(i=1;i<10; i = i + 1)
begin
#10     DATA_W=i; READ=1'b0; WRITE=1'b1; ADDR_W = i;
end

// Read Cycle
#10   READ=1'b0; WRITE=1'b0;
#5    no_of_test = no_of_test + 1;
      if (DATA_ret1 !== {`DATA_WIDTH{1'bz}} && DATA_ret2 !== {`DATA_WIDTH{1'bz}} )
        $write("[TEST] Read %1b, Write %1b, expecting 32'hzzzzzzzz, got %8h and %8h [FAILED]\n", READ, WRITE, DATA_R1, DATA_R2);
      else 
	no_of_pass  = no_of_pass + 1;

// test of write data
for(i=0;i<10; i = i + 1)
begin
#5      READ=1'b1; WRITE=1'b0; ADDR_R1 = i; ADDR_R2 = i;
#5      no_of_test = no_of_test + 1;
        if (DATA_ret1 !== i && DATA_ret2 !==i)
	    $write("[TEST] Read %1b, Write %1b, expecting %8h, got %8h and %8h[FAILED]\n", READ, WRITE, i, DATA_R1, DATA_R2);
        else 
	    no_of_pass  = no_of_pass + 1;

end

#10    READ=1'b0; WRITE=1'b0; // No op

#10 $write("\n");
    $write("\tTotal number of tests %d\n", no_of_test);
    $write("\tTotal number of pass  %d\n", no_of_pass);
    $write("\n");
    $stop;

end
endmodule;

