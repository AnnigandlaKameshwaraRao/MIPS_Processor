module tb_mips;

reg clk;
reg reset;
wire [31:0] instruction;


mips mips_DUT(clk, reset,instruction);

initial
	forever #5 clk = ~clk;

initial 
begin
//   $dumpfile("waves.vcd");  
//   $dumpvars(0, tb_mips);
	clk = 0;
	reset = 1;
	#10 
	reset = 0;
	#550 $finish;

end

always@(posedge clk)begin
$display("%4t, Instruction : %h",$time,instruction);
end

endmodule