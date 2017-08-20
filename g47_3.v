module testBench;

endmodule

module breadBoard();
	ASM m1();
	controller m2();
endmodule

module register8bit(update,clock,reset);
	input clock,reset;
	input[7:0] update;
	reg[7:0] memory;
	always @(posedge clock) begin
		if(reset == 1)
			memory <= 8'b0;
		else
			memory <= update;
	end
endmodule

module register9bit(update,clock,reset);
	input[8:0] update;
	input clock,reset;
	reg[8:0] memory;
	always @(posedge clock) begin
		if(reset == 1)
			memory <= 9'b0;
		else 
			memory <= update;
	end
endmodule

module register3bit(update,clock,reset);
	input[2:0] update;
	input clock,reset;
	reg[2:0] memory;
	always @(posedge clock) begin
		if(reset == 1)
			memory <= 3'b101;
		else
			memory <= update;
	end
endmodule

module ASM(clock,reset);
	
	input clock,reset;

	wire[7:0] u1,u2;
	wire[8:0] u3;
	wire[2:0] u4;
	wire[7:0] outputBus,inputBus2; 

	register8bit mpend(u1,clock,reset);
	register8bit acc(u2,clock,reset);
	register9bit mlier(u3,clock,reset);
	register3bit count(u4,clock,reset);
	
	reg[2:0] count;

endmodule

module feedback()

module controller();
	
endmodule
