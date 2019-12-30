`timescale 1ns/10ps
// Name:alu_tb.v
// Module: alu_tb
// Input: 
// Output: 
//
// Notes: Testbench for project 2 testing ALU functionality
// 
// Supports the following functions
//	
//	- Integer add (0x20), sub(0x22), mul(0x2c)
//	- Integer shift_rigth (0x02), shift_left (0x01)
//	- Bitwise and (0x24), or (0x25), nor (0x27)
//  - set less than (0x2a)
//
// 
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 02, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//  1.1     Sep 04, 2014	Kaushik Patra	kpatra@sjsu.edu		Fixed test_and_count task
//                                                                      to count number of test and
//                                                                      pass correctly.
//------------------------------------------------------------------------------------------
//
`include "prj_definition.v"
module alu_tb;

integer total_test;
integer pass_test;

reg [`ALU_OPRN_INDEX_LIMIT:0] oprn_reg;
reg [`DATA_INDEX_LIMIT:0] op1_reg;
reg [`DATA_INDEX_LIMIT:0] op2_reg;

wire zero_reg;
wire [`DATA_INDEX_LIMIT:0] r_net;

// Instantiation of ALU
ALU ALU_INST_01(.OUT(r_net),.ZERO(zero_reg), .OP1(op1_reg), 
                .OP2(op2_reg), .OPRN(oprn_reg));

// Drive the test patterns and test
initial
begin
op1_reg=0;
op2_reg=0;
oprn_reg=0;

total_test = 0;
pass_test = 0;

// test 15 + 3 = 18
#5  op1_reg=15;
    op2_reg=3;
    oprn_reg=`ALU_OPRN_WIDTH'h20;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 15-5 =10
#5  op1_reg=15;
    op2_reg=5;
    oprn_reg=`ALU_OPRN_WIDTH'h22;   
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 15+5 =20
#5  op1_reg=15;
    op2_reg=5;
    oprn_reg=`ALU_OPRN_WIDTH'h20;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 20*10 = 200
#5  op1_reg=20;
    op2_reg=10;
    oprn_reg=`ALU_OPRN_WIDTH'h2c;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 20>>1 = 10
#5  op1_reg=20;
    op2_reg=1;
    oprn_reg=`ALU_OPRN_WIDTH'h02;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 20<<1 = 40
#5 op1_reg=20;
    op2_reg=1;
    oprn_reg=`ALU_OPRN_WIDTH'h01;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 1 & 0 = 0
#5 op1_reg=1;
    op2_reg=0;
    oprn_reg=`ALU_OPRN_WIDTH'h24;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 1 &1 = 1
#5 op1_reg=1;
    op2_reg=1;
    oprn_reg=`ALU_OPRN_WIDTH'h24;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 1 | 0 = 1
#5  op1_reg=1;
    op2_reg=0;
    oprn_reg=`ALU_OPRN_WIDTH'h25;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 0|0 0
#5  op1_reg=0;
    op2_reg=0;
    oprn_reg=`ALU_OPRN_WIDTH'h25;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 0 nor 0 = 32 bit 1
#5  op1_reg=0;
    op2_reg=0;
    oprn_reg=`ALU_OPRN_WIDTH'h27;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 32 bit 1 nor 32 bit 1 = 0
#5  op1_reg=2147483647;
    op2_reg=2147483647;
    oprn_reg=`ALU_OPRN_WIDTH'h27;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 1 set less than 10  =1 
#5  op1_reg=1;
    op2_reg=10;
    oprn_reg=`ALU_OPRN_WIDTH'h2a;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));
//test 10 set less than 1 =0 
#5  op1_reg=10;
    op2_reg=1;
    oprn_reg=`ALU_OPRN_WIDTH'h2a;
#5  test_and_count(total_test, pass_test, 
                   test_golden(op1_reg,op2_reg,oprn_reg,r_net,zero_reg));



#5  $write("\n");
    $write("\tTotal number of tests %d\n", total_test);
    $write("\tTotal number of pass  %d\n", pass_test);
    $write("\n");
    $stop; // stop simulation here
end

//-----------------------------------------------------------------------------
// TASK: test_and_count
// 
// PARAMETERS: 
//     INOUT: total_test ; total test counter
//     INOUT: pass_test ; pass test counter
//     INPUT: test_status ; status of the current test 1 or 0
//
// NOTES: Keeps track of number of test and pass cases.
//
//-----------------------------------------------------------------------------
task test_and_count;
inout total_test;
inout pass_test;
input test_status;

integer total_test;
integer pass_test;
begin
    total_test = total_test + 1;
    if (test_status)
    begin
        pass_test = pass_test + 1;
    end
end
endtask

//-----------------------------------------------------------------------------
// FUNCTION: test_golden
// 
// PARAMETERS: op1, op2, oprn and result
// RETURN: 1 or 0 if the result matches golden 
//
// NOTES: Tests the result against the golden. Golden is generated inside.
//
//-----------------------------------------------------------------------------
function test_golden;
input [`DATA_INDEX_LIMIT:0] op1;
input [`DATA_INDEX_LIMIT:0] op2;
input [`ALU_OPRN_INDEX_LIMIT:0] oprn;
input [`DATA_INDEX_LIMIT:0] res;
input [`DATA_INDEX_LIMIT:0] zero;

reg [`DATA_INDEX_LIMIT:0] golden; // expected result
begin
    $write("[TEST] %0d ", op1);
    case(oprn)
        `ALU_OPRN_WIDTH'h20 : begin $write("+ "); golden = op1 + op2; end
	`ALU_OPRN_WIDTH'h22 : begin $write("- "); golden = op1 - op2; end
	`ALU_OPRN_WIDTH'h2c : begin $write("* "); golden = op1 * op2; end
	`ALU_OPRN_WIDTH'h02 : begin $write(">> "); golden = op1 >> op2; end
	`ALU_OPRN_WIDTH'h01 : begin $write("<< "); golden = op1 << op2; end
	`ALU_OPRN_WIDTH'h24 : begin $write("& "); golden = op1 & op2; end
	`ALU_OPRN_WIDTH'h25 : begin $write("| "); golden = op1 | op2; end
	`ALU_OPRN_WIDTH'h27 : begin $write("nor "); golden = ~(op1 | op2); end //using another logic operation which equals to nor
	`ALU_OPRN_WIDTH'h2a : begin $write("slt "); golden = op1<op2; end
       
        default: begin $write("? "); golden = `DATA_WIDTH'hx; end
    endcase
    $write("%0d = %0d , got %0d ... ", op2, golden, res);
    $write("ZERO is %0d ", zero);
    if((res ==0 && zero == 0) || (res !=0 && zero ==1))
	    test_golden =0; 
	else 
    	     test_golden = (res === golden )?1'b1:1'b0; // case equality

    if (test_golden)
	$write("[PASSED]");
    else 
        $write("[FAILED]");
    $write("\n");
end
endfunction

endmodule
