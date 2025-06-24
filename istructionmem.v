module imem (
    input  [5:0] addr,
    output [31:0] data
);
    reg [31:0] mem[0:63];

    assign data = mem[addr];

    initial begin

        // Initialize array in memory (address 0x100 simulated via registers)
        // Using $zero ($0) as source for immediate values
        mem[0]  = 32'h00084020;  // add $t0, $0, $t0  (equivalent to addi $t0, $0, 0x100)
        mem[1]  = 32'h00094820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 1)
        mem[2]  = 32'had090000;  // sw $t1, 0($t0)    (array[0] = 1)
        mem[3]  = 32'h00294820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 2)
        mem[4]  = 32'had090001;  // sw $t1, 4($t0)    (array[1] = 2)
        mem[5]  = 32'h00294820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 3)
        mem[6]  = 32'had090002;  // sw $t1, 8($t0)    (array[2] = 3)
        mem[7]  = 32'h00294820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 4)
        mem[8]  = 32'had090003;  // sw $t1, 12($t0)   (array[3] = 4)
        mem[9]  = 32'h00294820;  // add $t1, $0, $t1  (equivalent to addi $t1, $0, 5)
        mem[10] = 32'had090004;  // sw $t1, 16($t0)   (array[4] = 5)

        // Sum loop
        mem[11] = 32'h000a5020;  // add $t2, $0, $t2  (sum = 0)
        mem[12] = 32'h000b5820;  // add $t3, $0, $t3  (i = 0)
        mem[13] = 32'h000c6020;  // add $t4, $0, $t4  (loop limit = 5)

        // loop:
        mem[14] = 32'h016c682a;  // slt $t5, $t3, $t4 (i < 5?)
        mem[15] = 32'h11a00005;  // beq $t5, $0, exit
        mem[16] = 32'h8d0d0000;  // lw $t6, 0($t0)    (load array[i])
        mem[17] = 32'h014d5020;  // add $t2, $t2, $t6 (sum += array[i])
        mem[18] = 32'h00284020;  // add $t0, $t0, 1 (addr+=1)
        mem[19] = 32'h002b5820;  // add $t3, $t3, 1 (i=i+1)
        mem[20] = 32'h0800000e;  // j loop

        // exit:
        mem[21] = 32'hac0a0100;  // sw $t2, 0x100($0) (store sum)
    

        // Fill rest with 0
        for (integer i = 22; i < 64; i++) begin
            mem[i] = 32'h00000000;
        end
    end
endmodule