`timescale 1 ns / 1 ps

module tx_tb();

reg clk;
reg reset;
reg [7:0] data_in;
reg posedge_triger;

wire data_out;
wire busy;

tx my_tx(
.clk(clk),
.reset(reset),
.data_in(data_in),
.data_out(data_out),
.ready(ready)
);


always begin
		
	#10;
	clk = ~clk;
		
end



initial begin

clk = 0; reset = 1; data_in = 8'b10101010; posedge_triger = 0;

#100;

reset = 0;

#100;

posedge_triger = 1; #20; posedge_triger = 0;


#1500000;

data_in = 8'b0011001100;

#100;

posedge_triger = 1; #20; posedge_triger = 0;

#1500000;



end


endmodule