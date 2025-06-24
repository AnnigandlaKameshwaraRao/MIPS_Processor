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