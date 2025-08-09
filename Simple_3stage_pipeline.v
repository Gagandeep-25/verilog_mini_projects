`define ADD 4'b0000
`define SUB 4'b0001
module simple_pipeline(
    input rst,
    input clk
    );
 reg [11:0] IF_ID;
 reg [11:0] ID_EX;
 
 reg [7:0] regfile[0:15];
 wire [3:0] opcode,op1,op2;
 
 assign opcode = ID_EX[11:8];
 assign op1 = ID_EX[7:4];
 assign op2 = ID_EX[3:0];
 
 reg [11:0] instruction_mem[0:7];
 reg [2:0] pc;
 reg [7:0] result;
 
 always @(posedge clk or posedge rst)begin
   if(rst)begin
    pc <= 0;
    IF_ID <= 0;
    ID_EX <= 0;
    result <= 0;
   end
   else begin
   IF_ID <= instruction_mem[pc];
   pc <= pc+1;
   
   ID_EX <= IF_ID;
   
   case(opcode)
    `ADD : result <= regfile[op1] + regfile[op2];
    `SUB : result <= regfile[op1] + regfile[op2];
    default : result <= 8'b00000000;
   endcase 
   end
 end    
endmodule









module simple_pipeline_tb();
    reg clk;
    reg rst;
    simple_pipeline uut(
        .clk(clk),
        .rst(rst)
    );
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
       
        uut.regfile[0] = 8'h00;
        uut.regfile[1] = 8'h01;
        uut.regfile[2] = 8'h02;
        uut.regfile[3] = 8'h03;
        uut.regfile[4] = 8'h04;
        uut.regfile[5] = 8'h05;
        uut.regfile[6] = 8'h06;
        uut.regfile[7] = 8'h07;
        uut.regfile[8] = 8'h08;
        uut.regfile[9] = 8'h09;
        uut.regfile[10] = 8'h0A;
        uut.regfile[11] = 8'h0B;
        uut.regfile[12] = 8'h0C;
        uut.regfile[13] = 8'h0D;
        uut.regfile[14] = 8'h0E;
        uut.regfile[15] = 8'h0F;
    end 
    initial begin
        
        uut.instruction_mem[0] = 12'h0102; // ADD r1, r2 (0 + 2 = 2)
        uut.instruction_mem[1] = 12'h1123; // SUB r2, r3 (2 - 3 = -1)
        uut.instruction_mem[2] = 12'h0234; // ADD r3, r4 (3 + 4 = 7)
        uut.instruction_mem[3] = 12'h1345; // SUB r4, r5 (4 - 5 = -1)
        uut.instruction_mem[4] = 12'h0456; // ADD r5, r6 (5 + 6 = 11)
        uut.instruction_mem[5] = 12'h1567; // SUB r6, r7 (6 - 7 = -1)
        uut.instruction_mem[6] = 12'h0678; // ADD r7, r8 (7 + 8 = 15)
        uut.instruction_mem[7] = 12'h1789; // SUB r8, r9 (8 - 9 = -1)   
        rst = 1;
        #20;
        rst = 0;
         #200;  
        $display("Test Results:");
        $display("Clock cycles executed: %0d", $time/10);
        $display("Final result: %h", uut.result); 
        if (uut.result === 8'hFF) begin 
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end    
        $finish;
    end
    always @(posedge clk) begin
        if (!rst) begin
            $display("[%0t] PC=%0d IF_ID=%h ID_EX=%h Result=%h", 
                    $time, uut.pc, uut.IF_ID, uut.ID_EX, uut.result);
        end
    end
endmodule
