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