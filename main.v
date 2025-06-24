module alu (
    input clk,
    input [31:0] a_in, b_in,
    input [2:0] f_in,
    output zero,
    output c_out,
    output [31:0] y_out
);
    
   
    wire [31:0] b_in_bar;
    assign b_in_bar = ~ b_in;

    wire [31:0] b_mux_not_b;
    assign b_mux_not_b = f_in[2] ? b_in_bar : b_in; // Changing b with respect to add or subtract or set less than operations

    wire [31:0] fx00; // AND
    assign fx00 = a_in & b_mux_not_b;

    wire [31:0] fx01; // OR
    assign fx01 = a_in | b_mux_not_b;

    wire [31:0] fx10; // ADD , SUBTRACT
    assign {c_out, fx10} = a_in + b_mux_not_b + f_in[2]; // Performing 2's compliment addition and subtraction

    wire [31:0] fx11; // SET LESS THAN
    assign fx11 = {{31{1'b0}}, (a_in[31] != b_in[31]) ? a_in[31] : fx10[31]}; // Returns 1 if a < b

    

    assign y_out = (2'b00 == f_in[1:0]) ? fx00 : 
                    (2'b01 == f_in[1:0] ? fx01 : 
                    (2'b10 == f_in[1:0] ? fx10 : 
                                          fx11 ));
    assign zero = (y_out == 32'b0);
     always@(posedge clk)
        $display("%4t,a=%b, b=%b, f=%b, zero=%b, c_out=%b, y=%b",$time,a_in,b_in,f_in,zero,c_out,y_out);

endmodule

module alucontrol(
    input [1:0] AluOp,
    input [5:0] FnField, // funct field for R-type instructions
    output reg [2:0] AluCtrl
);

always @(*) begin
    case (AluOp)
        2'b00: AluCtrl = 3'b010; // lw/sw/addi - always use ADD
        2'b01: AluCtrl = 3'b110; // beq - always use SUBTRACT
        2'b10: begin             // R-type - check funct code
            case (FnField)
                6'b100000: AluCtrl = 3'b010; // ADD
                6'b100010: AluCtrl = 3'b110; // SUB
                6'b100100: AluCtrl = 3'b000; // AND
                6'b100101: AluCtrl = 3'b001; // OR
                6'b101010: AluCtrl = 3'b111; // SLT
                6'b000000: AluCtrl = 3'b011; // SLL (shift left logical)
                6'b000010: AluCtrl = 3'b100; // SRL (shift right logical)
                default:   AluCtrl = 3'b010;  // Default to ADD for unknown R-types
            endcase
        end
        default: AluCtrl = 3'b010; // Fallback to ADD
    endcase
end

endmodule

module mux #(
    parameter DATA_LENGTH = 8
) (
    input sel,
    input [DATA_LENGTH-1:0] ina,
    input [DATA_LENGTH-1:0] inb,
    output reg [DATA_LENGTH-1:0] out 
);

always @(*) begin
    case (sel)
        1'b0: out = ina;   
        1'b1: out = inb;   
        default: out = ina;
    endcase
end

endmodule

module pclogic(

    input reset,
    input clk,
    input [31:0] ain,
    input pcsel,
    input jump,
    input jal,

    output reg [31:0] aout

);


always @(posedge clk ) begin
	if (reset==1)
		aout<=32'b0;
	else 
    begin
        if (jump==1) // jump
        begin
            aout<=ain;
        end
        else 
        begin
            if (pcsel==0) 
            begin
                aout<=aout+1;
            end
            if (pcsel==1) 
            begin
                aout<=ain+aout+1; //branch
            end
	    end
    end
    $display("%4t , %32b, %b\n",$time,aout,pcsel);
end


endmodule

module registerfile(

    input clk,

	input [4:0] ra,
	input [4:0] rb,
	output [31:0] da,
	output [31:0] db,
	
	input regWrite,
	input [4:0] rc,
	input [31:0] dc


);


reg [31:0] memory [31:0]; //32 32-bit registers

initial begin
    memory[0]=32'h00000000;
    memory[1]=32'h00000001;
    memory[2]=32'h00000002;
    memory[3]=32'h00000003;
    memory[4]=32'h00000004;
    memory[8]=32'h0000000a;
    memory[9]=32'h00000000;
    memory[10]=32'h00000000;
    memory[11]=32'h00000000;
    memory[12]=32'h00000005;
    memory[13]=32'h00000000;
    memory[14]=32'h00000000;
end

assign da=(ra!=0)?memory[ra]:0;
assign db=(rb!=0)?memory[rb]:0;

always@(posedge clk)
begin
	if(regWrite==1'b1)
    begin
		memory[rc]=dc;
	end
end
endmodule

module sign_extend (
	input  [15:0] idata,
	output reg [31:0] odata
);

	always @(idata) 
    begin
		odata = {{16{idata[15]}}, idata};
	end

endmodule

module dmem (
	input clk,
	input write_enable,
    input read_enable,
	input [5:0] addr, // 64 - 32 bit data = 2 KB Data RAM
	input [31:0] wdata,
	output [31:0] rdata
);

	reg [31:0] memdata [63:0];

	assign rdata = memdata[addr];
    
	always @(posedge clk ) 
    begin
		if(write_enable==1'b1) 
        begin
			memdata[addr] <= wdata;
			$display("%4t, write, mem[%2d]=%2d\n",$time,addr,wdata);
		end
		$display("%4t, read, mem[%2d]=%2d\n",$time,addr,rdata);
	end

endmodule


module imem (
    input  [5:0] addr,
    output [31:0] data
);
    reg [31:0] mem[0:63];

    assign data = mem[addr];

    initial begin

        // Initialize array in memory (address 0x100 simulated via registers)
        // Using $zero ($0) as source for immediate values
        mem[0]  = 32'h00084020;  // add $t0, $0, $t0  (equivalent to addi $t0, $0, 0x100)
        mem[1]  = 32'h00094820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 1)
        mem[2]  = 32'had090000;  // sw $t1, 0($t0)    (array[0] = 1)
        mem[3]  = 32'h00294820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 2)
        mem[4]  = 32'had090001;  // sw $t1, 4($t0)    (array[1] = 2)
        mem[5]  = 32'h00294820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 3)
        mem[6]  = 32'had090002;  // sw $t1, 8($t0)    (array[2] = 3)
        mem[7]  = 32'h00294820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 4)
        mem[8]  = 32'had090003;  // sw $t1, 12($t0)   (array[3] = 4)
        mem[9]  = 32'h00294820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 5)
        mem[10] = 32'had090004;  // sw $t1, 16($t0)   (array[4] = 5)

        // Sum loop
        mem[11] = 32'h000a5020;  // add $t2, $0, $t2  (sum = 0)
        mem[12] = 32'h000b5820;  // add $t3, $0, $t3  (i = 0)
        mem[13] = 32'h000c6020;  // add $t4, $0, $t4  (loop limit = 5)

        // loop:
        mem[14] = 32'h016c682a;  // slt $t5, $t3, $t4 (i < 5?)
        mem[15] = 32'h11a00005;  // beq $t5, $0, exit
        mem[16] = 32'h8d0d0000;  // lw $t6, 0($t0)    (load array[i])
        mem[17] = 32'h014d5020;  // add $t2, $t2, $t6 (sum += array[i])
        mem[18] = 32'h00284020;  // add $t0, $t0, 1 (addr+=1)
        mem[19] = 32'h002b5820;  // add $t3, $t3, 1 (i=i+1)
        mem[20] = 32'h0800000e;  // j loop

        // exit:
        mem[21] = 32'hac0a0100;  // sw $t2, 0x100($0) (store sum)
    

        // Fill rest with 0
        for (integer i = 22; i < 64; i++) begin
            mem[i] = 32'h00000000;
        end
    end
endmodule

module datapath(

    input clk,
    input reset,

    input RegDst,AluSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Jump,Jal,
    input [1:0] ALUOp,

    output [5:0] OpCode,
    output [31:0] Instruction

);

wire [31:0] ReadRegister1;
wire [31:0] ReadRegister2;

// INSTRUCTION FETCH
wire [31:0] PC_adr;

imem meminstr(.addr(PC_adr[5:0]),.data(Instruction)); //Instruction memory
assign OpCode = Instruction[31:26];

wire [31:0] signExtend;
sign_extend Signextend(.odata(signExtend), .idata(Instruction[15:0])); //Sign extend


// EXECUTE

wire [2:0] ALUCtrl;
alucontrol AluControl(.AluOp(ALUOp), .FnField(Instruction[5:0]), .AluCtrl(ALUCtrl)); //ALUControl

wire [31:0] muxalu_out;
mux #(32) muxalu(AluSrc, ReadRegister2, signExtend, muxalu_out);//MUX for ALU

wire [31:0] ALUout;
wire Zero;
wire ALUcout;
alu Alu(.clk(clk),.a_in(ReadRegister1), .b_in(muxalu_out), .f_in(ALUCtrl), .y_out(ALUout), .zero(Zero),.c_out(ALUcout)); //ALU

// PC

reg PCsel;
always @(Branch or Zero) begin
    PCsel = Branch & Zero;
end

    
pclogic PC(.clk(clk), .reset(reset), .ain(signExtend), .aout(PC_adr), .pcsel(PCsel),.jump(Jump),.jal(Jal)); //generate PC


// MEM

wire [31:0] muxdata_out;
wire [31:0] ReadData;


dmem memdata(.clk(clk), .addr(ALUout[5:0]), .rdata(ReadData), .wdata(ReadRegister2), .read_enable(MemRead), .write_enable(MemWrite)); //Data memory
mux #(32) muxdata(MemtoReg, ALUout, ReadData, muxdata_out); //MUX from Data memory

// WRITE BACK


wire [4:0] muxinstr_out;

mux #(5) muxinstr(RegDst, Instruction[20:16],Instruction[15:11],muxinstr_out);//MUX for Write Register
registerfile rf(.clk(clk),.regWrite(RegWrite),.ra(Instruction[25:21]),.rb(Instruction[20:16]),.rc(muxinstr_out), .da(ReadRegister1), .db(ReadRegister2), .dc(muxdata_out)); //Registers

always @(posedge clk)
    $display("%4t,Branch:%b, Zero: %b, dc: %b, rc:%b, ra:%b, da:%b, rb:%b, db:%b, AluSrc:%b, muxaluout:%b, PCsel=%b\n",$time,Branch,Zero,muxdata_out,muxinstr_out,Instruction[25:21],ReadRegister1,Instruction[20:16],ReadRegister2,AluSrc,muxalu_out,PCsel);

endmodule

module controlpath(
    input clk,
    input [5:0] opcode,
    output reg RegDst,
    output reg AluSrc,
    output reg MemtoReg,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg Jump,
    output reg Jal,
    output reg [1:0] AluOP
);

always @(posedge clk or opcode) begin
    case (opcode)
        6'b000000: begin // R-type
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'b10010000010;
            $display("%4t R-type instruction detected\n",$time);
            $display("Control signals: RegDst=1, AluSrc=0, MemtoReg=0, RegWrite=1, MemRead=0, MemWrite=0, Jump=0, Branch=0, AluOP=2'b10\n");
        end
        
        6'b000010: begin // j
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'bxxx000100xx;
            $display("%4t Jump (j) instruction detected\n",$time);
            $display("Control signals: Jump=1, all others don't-care\n");
        end
        
        6'b100011: begin // lw
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'b01111000000;
            $display("%4t Load Word (lw) instruction detected\n",$time);
            $display("Control signals: AluSrc=1, MemtoReg=1, RegWrite=1, MemRead=1, AluOP=2'b00\n");
        end
        
        6'b101011: begin // sw
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'bx1x00100000;
            $display("%4t Store Word (sw) instruction detected\n",$time);
            $display("Control signals: AluSrc=1, MemWrite=1, AluOP=2'b00\n");
        end
        
        6'b000100: begin // beq
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'bx0x00000101;
            $display("%4t Branch Equal (beq) instruction detected\n",$time);
            $display("Control signals: Branch=1, AluOP=2'b01\n");
        end
        
        6'b000011: begin // jal
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'b0xx100110xx;
            $display("%4t Jump and Link (jal) instruction detected\n",$time);
          $display("Control signals: Jump=1,Jump and link=1, Reg Write=1, all others don't-care\n");
        end
        
        default: begin
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'bxxxxxxxxxxx;
            $display("%4t Unknown opcode: %6b\n", $time, opcode);
            $display("All control signals set to don't-care\n");
        end
    endcase
end

endmodule

module mips(
    input clk,
    input reset,
    output [31:0] Instruction
);


wire [5:0] OpCode;
wire [1:0] ALUOp;

wire RegDst;
wire AluSrc;
wire MemToReg;
wire RegWrite;
wire MemRead;
wire MemWrite;
wire Branch;
wire Jump;
wire Jal;


datapath Datapath(.clk(clk),.reset(reset),.RegDst(RegDst),.AluSrc(AluSrc),.MemtoReg(MemToReg),.RegWrite(RegWrite),.MemRead(MemRead),.MemWrite(MemWrite),.Branch(Branch),.Jump(Jump),.Jal(Jal),.ALUOp(ALUOp),.OpCode(OpCode),.Instruction(Instruction));

controlpath Control(.clk(clk),.opcode(OpCode),.RegDst(RegDst),.AluSrc(AluSrc),.MemtoReg(MemToReg),.RegWrite(RegWrite),.MemRead(MemRead),.MemWrite(MemWrite),.Branch(Branch),.Jump(Jump),.Jal(Jal),.AluOP(ALUOp)); 

endmodule



