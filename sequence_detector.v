module sequence_detector (
    input clk,
    input rst,
    input in,
    output reg detected
);

    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;

    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            S0: next_state = (in == 1'b1) ? S1 : S0;
            S1: next_state = (in == 1'b0) ? S2 : S1;
            S2: next_state = (in == 1'b1) ? S3 : S0;
            S3: next_state = (in == 1'b1) ? S4 : S2;
            S4: next_state = (in == 1'b1) ? S1 : S2; // Overlapping detection
            default: next_state = S0;
        endcase
    end

    always @(*) begin
        if (current_state == S4)
            detected = 1'b1;
        else
            detected = 1'b0;
    end

endmodule








`timescale 1ns / 1ps
module tb_sequence_detector
    reg clk;
    reg rst;
    reg in;
    wire detected;
    sequence_detector uut (
        .clk(clk),
        .rst(rst),
        .in(in),
        .detected(detected)
    );
    always #5 clk = ~clk;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_sequence_detector);
        clk = 0;
        rst = 1;
        in = 0;
        #10 rst = 0;
        
        in = 1; #10;
        in = 0; #10;
        in = 1; #10;
        in = 1; #10; 

        in = 1; #10;
        in = 0; #10;
        in = 1; #10;
        in = 1; #10;

        $finish;
    end

endmodule
