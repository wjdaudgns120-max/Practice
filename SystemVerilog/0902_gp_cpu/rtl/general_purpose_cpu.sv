module general_purpose_cpu(
	input				clk,
	input 				rst_n,
	output logic [7:0]	out
);

	logic rf_srcsel, we, out_control, lt10;
	logic [1:0] wa, ra0, ra1;

	datapath U_DATAPATH(
		.*
	);

	control_unit U_CONTROL_UNIT(
		.*
	);

endmodule

module control_unit(
	input  logic		clk,
	input  logic 		rst_n,
	input  logic 		lt10,
	output logic 		rf_srcsel,
	output logic [1:0]	ra0,
	output logic [1:0] 	ra1,
	output logic [1:0] 	wa,
	output logic		we,
	output logic 		out_control
);

	typedef enum logic [2:0] { S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6} state_e;
	state_e c_state, n_state;

	assign rf_srcsel = (c_state == S0 || c_state == S1 || c_state == S4 || c_state == S5) ? 1 : 0;
	assign ra0 = (c_state == S3 || c_state == S4 | c_state == S5) ? 3 : 0;
	assign ra1 = (c_state == S4) ? 1 : (c_state == S5 || c_state == S6) ? 2 : 0;
	assign wa = (c_state == S0 || c_state == S4) ? 3 : (c_state == S1 || c_state == S5) ? 2 : (c_state == S2) ? 1 : 0;
	assign we = (c_state == S0 || c_state == S1 || c_state == S2 || c_state == S4 || c_state == S5) ? 1 : 0;
	assign out_control = (c_state == S6) ? 1 : 0;

	always_ff @(posedge clk) begin
		if(!rst_n)begin
			c_state <= S0;
		end else begin
			c_state <= n_state;
		end
	end

	always_comb begin
		n_state = c_state;
		case(c_state)
			S0: n_state = S1;
			S1: n_state = S2;
			S2: n_state = S3;
			S3: begin
				if(lt10) n_state = S4;
				else n_state = S6;
			end
			S4: n_state = S5;
			S5: n_state = S3;
			S6: n_state = S6;
		endcase
	end

endmodule

module datapath(
	input  logic		clk,
	input  logic 		rst_n,
	input  logic 		rf_srcsel,
	input  logic [1:0]	ra0,
	input  logic [1:0] 	ra1,
	input  logic [1:0] 	wa,
	input  logic		we,
	input  logic 		out_control,
	output logic		lt10,
	output logic [7:0]	out
);

	logic [7:0] alu_result, wd, rd0, rd1;
	assign out = (out_control) ? rd1 : 8'hz;
	
	mux_2x1 U_RF_SRCSEL(
		.sel(rf_srcsel),
		.in0(8'd1),
		.in1(alu_result),
		.mux_out(wd)
	);
	
	register U_REG(
		.clk(clk),
		.rst_n(rst_n),
		.we(we),
		.wa(wa),
		.ra0(ra0),
		.ra1(ra1),
		.wd(wd),
		.rd0(rd0),
		.rd1(rd1)
	);
	
	alu U_ALU(
		.a(rd0),
		.b(rd1),
		.alu_result(alu_result)
	);
	
	lt10 U_LT10(
		.in(rd0),
		.lt10(lt10)
	);

endmodule

module register(
	input  logic		clk,
	input  logic		rst_n,
	input  logic		we,
	input  logic [1:0]	wa,
	input  logic [1:0]	ra0,
	input  logic [1:0]	ra1,
	input  logic [7:0]	wd,
	output logic [7:0]	rd0,
	output logic [7:0]	rd1
);

	logic [7:0] reg_arr[0:3];

	assign rd0 = reg_arr[ra0];
	assign rd1 = reg_arr[ra1];

	always_ff @(posedge clk)begin
		if(!rst_n)begin
			reg_arr[0] <= 0;
			reg_arr[1] <= 0;
			reg_arr[2] <= 0;
			reg_arr[3] <= 0;
		end else begin
			if(we) reg_arr[wa] <= wd;
		end
	end

endmodule

module mux_2x1(
	input  logic sel,
	input  logic [7:0] in0,
	input  logic [7:0] in1,
	output logic [7:0] mux_out
);

	assign mux_out = (sel) ? in1 : in0;

endmodule

module alu(
	input  logic [7:0] a,
	input  logic [7:0] b,
	output logic [7:0] alu_result
);

	assign alu_result = a + b;

endmodule

module lt10(
	input logic [7:0]	in,
	output logic		lt10
);

	assign lt10 = (in<10);

endmodule
