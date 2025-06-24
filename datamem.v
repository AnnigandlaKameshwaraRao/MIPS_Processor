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