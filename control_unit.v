// Name: control_unit.v
// Module: CONTROL_UNIT
// Output: RF_DATA_W  : Data to be written at register file address RF_ADDR_W
//         RF_ADDR_W  : Register file address of the memory location to be written
//         RF_ADDR_R1 : Register file address of the memory location to be read for RF_DATA_R1
//         RF_ADDR_R2 : Registere file address of the memory location to be read for RF_DATA_R2
//         RF_READ    : Register file Read signal
//         RF_WRITE   : Register file Write signal
//         ALU_OP1    : ALU operand 1
//         ALU_OP2    : ALU operand 2
//         ALU_OPRN   : ALU operation code
//         MEM_ADDR   : Memory address to be read in
//         MEM_READ   : Memory read signal
//         MEM_WRITE  : Memory write signal
//         
// Input:  RF_DATA_R1 : Data at ADDR_R1 address
//         RF_DATA_R2 : Data at ADDR_R1 address
//         ALU_RESULT    : ALU output data
//         CLK        : Clock signal
//         RST        : Reset signal
//
// INOUT: MEM_DATA    : Data to be read in from or write to the memory
//
// Notes: - Control unit synchronize operations of a processor
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//  1.1     Oct 19, 2014        Kaushik Patra   kpatra@sjsu.edu         Added ZERO status output
//------------------------------------------------------------------------------------------
`include "prj_definition.v"
module CONTROL_UNIT(MEM_DATA, RF_DATA_W, RF_ADDR_W, RF_ADDR_R1, RF_ADDR_R2, RF_READ, RF_WRITE,
                    ALU_OP1, ALU_OP2, ALU_OPRN, MEM_ADDR, MEM_READ, MEM_WRITE,
                    RF_DATA_R1, RF_DATA_R2, ALU_RESULT, ZERO, CLK, RST); 

// Output signals
// Outputs for register file 
output [`DATA_INDEX_LIMIT:0] RF_DATA_W;
output [`REG_ADDR_INDEX_LIMIT:0] RF_ADDR_W, RF_ADDR_R1, RF_ADDR_R2;
output RF_READ, RF_WRITE;
// Outputs for ALU
output [`DATA_INDEX_LIMIT:0]  ALU_OP1, ALU_OP2;
output  [`ALU_OPRN_INDEX_LIMIT:0] ALU_OPRN;
// Outputs for memory
output [`ADDRESS_INDEX_LIMIT:0]  MEM_ADDR;
output MEM_READ, MEM_WRITE;

// Input signals
input [`DATA_INDEX_LIMIT:0] RF_DATA_R1, RF_DATA_R2, ALU_RESULT;
input ZERO, CLK, RST;

// Inout signal
inout [`DATA_INDEX_LIMIT:0] MEM_DATA;

// State nets
wire [2:0] proc_state;

PROC_SM state_machine(.STATE(proc_state),.CLK(CLK),.RST(RST));

//outputs register
reg RF_READ_REG, RF_WRITE_REG, MEM_READ_REG, MEM_WRITE_REG;
reg [`DATA_INDEX_LIMIT:0]  ALU_OP1_REG, ALU_OP2_REG, RF_DATA_W_REG, MEM_DATA_REG;
reg [`REG_ADDR_INDEX_LIMIT:0] RF_ADDR_W_REG, RF_ADDR_R1_REG, RF_ADDR_R2_REG;
reg [`ADDRESS_INDEX_LIMIT:0] MEM_ADDR_REG;
reg [`ALU_OPRN_INDEX_LIMIT:0] ALU_OPRN_REG;

assign ALU_OP1 = ALU_OP1_REG; 
assign ALU_OP2 = ALU_OP2_REG;
assign ALU_OPRN = ALU_OPRN_REG;
assign RF_READ = RF_READ_REG; 
assign RF_WRITE = RF_WRITE_REG;
assign MEM_READ = MEM_READ_REG; 
assign MEM_WRITE = MEM_WRITE_REG;
assign RF_ADDR_W = RF_ADDR_W_REG; 
assign RF_DATA_W = RF_DATA_W_REG;
assign RF_ADDR_R1 = RF_ADDR_R1_REG; 
assign RF_ADDR_R2 = RF_ADDR_R2_REG;
assign MEM_ADDR = MEM_ADDR_REG;
assign MEM_DATA = ((MEM_READ===1'b0)&&(MEM_WRITE===1'b1))?MEM_DATA_REG:{`DATA_WIDTH{1'bz} };

reg [`ADDRESS_INDEX_LIMIT:0] PC_REG, SP_REF;
reg [`DATA_INDEX_LIMIT:0] INST_REG;


reg [5:0] opcode;
reg [4:0] rs;
reg [4:0] rt;
reg [4:0] rd;
reg [4:0] shamt;
reg [5:0] funct;
reg [15:0] immediate;
reg [25:0] address;
reg [`DATA_INDEX_LIMIT:0] signExtendedImmediate;
reg [`DATA_INDEX_LIMIT:0] zeroExtendedImmediate;
reg [`DATA_INDEX_LIMIT:0] lui;
reg [`DATA_INDEX_LIMIT:0] jumpAddress;

initial
begin
 PC_REG = 'h0001000;
 SP_REF = 'h3ffffff;
end


always @ (proc_state)
begin
  if(proc_state == `PROC_FETCH)
	begin
	MEM_ADDR_REG = PC_REG;
	MEM_READ_REG = 1'b1; 
	MEM_WRITE_REG = 1'b0;
	RF_READ_REG = 1'b0;
 	RF_WRITE_REG =1'b0;
	end
  if(proc_state == `PROC_DECODE)
	begin 
	INST_REG = MEM_DATA;
	//R-type 
	{opcode, rs, rt, rd, shamt, funct} = INST_REG; 
	// I-type 
	{opcode, rs, rt, immediate } = INST_REG; 
	// J-type
	 {opcode, address} = INST_REG; 
	
	signExtendedImmediate = {{16{immediate[15]}},immediate} ;
	 zeroExtendedImmediate = {{16'h0,immediate}} ;
	 lui = {immediate, 16'h0};
	jumpAddress = {6'b0, address};
	
	RF_ADDR_R1_REG = rs;
	RF_ADDR_R2_REG = rt;
	RF_READ_REG = 1'h1;
	end
 if(proc_state == `PROC_EXE)
begin
	case(opcode)
//handle r-type
	6'h0 :
		begin 
		  if(funct === 6'h08)
 	  	     begin
   		     PC_REG = RF_DATA_R1;
  	 	     end
		  if(funct === 6'h01 || funct === 6'h02)
		     begin 
		     ALU_OP1_REG = RF_DATA_R1;
		     ALU_OP2_REG = shamt;
		     ALU_OPRN_REG = funct;
		     end
		  else
		   begin
		   ALU_OP1_REG = RF_DATA_R1;
		   ALU_OP2_REG = RF_DATA_R2;
		   ALU_OPRN_REG = funct;
		   end
		end
//handle i-type
	6'h08 :
		begin
		  ALU_OPRN_REG = `ALU_OPRN_WIDTH'h20;
		  ALU_OP1_REG = RF_DATA_R1;
		  ALU_OP2_REG = signExtendedImmediate;
		end
	6'h1d :
		begin
		  ALU_OPRN_REG = `ALU_OPRN_WIDTH'h2c;
		  ALU_OP1_REG = RF_DATA_R1;
		  ALU_OP2_REG = signExtendedImmediate;
		end
	6'h0c :
		begin
		  ALU_OPRN_REG = `ALU_OPRN_WIDTH'h24;
		  ALU_OP1_REG = RF_DATA_R1;
		  ALU_OP2_REG = zeroExtendedImmediate;
		end
	6'h0d:
		begin
		  ALU_OPRN_REG = `ALU_OPRN_WIDTH'h25;
		  ALU_OP1_REG = RF_DATA_R1;
		  ALU_OP2_REG = zeroExtendedImmediate;
		end
	6'h0a :
		begin
		  ALU_OPRN_REG = `ALU_OPRN_WIDTH'h2a;
		  ALU_OP1_REG = RF_DATA_R1;
		  ALU_OP2_REG = signExtendedImmediate;
		end
	6'h23 :
		begin
		  ALU_OPRN_REG = `ALU_OPRN_WIDTH'h20;
		  ALU_OP1_REG = RF_DATA_R1;
		  ALU_OP2_REG = signExtendedImmediate;
		end
	6'h2b:
		begin
		  ALU_OPRN_REG = `ALU_OPRN_WIDTH'h20;
		  ALU_OP1_REG = RF_DATA_R1;
		  ALU_OP2_REG = signExtendedImmediate;
		end
	//handle j-type push 
	 6'h1b :
		 begin
		 RF_ADDR_R1_REG = 0;
 		end
	endcase
end
if(proc_state == `PROC_MEM)
begin 
	MEM_READ_REG = 1'b1;
	MEM_WRITE_REG = 1'b1;

	case(opcode)
		//handle i type instruction
		6'h23:
			begin
			   MEM_ADDR_REG = ALU_RESULT;
			   MEM_WRITE_REG = 1'b0;
			end
		6'h2b:
			begin 
			  MEM_ADDR_REG = ALU_RESULT;
		          MEM_DATA_REG = RF_DATA_R2;
			  MEM_READ_REG = 1'b0;
			 
			end
		//handle j type
		6'h1b:
			begin
			  MEM_ADDR_REG = SP_REF;
			  MEM_DATA_REG = RF_DATA_R1;
			  MEM_READ_REG = 1'b0;
			  SP_REF = SP_REF - 1;
			end
		6'h1c:
			begin
			  SP_REF = SP_REF+1;
			  MEM_ADDR_REG = SP_REF;
			  MEM_WRITE_REG = 1'b0;	
			end 
	endcase
end
if(proc_state == `PROC_WB)
begin 
//reset read write signals or memory and register file
PC_REG = PC_REG+1;
MEM_READ_REG = 1'b0;
MEM_WRITE_REG = 1'b0;
RF_READ_REG = 1'b0;
RF_WRITE_REG =1'b0;

	case(opcode)
//handle R-type
		6'h00:
		begin 
			 if(funct === 6'h08)
			PC_REG = RF_DATA_R1;
			else 
			begin 		
			 RF_ADDR_W_REG = rd;
			 RF_DATA_W_REG = ALU_RESULT;
			 RF_WRITE_REG = 1'b1;
			end
		end
//handle I-type
		6'h08:
			begin
			 RF_ADDR_W_REG = rt;
			 RF_DATA_W_REG = ALU_RESULT;
			 RF_WRITE_REG = 1'b1;
			end
		6'h0c:
			begin
			 RF_ADDR_W_REG = rt;
			 RF_DATA_W_REG = ALU_RESULT;
			 RF_WRITE_REG = 1'b1;
			end
		6'h0d:
			begin
			 RF_ADDR_W_REG = rt;
			 RF_DATA_W_REG = ALU_RESULT;
			 RF_WRITE_REG = 1'b1;
			end
		6'h1d:
			begin
			 RF_ADDR_W_REG = rt;
			 RF_DATA_W_REG = ALU_RESULT;
			 RF_WRITE_REG = 1'b1;
			end
		6'h0f:
			begin
			 RF_ADDR_W_REG = rt;
			 RF_DATA_W_REG = lui;
			 RF_WRITE_REG = 1'b1;
			end
		6'h0a:
			begin
			 RF_ADDR_W_REG = rt;
			 RF_DATA_W_REG = ALU_RESULT;
			 RF_WRITE_REG = 1'b1;
			end
		6'h04:
			begin 
			if(RF_DATA_R1 === RF_DATA_R2)
			 begin 
			 PC_REG = PC_REG +signExtendedImmediate;
			 end
			end
		6'h05:
			begin 
			 if(RF_DATA_R1 != RF_DATA_R2)
			  begin
			 PC_REG =PC_REG +signExtendedImmediate;
			  end
			end	
		6'h23:
			begin
			RF_ADDR_W_REG = rt;
			RF_DATA_W_REG = MEM_DATA;
			RF_WRITE_REG = 1'b1;
			end
	      //Setting PC Registers and writing back for J-Type Instructions
		6'h02:
			begin
			PC_REG = jumpAddress;	
			end
		6'h03:
			begin
			RF_DATA_W_REG = PC_REG;
			PC_REG = jumpAddress;
			RF_ADDR_W_REG = 31;
			RF_WRITE_REG = 1'b1;
			end
		6'h1c:
			begin
			RF_ADDR_W_REG =0;
			RF_DATA_W_REG = MEM_DATA;
			RF_WRITE_REG = 1'b1;
			end
		endcase		
		
end
end
endmodule;

//------------------------------------------------------------------------------------------
// Module: CONTROL_UNIT
// Output: STATE      : State of the processor
//         
// Input:  CLK        : Clock signal
//         RST        : Reset signal
//
// INOUT: MEM_DATA    : Data to be read in from or write to the memory
//
// Notes: - Processor continuously cycle witnin fetch, decode, execute, 
//          memory, write back state. State values are in the prj_definition.v
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
module PROC_SM(STATE,CLK,RST);
// list of inputs
input CLK, RST;
// list of outputs
output [2:0] STATE;
reg[2:0] current_state;
reg [2:0] next_state;
assign STATE = current_state;
initial
begin
current_state = 3'bxx;
next_state = `PROC_FETCH;
end

always @(negedge RST)
begin 
current_state = 3'bxx; //0 is PROC_FETCH
next_state = `PROC_FETCH;
end
//switching states
always @(posedge CLK)
begin 
current_state = next_state;
end
//switching next states when current states change
always @(current_state)
begin	
	case(current_state)
		`PROC_FETCH : next_state = `PROC_DECODE;
		`PROC_DECODE : next_state = `PROC_EXE;
		`PROC_EXE : next_state = `PROC_MEM;
		`PROC_MEM : next_state = `PROC_WB;
		`PROC_WB : next_state = `PROC_FETCH;
	endcase
	
end


endmodule;