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