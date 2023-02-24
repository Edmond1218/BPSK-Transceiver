//这是PhaseDetect.v文件的程序清单
module PhaseDetect (
	rst,clk,yi,yq,
	pd); 
	
	input		rst;   //复位信号，高电平有效
	input		clk;   //FPGA系统时钟：8MHz
	input	 signed [25:0]	yi;  //输入同相支路数据：8MHz
	input	 signed [25:0]	yq;  //输入正交支路数据：8MHz
	output signed [25:0]	pd;  //鉴相器输出数据
	
	reg signed [25:0] sygnyi,sygnyq;
	reg signed [26:0] pdt;
	
	initial begin
		sygnyi <= 26'd0;
		sygnyq <= 26'd0;
		pdt <= 27'd0;
	end
	
	always @(*)
		   begin
			   if (!yi[25])
				   sygnyq <= yq;
				else
				   sygnyq <= -yq;
				if (!yq[25])
				   sygnyi <= yi;
				else
					sygnyi <= -yi;
			end
			
	always @(posedge clk)
		pdt <= {sygnyq[25],sygnyq} - {sygnyi[25],sygnyi};	
		
	assign pd = pdt[26:1];

endmodule
