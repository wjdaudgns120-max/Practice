`timescale 1ns / 1ps



module tb_10000 ();

    reg clk;
    reg reset;
    reg btn_L;
    reg btn_R;
    reg btn_UP;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    parameter TEST_DELAY = 25_000_000;

    top_counter_10000 dut(
    .clk(clk),
    .reset(reset),
    .btn_L(btn_L),    // run_stop
    .btn_R(btn_R),    // clear
    .btn_UP(btn_UP),   // mode
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        {btn_R, btn_L, btn_UP} = 3'b000;
        #10;
        reset = 0;

        // sinario btn_L
        // // 1
        {btn_R, btn_L, btn_UP} = 3'b000;
        #(TEST_DELAY);

        // 2
        {btn_R, btn_L, btn_UP} = 3'b010;
        #10;

        // 3
        {btn_R, btn_L, btn_UP} = 3'b000;
        #(TEST_DELAY);

        // sinario btn_R

        {btn_R, btn_L, btn_UP} = 3'b010;
        #10;
        
        {btn_R, btn_L, btn_UP} = 3'b100;
        #10;
        {btn_R, btn_L, btn_UP} = 3'b000;
        #(TEST_DELAY);
        

        // 4
        // sw = 3'b110;
        // #(TEST_DELAY);

        // // 5
        // sw = 3'b100;
        // #(TEST_DELAY);

        // // 6
        // sw = 3'b101;
        // #(TEST_DELAY);

        // // 7
        // sw = 3'b000;
        // #(TEST_DELAY);

        $stop;
    end

endmodule
