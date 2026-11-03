`timescale 1ns / 1ps

module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [8:0] y
);
    // combinational logic
    always_comb begin
        y = a + b;
    end

endmodule
