`timescale 1ns / 1ps

module bpsk(
    //2路系统时钟及一路复位信号
    input gclk1,
    input gclk2,
    input rst,
	 
	 input idata,
	 output iready,
	 input ivalid,
	 output ext9,  //解调输出同相支路数据
	 output ext11,  //解调输出正交支路数据
	 output bitsync,
	 //DA通道
    output da2_clk,       
    output [7:0] da2_out, //滤波后输出的信号
	 
	 //1路AD通道
    output ad_clk,        //AD采样时钟:2MHz
    input [7:0] ad_din
    );


	wire clk_da2_50m;
	wire clk_32m    ;
	wire clk_8m     ;

   assign da2_clk = clk_da2_50m;
	assign ad_clk  = clk_8m;


   clk_produce u1 (
     .rst(rst), 
     .gclk1(gclk1), 
     .gclk2(gclk2), 
     .clk_da2_50m(clk_da2_50m), 
     .clk_32m(clk_32m), 
     .clk_8m(clk_8m));
   
	tstdata_produce u2(
		.rst(rst),
		.iready(iready),
		.idata(idata),
		.ivalid(ivalid),
		.clk(clk_da2_50m), 
      .da_data(da2_out));
	//wire bitsync;
	PolarCostas u3(
		 .rst(rst),
		 .clk(clk_8m),
		 .clk4(clk_32m) ,
		 .din(ad_din),
		 .bitsync(bitsync),
		 .dout({ext9,ext11}));
		 
endmodule
