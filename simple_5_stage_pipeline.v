`define ADD 4'b0000
`define SUB 4'b0001
`define MUL 4'b0010
`define DIV 4'b0011

module simple_5stage_pipeline(
    input wire clk,
    input wire rst
);
    // Instruction Memory 
    reg [11:0] instr_mem [0:15];
    initial begin
        // Format: {opcode, rs, rt}
        instr_mem[0] = {`ADD, 4'd1, 4'd2}; // R1 = R1 + R2
        instr_mem[1] = {`SUB, 4'd3, 4'd1}; // R3 = R3 - R1
        instr_mem[2] = {`MUL, 4'd4, 4'd3}; // R4 = R4 * R3
        instr_mem[3] = {`DIV, 4'd5, 4'd4}; // R5 = R5 / R4
    end

    // Register File

    reg [7:0] regfile [0:15];
    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1)
            regfile[i] = i; // preload R0=0, R1=1, R2=2, ...
    end

    // Pipeline Registers
    reg [11:0] IF_ID;      // Instruction
    reg [3:0]  ID_EX_rs, ID_EX_rt, ID_EX_opcode;
    reg [7:0]  ID_EX_val_rs, ID_EX_val_rt;
    reg [3:0]  EX_MEM_rd;
    reg [7:0]  EX_MEM_result;
    reg [3:0]  MEM_WB_rd;
    reg [7:0]  MEM_WB_result;

    // PC
    reg [3:0] PC;


    // ALU
    reg [7:0] alu_out;
    always @(*) begin
        case (ID_EX_opcode)
            `ADD: alu_out = ID_EX_val_rs + ID_EX_val_rt;
            `SUB: alu_out = ID_EX_val_rs - ID_EX_val_rt;
            `MUL: alu_out = ID_EX_val_rs * ID_EX_val_rt;
            `DIV: alu_out = (ID_EX_val_rt != 0) ? ID_EX_val_rs / ID_EX_val_rt : 8'hFF; // return FF if divide by zero
            default: alu_out = 8'h00;
        endcase
    end

    // Main Pipeline Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 0;
            IF_ID <= 12'b0;
            ID_EX_opcode <= 4'b0;
            ID_EX_rs <= 4'b0;
            ID_EX_rt <= 4'b0;
            ID_EX_val_rs <= 8'b0;
            ID_EX_val_rt <= 8'b0;
            EX_MEM_result <= 8'b0;
            EX_MEM_rd <= 4'b0;
            MEM_WB_result <= 8'b0;
            MEM_WB_rd <= 4'b0;
        end else begin
            // WB Stage
            regfile[MEM_WB_rd] <= MEM_WB_result;

            // MEM Stage (no memory access, just pass data)
            MEM_WB_result <= EX_MEM_result;
            MEM_WB_rd <= EX_MEM_rd;

            // EX Stage
            EX_MEM_result <= alu_out;
            EX_MEM_rd <= ID_EX_rs; // store result in rs

            // ID Stage
            ID_EX_opcode <= IF_ID[11:8];
            ID_EX_rs <= IF_ID[7:4];
            ID_EX_rt <= IF_ID[3:0];
            ID_EX_val_rs <= regfile[IF_ID[7:4]];
            ID_EX_val_rt <= regfile[IF_ID[3:0]];

            // IF Stage
            IF_ID <= instr_mem[PC];
            PC <= PC + 1;
        end
    end

endmodule
