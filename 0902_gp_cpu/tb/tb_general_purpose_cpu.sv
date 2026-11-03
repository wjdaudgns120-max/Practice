module tb_general_purpose_cpu();

	logic clk = 0, rst_n = 0;
	logic [7:0] out;

	always #5 clk = ~clk;

	general_purpose_cpu dut(
		.clk(clk),
		.rst_n(rst_n),
		.out(out)
	);

	initial begin
		$fsdbDumpfile("wave.fsdb");
		$fsdbDumpvars(0, tb_general_purpose_cpu);
	end

	initial begin
		#10;
		rst_n = 1;

		#500;
		$finish;
	end

endmodule
