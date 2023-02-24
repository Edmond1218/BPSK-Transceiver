`timescale 1ns / 1ps

module bpsk_tb();

wire [7:0] ad_data;
reg gclk1, gclk2;
reg rst;
wire ext9, ext11, bitsync;
wire ad_clk, da2_clk;
reg idata, ivalid;
wire iready;

bpsk bpsk_inst(
	.gclk1(gclk1),
	.gclk2(gclk2),
	.rst(rst),
	.ext9(ext9),
	.ext11(ext11),
	.idata(idata),
	.ivalid(ivalid),
	.iready(iready),
	.bitsync(bitsync),
	.da2_clk(da2_clk),      
	.da2_out(ad_data),
	.ad_clk(ad_clk),
	.ad_din(ad_data)
	);

always #10 gclk1 <= !gclk1;
always #10 gclk2 <= !gclk2;

reg [9:0] data;

initial begin
	gclk1 <= 1'b0;ivalid <= 1'b0;idata <= 1'b0;
	rst <= 1'b1; data <= 10'b1101011001;
	#5;
	gclk2 <= 1'b0;
	#100;
	rst <= 1'b0;
	#1000;
	ivalid <= 1'b1;
	forever begin
		@(posedge gclk1);
		idata <= data[0];
		if(iready)
			data <= {data[8:0], data[9]};
	end
end

endmodule
