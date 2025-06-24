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