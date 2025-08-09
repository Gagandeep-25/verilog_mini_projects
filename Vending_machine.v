module vending_machine (
    input clk,
    input rst,
    input coin_1,    // ₹1 coin
    input coin_2,    // ₹2 coin
    output reg dispense,
    output reg return_change
);

    parameter S0 = 3'd0;
    parameter S1 = 3'd1;
    parameter S2 = 3'd2;
    parameter S3 = 3'd3;
    parameter S4 = 3'd4;
    parameter S5 = 3'd5;

    reg [2:0] state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end


    always @(*) begin
        case (state)
            S0: if (coin_1) next_state = S1;
                else if (coin_2) next_state = S2;
                else next_state = S0;
            S1: if (coin_1) next_state = S2;
                else if (coin_2) next_state = S3;
                else next_state = S1;
            S2: if (coin_1) next_state = S3;
                else if (coin_2) next_state = S4;
                else next_state = S2;
            S3: if (coin_1) next_state = S4;
                else if (coin_2) next_state = S5;
                else next_state = S3;
            S4: if (coin_1 || coin_2) next_state = S5;
                else next_state = S4;
            S5: next_state = S0;
            default: next_state = S0;
        endcase
    end

    always @(*) begin
        dispense = (state == S5);
        return_change = (state == S5) && coin_2 && (state == S4);  // Only case where overpay occurs
    end

endmodule





`timescale 1ns / 1ps
module vending_machine_tb;

    reg clk, rst;
    reg coin_1, coin_2;
    wire dispense, return_change;
    vending_machine dut (
        .clk(clk),
        .rst(rst),
        .coin_1(coin_1),
        .coin_2(coin_2),
        .dispense(dispense),
        .return_change(return_change)
    );
    always #5 clk = ~clk;

    initial begin
        $display("Starting Vending Machine FSM Simulation");
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_tb);
        clk = 0;
        rst = 1;
        coin_1 = 0;
        coin_2 = 0;

        #10 rst = 0;

        #10 coin_1 = 1; #10 coin_1 = 0;
        #10 coin_2 = 1; #10 coin_2 = 0;
        #10 coin_2 = 1; #10 coin_2 = 0;

        #20;

        #10 coin_2 = 1; #10 coin_2 = 0;
        #10 coin_2 = 1; #10 coin_2 = 0;
        #10 coin_2 = 1; #10 coin_2 = 0;

        #20;

        $finish;
    end

endmodule
