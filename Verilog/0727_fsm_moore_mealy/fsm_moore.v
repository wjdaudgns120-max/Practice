`timescale 1ns / 1ps

module fsm_moore(
    input clk,
    input reset,
    input moore_in,
    output moore_out
    );

    reg [2:0] c_state, n_state;

    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100;

    assign moore_out = (c_state == S4) ? 1 : 0;
                    
    always @(c_state or moore_in) begin
        n_state = c_state;
        case (c_state)
            S0:
            if (moore_in == 1'b0) n_state = S1;
            else n_state = c_state;
            S1:
            if (moore_in == 1'b1) n_state = S2;
            else n_state = c_state;
            S2:
            if (moore_in == 1'b0) n_state = S3;
            else n_state = S0;
            S3: 
            if (moore_in == 1'b1) n_state = S4;
            else n_state = S1;
            S4:
            if (moore_in == 1'b1) n_state = S0;
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
