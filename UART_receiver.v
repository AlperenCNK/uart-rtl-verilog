module UART_receiver 
#(
parameter CLK_FREQ = 50,
parameter BAUND_RATE = 9600,
parameter DATA_WIDTH = 8
)
(
	input wire clk,
	input wire reset,
	input wire data_in,
	output reg [DATA_WIDTH - 1 : 0] data_out,
	output reg ready
);

localparam CHECK = 2'b01;
localparam RECEIVE = 2'b10;
localparam STOP = 2'b11;

localparam CLKS_PER_BIT = (CLK_FREQ * 1_000_000)/BAUND_RATE;

reg [19:0] clk_counter;
reg [1:0] state;
reg [2:0] bit_index;
reg ready_to_receive;
reg finish_receive;



always@(posedge clk or posedge reset)begin

	if(reset)begin 
	
		state <= CHECK;
		clk_counter <= 0;
		data_out <= 0;
		bit_index <= 0;
		ready_to_receive <= 1;
		finish_receive <= 0;
		
	end else begin

		case(state)

			CHECK : begin
				if(clk_counter < CLKS_PER_BIT - 1)begin
					clk_counter <= clk_counter + 1;			
				end else begin
					clk_counter <= 0;
					if(data_in == 0)begin
						state <= RECEIVE;
					end
				end
			end

			
			RECEIVE : begin 
				if(clk_counter < CLKS_PER_BIT - 1)begin
					clk_counter <= clk_counter + 1;			
				end else begin
					clk_counter <= 0;
					data_out[bit_index] <= data_in;
					bit_index <= bit_index + 1;
					if(bit_index == DATA_WIDTH - 1)begin
						state <= STOP;
					end
				end
			end

			STOP : begin
				if(clk_counter < CLKS_PER_BIT - 1)begin
					clk_counter <= clk_counter + 1;			
				end else begin
					state <= CHECK;
				end
			end
	
		endcase

	end


end


always@(*)begin

	









end



endmodule