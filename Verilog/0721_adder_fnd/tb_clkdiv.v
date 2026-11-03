`timescale 1ns / 1ps

module tb_clkdiv ();
    reg clk, reset;
    wire o_1khz;
    
    clk_div dut (
        .clk   (clk),
        .reset (reset),
        .o_1khz(o_1khz)
    );

    always #5 clk = ~clk;

    // 1kHz
    // initial begin
    //     clk = 0;
    //     reset = 1;
    //     #10;
    //     reset = 0;
    //     #(500_000 * 3);
    //     $stop;
    // end

    // //2
    // initial begin
    //     clk = 0;
    //     reset = 1;
    //     #10;
    //     reset = 0;
    //     #200;
    //     $stop;
    // end

    // 4
    // initial begin
    //     clk = 0;
    //     reset = 1;
    //     #10;
    //     reset = 0;
    //     #(20 * 3);
    //     $stop;
    // end

    // 6
    // initial begin
    //     clk = 0;
    //     reset = 1;
    //     #10;
    //     reset = 0;
    //     #(30 * 6);
    //     $stop;
    // end

    // 12
    initial begin
        clk = 0;
        reset = 1;
        #10;
        reset = 0;
        #(60 * 4);
        $stop;
    end

endmodule
