`timescale 1ns / 1ps

module tb_ram ();

    reg        clk;
    reg        reset;
    reg        push;
    reg        pop;
    reg  [7:0] wdata;
    wire [7:0] rdata;
    wire       full;
    wire       empty;

    fifo dut (
        .clk  (clk),
        .reset(reset),
        .push (push),
        .pop  (pop),
        .wdata(wdata),  // push data
        .rdata(rdata),  // pop data
        .full (full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        push = 1'b0;
        pop = 1'b0;
        wdata = 0;
        #10;

        reset = 0;
        #10;

        push = 1'b1;
        wdata = 8'h0a;
        #10;

        push = 1'b1;
        wdata = 8'h0b;
        #10;

        push = 1'b1;
        wdata = 8'h0c;
        #10;

        push = 1'b1;
        wdata = 8'h0d;
        #10;

        push = 1'b1;
        wdata = 8'h0e;
        #10;

        $stop;
    end

endmodule
