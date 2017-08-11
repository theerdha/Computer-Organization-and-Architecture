module top;
	wire clk,rst,inp,out;
	fsm_beh sm(clk,rst,inp,out);
	testBench tb(clk,rst,inp,out);
endmodule

module testBench(clk,rst,inp,out);
	input out;
	output clk,rst,inp;
	reg reset = 0;
	reg clock = 0,inpu = 0,ou = 0;
	initial
	begin 
		$dumpfile ("shifter.vcd");
		$dumpvars;
	end
	always 
	begin 
		#10 inpu = $urandom%2;
		#5 clock = !clock;
		ou <= out;
	end
	assign clk = clock;
	assign inp = inpu;
	assign rst = reset; 
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
	reg[0:1] state = 01;
	always @(posedge clk or posedge rst)
	begin
		state <= { inp,((!inp) && (!s1) && (!s2)) };
	end
	assign s1 = state[0];
	assign s2 = state[1];
endmodule

module outputFn_fsm(inp,s1,s2,ot);
	input inp,s1,s2;
	output ot;
	assign ot = ( (s1 && s2 && (~inp) ) || ( (~s1) && (~s2) && inp) );
endmodule
