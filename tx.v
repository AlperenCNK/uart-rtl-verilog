module tx 
#(
	parameter CLK_FREQ = 50,
	parameter BAUND_RATE = 9600,
	parameter DATA_WIDTH = 8,
	parameter SHIFT_COUNTER_WIDTH = $clog2(DATA_WIDTH)
)(
	input wire clk,
	input wire reset,
	input wire [DATA_WIDTH - 1 : 0]data_in,
	input wire posedge_triger,
	output reg data_out,
	output reg busy

);

localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam SEND = 2'b10;
localparam STOP = 2'b11;

localparam CLKS_PER_BIT = (CLK_FREQ * 1_000_000)/BAUND_RATE;  

reg [19:0] clk_counter;
reg [1:0] state , next_state;
reg [SHIFT_COUNTER_WIDTH - 1 :0] shift_counter;
reg old_posedge_triger;
reg [DATA_WIDTH - 1 : 0] data_in_buffer;

wire trigered = (posedge_triger == 1) & (old_posedge_triger == 0);
wire stay_in_state = (clk_counter < CLKS_PER_BIT -1);
wire quit_from_state = (clk_counter == CLKS_PER_BIT -1);
wire shift_full = (shift_counter == DATA_WIDTH - 1);


always@(posedge clk or posedge reset)begin

	if(reset)begin
		state <= IDLE;
	end else begin
		state <= next_state;
	end

end



always@(posedge clk or posedge reset)begin
	if(reset)begin
		clk_counter <= 0;
		shift_counter <= 0;
		old_posedge_triger <= 0;
		data_in_buffer <= 0;
	end else begin
		old_posedge_triger <= posedge_triger;
		
		case(state) 
		
			IDLE : begin
				clk_counter <= 0;
				shift_counter <= 0;
				data_in_buffer <= data_in;
			end
		
			START : begin 
				if(stay_in_state)begin
					clk_counter <= clk_counter + 1;
				end else begin
					clk_counter <= 0;
				end
			end
		
		
			SEND : begin
				if(stay_in_state)begin
					clk_counter <= clk_counter + 1;
				end else begin
					clk_counter <= 0;
					if(!(shift_full))begin
						shift_counter <= shift_counter + 1;
						data_in_buffer <= data_in_buffer >> 1;
					end else begin
						shift_counter <= 0;
					end
				end
			end
		
			STOP : begin
				if(stay_in_state) begin
					clk_counter <= clk_counter + 1;
				end else begin
					clk_counter <= 0;
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
	
		IDLE : begin
			
			if(trigered)begin
				next_state = START;
			end else begin
				next_state = IDLE;
			end
		end
	
		START : begin
			if(quit_from_state)begin
				next_state = SEND;
			end else begin
				next_state = START;
			end
		end
	
	
		SEND : begin
			if(quit_from_state) begin
				if(shift_full)begin
					next_state = STOP;
				end else begin
					next_state = SEND;
				end
			end else begin
				next_state = SEND;
			end
		end
	
	
		STOP : begin
			if(quit_from_state) begin
				next_state = IDLE;
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

	data_out = 1;
	busy = 1;
	
	
	case(state)
	
		IDLE : begin
			data_out = 1;
			busy = 0;
		end
		
		START : begin 
			data_out = 0;
			busy = 1;
		end
	
		
		SEND : begin 
			
			data_out = data_in_buffer[0];
			busy = 1;
		end
		
		
		STOP : begin
			data_out = 1;
			busy = 1;
		end
		
		default : begin 
			data_out = 1;
			busy = 1;
		end
	
	endcase


end

endmodule