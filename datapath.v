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