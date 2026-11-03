`timescale 1ns / 1ps

module tb_debouncer ();

    reg  clk;
    reg  reset;
    reg  i_btn;
    wire o_btn;

    btn_debouncer dut (
        .clk  (clk),
        .reset(reset),
        .i_btn(i_btn),
        .o_btn(o_btn)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        i_btn = 0;
        #15;
        reset = 0;

        i_btn = 1;
        #15000;
        i_btn = 0;
        #100;

        i_btn = 1;
        #15000;
        i_btn = 0;
        #15000;

        $finish;



    end

endmodule
