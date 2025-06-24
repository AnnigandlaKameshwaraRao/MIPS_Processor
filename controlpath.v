module controlpath(
    input clk,
    input [5:0] opcode,
    output reg RegDst,
    output reg AluSrc,
    output reg MemtoReg,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg Jump,
    output reg Jal,
    output reg [1:0] AluOP
);

always @(posedge clk or opcode) begin
    case (opcode)
        6'b000000: begin // R-type
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'b10010000010;
            $display("%4t R-type instruction detected\n",$time);
            $display("Control signals: RegDst=1, AluSrc=0, MemtoReg=0, RegWrite=1, MemRead=0, MemWrite=0, Jump=0, Branch=0, AluOP=2'b10\n");
        end
        
        6'b000010: begin // j
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'bxxx000100xx;
            $display("%4t Jump (j) instruction detected\n",$time);
            $display("Control signals: Jump=1, all others don't-care\n");
        end
        
        6'b100011: begin // lw
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'b01111000000;
            $display("%4t Load Word (lw) instruction detected\n",$time);
            $display("Control signals: AluSrc=1, MemtoReg=1, RegWrite=1, MemRead=1, AluOP=2'b00\n");
        end
        
        6'b101011: begin // sw
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'bx1x00100000;
            $display("%4t Store Word (sw) instruction detected\n",$time);
            $display("Control signals: AluSrc=1, MemWrite=1, AluOP=2'b00\n");
        end
        
        6'b000100: begin // beq
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'bx0x00000101;
            $display("%4t Branch Equal (beq) instruction detected\n",$time);
            $display("Control signals: Branch=1, AluOP=2'b01\n");
        end
        
        6'b000011: begin // jal
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'b0xx100110xx;
            $display("%4t Jump and Link (jal) instruction detected\n",$time);
          $display("Control signals: Jump=1,Jump and link=1, Reg Write=1, all others don't-care\n");
        end
        
        default: begin
            {RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Jump,Jal, Branch, AluOP} = 11'bxxxxxxxxxxx;
            $display("%4t Unknown opcode: %6b\n", $time, opcode);
            $display("All control signals set to don't-care\n");
        end
    endcase
end

endmodule