/////////////////////////////////////////////////////////////////////////////////////////////// DESIGN ////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module alu_8bit(
    input [7:0] a,
    input [7:0] b,
    input [3:0] opcode,
    input cin,
    output reg [7:0] result,   // corrected from 'out'
    output reg cout,
    output reg zero,
    output reg sign,
    output reg overflow
);

always @(*) begin 

    // Default assignments
    result = 8'b0;
    cout = 0;
    zero = 0;
    sign = 0;
    overflow = 0;

    case(opcode)
        4'b0000: {cout,result} = a + b;            // ADD without carry 
        4'b0001: {cout,result} = a - b;            // SUB half
        4'b0010: {cout,result} = a + b + cin;      // ADD with carry
        4'b0011: {cout,result} = a - b - cin;      // SUB with borrow
        4'b0100: result = a + 1;                   // INC
        4'b0101: result = a - 1;                   // DEC
        4'b0110: result = ~a + 1;                  // 2's complement

        4'b0111: result = a & b;                   // AND
        4'b1000: result = a | b;                   // OR
        4'b1001: result = a ^ b;                   // XOR
        4'b1010: result = ~(a & b);                // NAND
        4'b1011: result = ~(a | b);                // NOR
        4'b1100: result = ~(a ^ b);                // XNOR
        4'b1101: result = ~a;                      // NOT

        4'b1110: result = a << 1;                  // SHL
        4'b1111: result = a >> 1;                  // SHR

        default: result = 8'b0;
    endcase

    // Flags
    zero = (result == 8'b0);
    sign = result[7];

    if(opcode == 4'b0000 || opcode == 4'b0001 || opcode == 4'b0010 || opcode == 4'b0011) begin
        overflow = ((a[7] ~^ b[7]) & (a[7] ^ result[7])); // Signed overflow
    end else begin
        overflow = 0;
    end

end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////// TESTBENCH (VERILOG) ////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module tb_alu_8bit;

    // Testbench signals
    reg [7:0] a, b;
    reg [3:0] opcode;
    reg cin;
    wire [7:0] out;
    wire cout, zero, sign, overflow;

    // Instantiate the ALU
    alu_8bit uut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .cin(cin),
        .result(out),
        .cout(cout),
        .zero(zero),
        .sign(sign),
        .overflow(overflow)
    );

    // Initialize simulation and dump waves for EPWave
    initial begin
        $dumpfile("alu_8bit_tb.vcd");  // VCD file for waveform
        $dumpvars(0, tb_alu_8bit);     // Dump all variables of this module

        // Initialize inputs
        a = 0; b = 0; opcode = 0; cin = 0;

        // Test ADD
        #10 a = 8'd50; b = 8'd25; opcode = 4'b0000; cin = 0;
        #10 $display("ADD: %d + %d = %d, cout=%b, zero=%b, sign=%b, overflow=%b", a, b, out, cout, zero, sign, overflow);

        // Test SUB
        #10 a = 8'd50; b = 8'd100; opcode = 4'b0001;
        #10 $display("SUB: %d - %d = %d, cout=%b, zero=%b, sign=%b, overflow=%b", a, b, out, cout, zero, sign, overflow);

        // Test ADC
        #10 a = 8'd200; b = 8'd100; opcode = 4'b0010; cin = 1;
        #10 $display("ADC: %d + %d + %b = %d, cout=%b, zero=%b, sign=%b, overflow=%b", a, b, cin, out, cout, zero, sign, overflow);

        // Test SBC
        #10 a = 8'd50; b = 8'd25; opcode = 4'b0011; cin = 1;
        #10 $display("SBC: %d - %d - %b = %d, cout=%b, zero=%b, sign=%b, overflow=%b", a, b, cin, out, cout, zero, sign, overflow);

        // Test AND
        #10 a = 8'b10101010; b = 8'b11001100; opcode = 4'b0111;
        #10 $display("AND: %b & %b = %b", a, b, out);

        // Test OR
        #10 opcode = 4'b1000;
        #10 $display("OR: %b | %b = %b", a, b, out);

        // Test XOR
        #10 opcode = 4'b1001;
        #10 $display("XOR: %b ^ %b = %b", a, b, out);

        // Test NOT
        #10 opcode = 4'b1101;
        #10 $display("NOT: ~%b = %b", a, out);

        // Test SHL
        #10 opcode = 4'b1110;
        #10 $display("SHL: %b << 1 = %b", a, out);

        // Test SHR
        #10 opcode = 4'b1111;
        #10 $display("SHR: %b >> 1 = %b", a, out);

        #10 $finish;
    end

endmodule
