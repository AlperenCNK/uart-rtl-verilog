module rx
#(
	parameter CLK_FREQ = 50,
	parameter BAUND_RATE = 9600,
	parameter DATA_WIDTH = 8,
	parameter INDEX_COUNTER_WIDTH = $clog2(DATA_WIDTH)
)
(
	input wire clk,
	input wire reset,
	input wire data_in,
	output reg [DATA_WIDTH - 1 : 0] data_out,
	output reg ready
);

localparam CHECK = 2'b00;
localparam START = 2'b01;
localparam RECEIVE = 2'b10;
localparam STOP = 2'b11;

localparam CLKS_PER_BIT = (CLK_FREQ * 1_000_000)/BAUND_RATE;

reg [19:0] clk_counter;
reg [1:0] state , next_state;
reg [INDEX_COUNTER_WIDTH - 1 : 0] shift_counter;

wire stay_in_state_except_start = (clk_counter < CLKS_PER_BIT -1);
wire stay_in_state_for_start = (clk_counter < CLKS_PER_BIT - 11);
wire quit_from_state_except_start = (clk_counter == CLKS_PER_BIT -1);
wire quit_from_state_for_start = (clk_counter == CLKS_PER_BIT - 11);
wire shift_full = (shift_counter == DATA_WIDTH - 1);
wire stop_bit_correct = (data_in == 1);


always@(posedge clk or posedge reset)begin

	if(reset)begin
		state <= CHECK;
	end else begin
		state <= next_state;
	end

end



always@(posedge clk or posedge reset)begin

	if(reset)begin

		clk_counter <= 0;
		shift_counter <= 0;
		data_out <= 0;

	end else begin

		
		case(state)
		
			CHECK : begin
				clk_counter <= 0;
				shift_counter <= 0;
				data_out <= 0;
			end
			
			
			START : begin 
			
				if(stay_in_state_for_start)begin
					clk_counter <= clk_counter + 1;
				end else begin
					clk_counter <= 0;
				end
			end
	
		
			
			RECEIVE : begin
				
				if(stay_in_state_except_start)begin
					clk_counter <= clk_counter + 1;
				end else begin
					clk_counter <= 0;
					shift_counter <= shift_counter + 1;
					data_out <= {data_in , data_out[DATA_WIDTH - 1 : 1]};
				end
			end
				
				
			STOP : begin 
			
				if(stay_in_state_except_start)begin
					clk_counter <= clk_counter + 1;
				end else begin
					clk_counter <= 0;
					shift_counter <= 0;
				end
		
			end
			
			default : begin
				
			end
		
		
		
		endcase
		
	
	end


end





always@(*) begin
	
	next_state = state;

	case(state)
	
		CHECK : begin
			
		
			if(data_in == 0)begin
				next_state = START;
			end else begin
				next_state = CHECK;
			end
		
		end
	
	
		START : begin
		
			if(quit_from_state_for_start)begin
				next_state = RECEIVE;
			end else begin
				next_state = START;
			end
		
		end
	
	
	
		RECEIVE : begin
			if(quit_from_state_except_start)begin
				if(shift_full)begin
					next_state = STOP;
				end else begin
					next_state = RECEIVE;
				end
			end
			
		end
		

	
	
		STOP : begin
			if(quit_from_state_except_start)begin
				next_state = CHECK;
			end else begin
				next_state = STOP;
			end
		end
		
		default : begin 
			next_state = state;
		end
	
	
	endcase

end


always@(*)begin

	ready = 0;

	case(state)
	
		CHECK : begin
			ready = 0;
		end
		
		START : begin
			ready = 0;
		end
	
		RECEIVE : begin
			ready = 0;
		end
		
		STOP : begin
			if(stop_bit_correct)begin
				ready = 1;
			end else begin
				ready = 0;
			end
		end
		
		default : begin
			ready = 0;
		end

	
	endcase



end

endmodule