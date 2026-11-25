`timescale 1ns / 1ps

module uart #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,
    // TX internal signal
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output wire       tx_done,
    // TX external siganl
    output wire       tx,
    // RX internal siganl
    output wire [7:0] rx_data,
    output wire       rx_done,
    // RX external signal
    input  wire       rx
);

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_tx (
        .clk     (clk),
        .rst_n   (rst_n),
        .tx_start(tx_start),
        .tx_data (tx_data),
        .tx_busy (tx_busy),
        .tx_done (tx_done),
        .tx      (tx)
    );

    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx (
        .clk    (clk),
        .rst_n  (rst_n),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx     (rx)
    );

endmodule

module uart_tx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,
    // internal signal
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output wire       tx_done,
    // external siganl
    output wire       tx
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam S_IDLE = 2'd0, S_START = 2'd1, S_DATA = 2'd2, S_STOP = 2'd3;

    reg tx_r, tx_busy_r, tx_done_r;
    reg [1:0] state;
    reg [$clog2(CLKS_PER_BIT):0] clk_cnt;
    reg [2:0] bit_idx;
    reg [7:0] tx_data_r;

    assign tx      = tx_r;
    assign tx_busy = tx_busy_r;
    assign tx_done = tx_done_r;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            clk_cnt   <= 0;
            bit_idx   <= 0;
            tx_data_r <= 0;
            tx_busy_r <= 1'b0;
            tx_done_r <= 1'b0;
            tx_r      <= 1'b1;
        end else begin
            case (state)
                S_IDLE: begin
                    tx_r <= 1'b1;
                    tx_busy_r <= 1'b0;
                    tx_done_r <= 1'b0;
                    tx_data_r <= 0;
                    if (tx_start) begin
                        state     <= S_START;
                        tx_data_r <= tx_data;
                        tx_busy_r <= 1'b1;
                        clk_cnt   <= 0;
                    end
                end
                S_START: begin
                    tx_r <= 1'b0;
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        bit_idx <= 0;
                        state   <= S_DATA;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                S_DATA: begin
                    tx_r <= tx_data_r[bit_idx];
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        if (bit_idx == 3'd7) begin
                            state <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                // S_D1: begin
                //     tx_r <= tx_data_r[1];
                //     if (clk_cnt == CLKS_PER_BIT - 1) begin
                //         clk_cnt <= 0;
                //         //bit_idx <= 0;
                //         state   <= S_D2;
                //     end else begin
                //         clk_cnt <= clk_cnt + 1;
                //     end
                // end
                // S_D2: begin
                //     tx_r <= tx_data_r[2];
                //     if (clk_cnt == CLKS_PER_BIT - 1) begin
                //         clk_cnt <= 0;
                //         //bit_idx <= 0;
                //         state   <= S_D3;
                //     end else begin
                //         clk_cnt <= clk_cnt + 1;
                //     end
                // end
                // S_D3: begin
                //     tx_r <= tx_data_r[3];
                //     if (clk_cnt == CLKS_PER_BIT - 1) begin
                //         clk_cnt <= 0;
                //         //bit_idx <= 0;
                //         state   <= S_D4;
                //     end else begin
                //         clk_cnt <= clk_cnt + 1;
                //     end
                // end
                // S_D4: begin
                //     tx_r <= tx_data_r[4];
                //     if (clk_cnt == CLKS_PER_BIT - 1) begin
                //         clk_cnt <= 0;
                //         //bit_idx <= 0;
                //         state   <= S_D5;
                //     end else begin
                //         clk_cnt <= clk_cnt + 1;
                //     end
                // end
                // S_D5: begin
                //     tx_r <= tx_data_r[5];
                //     if (clk_cnt == CLKS_PER_BIT - 1) begin
                //         clk_cnt <= 0;
                //         //bit_idx <= 0;
                //         state   <= S_D6;
                //     end else begin
                //         clk_cnt <= clk_cnt + 1;
                //     end
                // end
                // S_D6: begin
                //     tx_r <= tx_data_r[6];
                //     if (clk_cnt == CLKS_PER_BIT - 1) begin
                //         clk_cnt <= 0;
                //         //bit_idx <= 0;
                //         state   <= S_D7;
                //     end else begin
                //         clk_cnt <= clk_cnt + 1;
                //     end
                // end
                // S_D7: begin
                //     tx_r <= tx_data_r[7];
                //     if (clk_cnt == CLKS_PER_BIT - 1) begin
                //         clk_cnt <= 0;
                //         //bit_idx <= 0;
                //         state   <= S_STOP;
                //     end else begin
                //         clk_cnt <= clk_cnt + 1;
                //     end
                // end
                S_STOP: begin
                    tx_r <= 1'b1;
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt   <= 0;
                        bit_idx   <= 0;
                        tx_done_r <= 1'b1;
                        state     <= S_IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule

module uart_rx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,
    // internal siganl
    output wire [7:0] rx_data,
    output wire       rx_done,
    // external signal
    input  wire       rx
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT = CLKS_PER_BIT / 2;

    localparam S_IDLE = 2'd0, S_START = 2'd1, S_DATA = 2'd2, S_STOP = 2'd3;

    reg [                   1:0] state;
    reg [$clog2(CLKS_PER_BIT):0] clk_cnt;
    reg [                   2:0] bit_idx;
    reg [                   7:0] rx_data_r;
    reg                          rx_done_r;

    assign rx_data = rx_data_r;
    assign rx_done = rx_done_r;

    // syncronize
    reg rx_sync0, rx_sync;
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            // IDLE state -> 1 value
            rx_sync0 <= 1'b1;
            rx_sync  <= 1'b1;
        end else begin
            rx_sync0 <= rx;
            rx_sync  <= rx_sync0;
        end
    end

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            clk_cnt   <= 0;
            bit_idx   <= 0;
            rx_data_r <= 0;
            rx_done_r <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    rx_done_r <= 1'b0;
                    if (!rx_sync) begin
                        state   <= S_START;
                        clk_cnt <= 3'd0;
                        bit_idx <= 3'd0;
                    end
                end
                S_START: begin
                    if (clk_cnt == (HALF_BIT - 1)) begin
                        clk_cnt <= 0;
                        state   <= S_DATA;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                S_DATA: begin
                    if (clk_cnt == (CLKS_PER_BIT - 1)) begin
                        clk_cnt <= 0;
                        rx_data_r[bit_idx] <= rx_sync;
                        if (bit_idx == 3'd7) begin
                            bit_idx <= 3'd0;
                            state   <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                S_STOP: begin
                    if (clk_cnt == (CLKS_PER_BIT - 1)) begin
                        clk_cnt   <= 0;
                        rx_done_r <= 1'b1;
                        state     <= S_IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule

//Editor: Quick Suggestions

