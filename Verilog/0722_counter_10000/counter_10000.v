`timescale 1ns / 1ps

module top_counter_10000 (
    input        clk,
    input        reset,
    input        btn_L,    // run_stop
    input        btn_R,    // clear
    input        btn_U,    // mode
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [13:0] w_count;
    wire w_reset;
    wire w_run_stop, w_clear, w_mode;
    wire w_bd_runstop, w_bd_clear, w_bd_mode;

    assign w_reset = reset | w_clear;

    btn_debouncer U_BD_RUNSTOP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_L),
        .o_btn(w_bd_runstop)
    );

    btn_debouncer U_BD_CLEAR (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_R),
        .o_btn(w_bd_clear)
    );

    btn_debouncer U_BD_MODE (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_U),
        .o_btn(w_bd_mode)
    );

    control_unit U_CONTROL_UNIT (
        .clk       (clk),
        .reset     (reset),
        .i_run_stop(w_bd_runstop),
        .i_clear   (w_bd_clear),
        .i_mode    (w_bd_mode),
        .o_run_stop(w_run_stop),
        .o_clear   (w_clear),
        .o_mode    (w_mode)
    );

    datapath_10000 U_DATA_PATH (
        .clk     (clk),
        .reset   (w_reset),
        .mode    (w_mode),
        .run_stop(w_run_stop),
        .counter (w_count)
    );

    fnd_controller U_FND_CONTROLLER (
        .clk     (clk),
        .reset   (w_reset),
        .fnd_in  (w_count),
        .fnd_com (fnd_com),
        .fnd_data(fnd_data)
    );


endmodule

module datapath_10000 (
    input         clk,
    input         reset,
    input         mode,
    input         run_stop,
    output [13:0] counter
);

    wire w_tick;

    counter_10000 U_COUNTER_10000 (
        .clk     (clk),
        .reset   (reset),
        .i_tick  (w_tick),
        .c_sw    (mode),
        .c_sw_run(run_stop),
        .counter (counter)
    );


    tick_gen U_TICK_GEN (
        .clk  (clk),
        .reset(reset),
        .t_run(run_stop),
        .tick (w_tick)
    );


endmodule

module counter_10000 (
    input clk,
    input reset,
    input i_tick,
    input c_sw,
    input c_sw_run,
    output [13:0] counter
);

    reg [$clog2(10000)-1:0] tick_counter_reg;

    assign counter = tick_counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            tick_counter_reg <= 0;
        end else begin
            if (i_tick) begin
                if (c_sw_run == 1) begin
                    if (c_sw == 0) begin
                        if (tick_counter_reg == (10000 - 1)) begin
                            tick_counter_reg <= 0;
                        end else begin
                            tick_counter_reg <= tick_counter_reg + 1;
                        end
                    end else begin
                        if (tick_counter_reg == 0) begin
                            tick_counter_reg <= (10000 - 1);
                        end else begin
                            tick_counter_reg <= tick_counter_reg - 1;
                        end
                    end
                end else begin
                    tick_counter_reg <= tick_counter_reg;
                end
            end
        end
    end

endmodule

module tick_gen (
    input  clk,
    input  reset,
    input  t_run,
    output tick
);
    reg [$clog2(1_000_000)-1:0] counter_reg;
    reg tick_reg;

    assign tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg <= 0;
        end else begin
            if (t_run == 1) begin
                counter_reg <= counter_reg + 1;
                if (counter_reg == (1_000_000 - 1)) begin
                    counter_reg <= 0;
                    tick_reg <= 1'b1;
                end else begin
                    tick_reg <= 1'b0;
                end
            end
        end
    end


endmodule
