`timescale 1ns / 1ps

module ram_ip (
    input        clk,
    input  [9:0] addr,
    input  [7:0] wdata,
    input        wr,
    output reg [7:0] rdata
);

    reg [7:0] ram[0:1023]; // retrendian

    always @ (posedge clk)begin
        if(wr) begin
            ram[addr] <= wdata;
        end else begin
            rdata <= ram[addr];
        end
    end

    // CL output
    // assign rdata = (!wr) ? ram[addr] : 8'hz;
    // assign rdata = ram[addr]; // without wr signal


endmodule
