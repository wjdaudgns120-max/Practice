`timescale 1ns / 1ps

module tb_moore ();

    reg  clk;
    reg  reset;
    reg  moore_in;
    wire moore_out;

    fsm_moore dut (
        .clk      (clk),
        .reset    (reset),
        .moore_in (moore_in),
        .moore_out(moore_out)
    );

    always #5 clk = ~clk;

    initial begin
        // 초기값 설정
        clk = 0;
        reset = 1;
        moore_in = 0;

        // 리셋 신호
        #15 reset = 0;

        // 입력 신호 패턴 (예시)
        #5 moore_in = 1;
        #30 moore_in = 0;
        #10 moore_in = 1;
        #20 moore_in = 0;
        #40 moore_in = 1;
        #10 moore_in = 0;
        #30 moore_in = 1;
        #40 moore_in = 0;
        #10 moore_in = 1;
        #10 moore_in = 0;
        #30 moore_in = 1;
        #20 moore_in = 0;
        // 시뮬레이션 종료
        #100 $finish;
    end

endmodule
