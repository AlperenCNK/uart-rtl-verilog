module UART_top #(
	parameter CLK_FREQ = 50,
	parameter BAUND_RATE = 9600,
	parameter DATA_WIDTH = 8
)
(
input wire clk_t,
input wire reset_t,
input wire [7 : 0] data_in_t,
output wire data_out_t,
input wire posedge_triger_t,
output busy_t,

input wire clk_r,
input wire reset_r,
input wire data_in_r,
output wire [7:0] data_out_r,
output ready_r
);


tx #(
	.CLK_FREQ(CLK_FREQ),
	.BAUND_RATE(BAUND_RATE),
	.DATA_WIDTH(DATA_WIDTH)
) t(
.clk(clk_t),
.reset(reset_t),
.data_in(data_in_t),
.data_out(data_out_t),
.posedge_triger(posedge_triger_t),
.busy(busy_t)
);


rx #(
	.CLK_FREQ(CLK_FREQ),
	.BAUND_RATE(BAUND_RATE),
	.DATA_WIDTH(DATA_WIDTH)
) r(
.clk(clk_r),
.reset(reset_r),
.data_in(data_in_r),
.data_out(data_out_r),
.ready(ready_r)
);



endmodule