`timescale 1ns / 1ps

module tb_mealy ();

    reg  clk;
    reg  reset;
    reg  mealy_in;
    wire mealy_out;

    fsm_mealy dut (
        .clk      (clk),
        .reset    (reset),
        .mealy_in (mealy_in),
        .mealy_out(mealy_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        mealy_in = 0;
        #10;
        reset = 0;

        // 0101
        @ (posedge clk) mealy_in = 1'b0;
        @ (posedge clk) mealy_in = 1'b1;
        @ (posedge clk) mealy_in = 1'b0;
        @ (posedge clk) mealy_in = 1'b1;
        #10;

        // 0110
        @ (posedge clk) mealy_in = 1'b0;
        @ (posedge clk) mealy_in = 1'b1;
        @ (posedge clk) mealy_in = 1'b1;
        @ (posedge clk) mealy_in = 1'b0;
        #10;

        // 0100
        @ (posedge clk) mealy_in = 1'b0;
        @ (posedge clk) mealy_in = 1'b1;
        @ (posedge clk) mealy_in = 1'b0;
        @ (posedge clk) mealy_in = 1'b0;
        #10;


        $finish;
    end

endmodule
