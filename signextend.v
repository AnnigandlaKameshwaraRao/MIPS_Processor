module sign_extend (
	input  [15:0] idata,
	output reg [31:0] odata
);

	always @(idata) 
    begin
		odata = {{16{idata[15]}}, idata};
	end

endmodule