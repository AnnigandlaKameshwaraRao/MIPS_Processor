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