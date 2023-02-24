//这是tstdata_produce.v文件的程序清单
module tstdata_produce(
	rst,
	clk,
	ivalid,
	iready,
	idata,
	da_data);

	//input txdata;
	input rst;
	input	clk;//时钟，50MHz
	input ivalid;
	input idata;
	output reg iready;
	output signed [7:0] da_data;//产生的测试信号输出，500kHz的正弦波，1Mbps的基带数据

	wire [31:0] phi;	
	wire [9:0] sin_500k, cos_500k;
	wire ovalid;
	wire [9:0] cos0;
	wire signed [7:0] sin_mix1, sin_mix0;
	reg [9:0] delay_sin[124:0];
	integer i = 0;
	
	assign phi = 32'd8589935;//100KHz//32'd42950000;//500Khz

	data u1(
		.phi_inc_i(phi),
		.clk(clk),
		.reset_n(1'b1),
		.clken(1'b1),
		.fsin_o(sin_500k),
		.fcos_o(cos_500k),
		.out_valid(ovalid));
	
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			for (i=1; i < 125; i = i + 1) begin
				delay_sin[i] <= 0;
			end
		end
		else begin
			for (i=1; i < 125; i = i + 1) begin
				delay_sin[i] <= delay_sin[i-1];
			end
		end
	end
	
	always @(posedge clk, posedge rst) begin
		if(rst)
			delay_sin[0] <= 0;
		else
			delay_sin[0] <= sin_500k;
	end
	
	//将补码数据转换为正整数形式送DA转换器 
	assign  sin_mix0 = cos_500k[9] ? (cos_500k[9:2]-8'd128) : (cos_500k[9:2]+8'd128);
	assign  sin_mix1 = cos0[9] ? (cos0[9:2]-8'd128) : (cos0[9:2]+8'd128);
	assign cos0 = delay_sin[124];
	
	reg [7:0] sin_temp1, sin_temp0;	
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			sin_temp0 = 0; sin_temp1 = 0;
		end
		else begin
			sin_temp0 <= sin_mix0;
			sin_temp1 <= sin_mix1;
		end
	end
	
	reg tx_state;
	reg [1:0] txdata;
	reg [3:0] wave_cnt;
	
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			iready <= 1'b0;
			tx_state <= 0;
			txdata <= 2'b11;
			wave_cnt <= 0;
		end
		else begin
			case(tx_state)
				1'b0: begin
					if((sin_temp0 == 8'd129) && (sin_mix0 == 8'd128) && ivalid) begin
						iready <= 1'b1;
						tx_state <= 1'b1;
					end
					else begin
						tx_state <= 1'b0;
						iready <= 1'b0;
						txdata <= 2'b11;
					end
				end
				1'b1: begin
					iready <= 1'b0;
					txdata <= {1'b0, idata};
					if((sin_temp0 == 8'd129) && (sin_mix0 == 8'd128)) begin
						wave_cnt <= wave_cnt + 1;
						if(wave_cnt == 4'd9) begin
							wave_cnt <= 0;
							if(ivalid) begin
								iready <= 1'b1;
							end
							else begin
								txdata <= 2'b11;
								tx_state <= 1'b0;
							end
						end
					end
				end
			endcase
		end
	end
	
	assign da_data = (txdata == 2'b00)? sin_mix0 : (txdata == 2'b01)? sin_mix1 : 8'd0;

endmodule
