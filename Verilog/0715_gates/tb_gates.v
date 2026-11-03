`timescale 1ns / 1ps

module tb_gates(); // simulation top module environment : Modules for configuring simulation environments


    reg a, b; //register, 1bit variable(can exchange values)
    wire y0, y1, y2, y3, y4, y5, y6;

    gates dut( // instance, another module substantiate in tb_gates.
        .a(a),
        .b(b),
        .y0(y0),
        .y1(y1),
        .y2(y2),
        .y3(y3),
        .y4(y4),
        .y5(y5),
        .y6(y6)
    );

    initial begin // simulation reset
        a = 0;
        b = 0;
        #10; //10ns delay
        a = 0;
        b = 1;
        #10;
        a = 1;
        b = 0;
        #10;
        a = 1;
        b = 1;
        $stop;
    end


endmodule
