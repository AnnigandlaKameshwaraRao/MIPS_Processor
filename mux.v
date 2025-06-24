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