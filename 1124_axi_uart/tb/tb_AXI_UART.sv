`timescale 1ns / 1ps

module tb_AXI_UART ();

    parameter integer C_S00_AXI_DATA_WIDTH = 32;
    parameter integer C_S00_AXI_ADDR_WIDTH = 4;

    logic                                  s00_axi_aclk;
    logic                                  s00_axi_aresetn;
    logic [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
    logic [                         2 : 0] s00_axi_awprot;
    logic                                  s00_axi_awvalid;
    logic                                  s00_axi_awready;
    logic [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
    logic [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
    logic                                  s00_axi_wvalid;
    logic                                  s00_axi_wready;
    logic [                         1 : 0] s00_axi_bresp;
    logic                                  s00_axi_bvalid;
    logic                                  s00_axi_bready;
    logic [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
    logic [                         2 : 0] s00_axi_arprot;
    logic                                  s00_axi_arvalid;
    logic                                  s00_axi_arready;
    logic [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
    logic [                         1 : 0] s00_axi_rresp;
    logic                                  s00_axi_rvalid;
    logic                                  s00_axi_rready;

    logic clk, reset_n;
    logic intr;
    logic loop;

    assign s00_axi_aclk = clk;
    assign s00_axi_aresetn = reset_n;

    initial clk = 0;
    always #5 clk = ~clk;

`ifdef FSDB
    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_AXI_UART);
    end
`endif

    uart_v1_0 dut (
        .*,
        .tx(loop),
        .rx(loop)
    );

    task AXI_WriteData(logic [31:0] addr, logic [31:0] data);
        @(posedge clk);
        s00_axi_awaddr  <= addr;
        s00_axi_awvalid <= 1'b1;
        s00_axi_wdata   <= data;
        s00_axi_wstrb   <= 4'b1111;
        s00_axi_wvalid  <= 1'b1;
        s00_axi_bready  <= 1'b1;
        @(posedge clk);
        wait (s00_axi_awready & s00_axi_wready);
        @(posedge clk);
        s00_axi_awvalid <= 1'b0;
        s00_axi_wvalid  <= 1'b0;
        @(posedge clk);
        wait (s00_axi_bvalid);
        @(posedge clk);
        s00_axi_bready <= 1'b0;
        @(posedge clk);
    endtask

    task AXI_ReadData(input logic [31:0] addr, output logic [31:0] rdata);
        @(posedge clk);
        s00_axi_araddr  <= addr;
        s00_axi_arvalid <= 1'b1;
        //s00_axi_rvalid  <= 1'b1;
        s00_axi_rready  <= 1'b1;
        @(posedge clk);
        wait (s00_axi_arready);
        @(posedge clk);
        s00_axi_arvalid <= 1'b0;
        wait (s00_axi_rvalid);
        @(posedge clk);
        s00_axi_rready <= 1'b0;
        rdata          <= s00_axi_rdata;
        @(posedge clk);
    endtask

    localparam SR_ADDR  = 32'h0000_0000;
    localparam TDR_ADDR = 32'h0000_0004;
    localparam RDR_ADDR = 32'h0000_0008;
    localparam CR_ADDR  = 32'h0000_000C;

    logic [31:0] sr_r, tdr_r, rdr_r, cr_r;
    initial begin
        reset_n = 0;
        repeat (5) @(posedge clk);
        reset_n = 1;
        repeat (3) @(posedge clk);

    do begin
        AXI_ReadData(SR_ADDR, sr_r);
    end while (sr_r & (1<<0));
        tdr_r = 32'haa;
        AXI_WriteData(TDR_ADDR, tdr_r);
    do begin
        AXI_ReadData(SR_ADDR, sr_r);
    end while (!(sr_r & (1 << 1)));
    AXI_ReadData(RDR_ADDR, rdr_r);
    if(tdr_r == rdr_r) begin
        $display("PASS! tdr = 0x%x, rdr = 0x%x", tdr_r, rdr_r);
    end else begin
        $display("FAIL! tdr = 0x%x, rdr = 0x%x", tdr_r, rdr_r);
    end

    do begin
        AXI_ReadData(SR_ADDR, sr_r);
    end while (sr_r & (1<<0));
        tdr_r = 32'h55;
        AXI_WriteData(TDR_ADDR, tdr_r);
    do begin
        AXI_ReadData(SR_ADDR, sr_r);
    end while (!(sr_r & (1 << 1)));
    AXI_ReadData(RDR_ADDR, rdr_r);
    if(tdr_r == rdr_r) begin
        $display("PASS! tdr = 0x%x, rdr = 0x%x", tdr_r, rdr_r);
    end else begin
        $display("FAIL! tdr = 0x%x, rdr = 0x%x", tdr_r, rdr_r);
    end

    cr_r = 32'h01; // rx ie bit set
    AXI_WriteData(CR_ADDR, cr_r);
    do begin
        AXI_ReadData(SR_ADDR, sr_r);
    end while (sr_r & (1<<0));
        tdr_r = 32'hf0;
        AXI_WriteData(TDR_ADDR, tdr_r);
    do begin
        AXI_ReadData(SR_ADDR, sr_r);
    end while (!(sr_r & (1 << 1)));
    AXI_ReadData(RDR_ADDR, rdr_r);
    if(tdr_r == rdr_r) begin
        $display("PASS! tdr = 0x%x, rdr = 0x%x", tdr_r, rdr_r);
    end else begin
        $display("FAIL! tdr = 0x%x, rdr = 0x%x", tdr_r, rdr_r);
    end

    cr_r = 32'h00; // rx ie bit clear
    AXI_WriteData(CR_ADDR, cr_r);
    do begin
        AXI_ReadData(SR_ADDR, sr_r);
    end while (sr_r & (1<<0));
        tdr_r = 32'hf0;
        AXI_WriteData(TDR_ADDR, tdr_r);
    do begin
        AXI_ReadData(SR_ADDR, sr_r);
    end while (!(sr_r & (1 << 1)));
    AXI_ReadData(RDR_ADDR, rdr_r);
    if(tdr_r == rdr_r) begin
        $display("PASS! tdr = 0x%x, rdr = 0x%x", tdr_r, rdr_r);
    end else begin
        $display("FAIL! tdr = 0x%x, rdr = 0x%x", tdr_r, rdr_r);
    end

        repeat (5) @(posedge clk);
        $finish;
    end

endmodule

