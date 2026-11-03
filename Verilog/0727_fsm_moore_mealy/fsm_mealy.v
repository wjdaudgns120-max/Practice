`timescale 1ns / 1ps

module fsm_mealy (
    input  clk,
    input  reset,
    input  mealy_in,
    output mealy_out
);

    reg [1:0] c_state, n_state;

    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;

    assign mealy_out = (c_state == S3 && mealy_in == 1'b1) ? 1 : 0;

    always @(c_state or mealy_in) begin
        n_state = c_state;
        case (c_state)
            S0:
            if (mealy_in == 1'b0) n_state = S1;
            else n_state = c_state;
            S1:
            if (mealy_in == 1'b1) n_state = S2;
            else n_state = c_state;
            S2:
            if (mealy_in == 1'b0) n_state = S3;
            else n_state = S0;
            S3: 
            if (mealy_in == 1'b1) n_state = S0;
            else n_state = S1;
            default: n_state = S0;
        endcase
    end

    always @ (posedge clk, posedge reset)begin
        if(reset) begin
            c_state <= S0;
        end else begin
            c_state <= n_state;
        end
    end
endmodule
