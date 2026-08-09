`timescale 1 ns / 1 ps

module UART_tb();

localparam DATA_WIDTH = 8;


reg clk_t;
reg reset_t;
reg [DATA_WIDTH - 1 : 0] data_in_t;
reg posedge_triger_t;
wire busy_t;


reg clk_r;
reg reset_r;
wire [DATA_WIDTH - 1 : 0] data_out_r;
wire connect;

UART_top #(
	.CLK_FREQ(50),
	.BAUND_RATE(9600),
	.DATA_WIDTH(8)
)
top(

.clk_t(clk_t),
.reset_t(reset_t),
.data_in_t(data_in_t),
.data_out_t(connect),
.posedge_triger_t(posedge_triger_t),
.busy_t(busy_t),


.clk_r(clk_r),
.reset_r(reset_r),
.data_out_r(data_out_r),
.data_in_r(connect)

);



always begin
	#10;
	clk_t = ~clk_t;
end

always begin
	#10;
	clk_r = ~clk_r;
end


initial begin

clk_t = 0; reset_t =1; data_in_t = 8'b11001011; posedge_triger_t = 0;

clk_r = 0; reset_r =1;

#500;

reset_t = 0;
reset_r = 0;

#500;

posedge_triger_t = 1;

#1050000;

data_in_t = 8'b00110100; posedge_triger_t = 0;

#500;

posedge_triger_t = 1;

#1050000;

$stop;

end


endmodule