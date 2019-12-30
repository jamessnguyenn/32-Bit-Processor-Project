// Name: alu.v
// Module: ALU
// Input: OP1[32] - operand 1
//        OP2[32] - operand 2
//        OPRN[6] - operation code
// Output: OUT[32] - output result for the operation
//
// Notes: 32 bit combinatorial ALU
// 
// Supports the following functions
//	- Integer add (0x20), sub(0x22), mul(0x2c)
//	- Integer shift_rigth (0x02), shift_left (0x01)
//	- Bitwise and (0x24), or (0x25), nor (0x27)
//  - set less than (0x2a)
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//  1.1     Oct 19, 2014        Kaushik Patra   kpatra@sjsu.edu         Added ZERO status output
//------------------------------------------------------------------------------------------
//
`include "prj_definition.v"
module ALU(OUT, ZERO, OP1, OP2, OPRN);
// input list
input [`DATA_INDEX_LIMIT:0] OP1; // operand 1
input [`DATA_INDEX_LIMIT:0] OP2; // operand 2
input [`ALU_OPRN_INDEX_LIMIT:0] OPRN; // operation code

// output list
output [`DATA_INDEX_LIMIT:0] OUT; // result of the operation.
output ZERO;

// simulator internal storage - this is not h/w register
reg [`DATA_INDEX_LIMIT:0] OUT;
reg ZERO;


always @(OP1 or OP2 or OPRN)
begin
	case(OPRN)
		//set oprn numbers with correct function number for r type
		`ALU_OPRN_WIDTH'h20: OUT = OP1 +OP2;
		`ALU_OPRN_WIDTH'h22: OUT = OP1 - OP2;
		`ALU_OPRN_WIDTH'h2c: OUT = OP1*OP2;
		`ALU_OPRN_WIDTH'h02: OUT = OP1 >> OP2;
		`ALU_OPRN_WIDTH'h01: OUT = OP1 << OP2;
		`ALU_OPRN_WIDTH'h24: OUT = OP1 & OP2;
		`ALU_OPRN_WIDTH'h25: OUT = OP1 | OP2;
		`ALU_OPRN_WIDTH'h27: OUT = ~(OP1 | OP2);
		`ALU_OPRN_WIDTH'h2a: OUT = OP1 < OP2;
		default: OUT = `DATA_WIDTH'hxxxxxxxx;
	endcase
end

always @(OUT)
begin 
	if (OUT == 0) 
		ZERO = 1;
	else 
		ZERO = 0;
end
endmodule
