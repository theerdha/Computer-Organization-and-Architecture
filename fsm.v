module top;
	wire clk,rst,inp,out;
	fsm_beh sm(clk,rst,inp,out);
	testBench tb(clk,rst,inp,out);
endmodule

module testBench(clk,rst,inp,out);
	input out;
	output clk,rst,inp;
	reg reset = 0;
	reg clock = 0,inpu = 0;
	initial
	begin 
		$dumpfile ("shifter.vcd");
		$dumpvars;
	end
	always 
	begin 
		#10 inpu = $urandom%2;
		#5 clock = !clock;
	end
	assign clk = clock;
	assign inp = inpu;
	assign rst = reset; 
	// $display("CLK");
	// $moniter("Inp : %b Out : %b",inp,out);
endmodule

module fsm_beh(clk,rst,inp,out);
	input inp,clk,rst;
	output out;
	wire s1,s2,ot;
	stateTrans_fsm C1(clk,rst,inp,s1,s2);
	outputFn_fsm C2(inp,s1,s2,ot);	
	assign out = ot;
endmodule

module stateTrans_fsm(clk,rst,inp,s1,s2);
	input inp,clk,rst;
	output s1,s2;
	
	reg[0:1] state = 00;
	always @(posedge clk or posedge rst)
	begin
		if(rst == 1) 
			state <= 00;
		case({state,inp})
			3'b000: state <= 00;
			3'b001: state <= 10;
			3'b010: state <= 00;
			3'b011: state <= 10;
			3'b100: state <= 00;
			3'b101: state <= 11;
			3'b110: state <= 00;
			3'b111: state <= 10;
		endcase
	end
	assign s1 = state[0];
	assign s2 = state[1];
endmodule

module outputFn_fsm(inp,s1,s2,ot);
	input inp,s1,s2;
	output ot;
	reg out = 0;
	reg[0:1] state = 00;
	always @(s1 != state[0] or s2 != state[1])
	begin
		state <= {s1,s2};
		case({s1,s2,inp})
			3'b000: out <= 0;
			3'b001: out <= 1;
			3'b010: out <= 0;
			3'b011: out <= 0;
			3'b100: out <= 0;
			3'b101: out <= 0;
			3'b110: out <= 1;
			3'b111: out <= 0;
		endcase
	end
	assign ot = out;
endmodule
