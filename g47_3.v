module testBench;
	// breadBoard BB(clock,reset,SW,go);
endmodule

module breadBoard(clock,reset,SW,go);
	
	input clock,reset,go;
	input[7:0] SW;

	wire is_zero;
	wire[2:0] x;
	wire transSW,transMpend,transAcc,transAddOSub,
	ldAcc,ldMpend,ldMplier,ldCount,ldShift,
	double,addOsub;

	ASM m1(clock,reset,SW,is_zero,x,
	transSW,transMpend,transAcc,transAddOSub,
	ldAcc,ldMpend,ldMplier,ldCount,ldShift,
	double,addOsub);
	
	controller m2(clock,reset,is_zero,go,x,
	transSW,transMpend,transAcc,transAddOSub,
	ldAcc,ldMpend,ldMplier,ldCount,ldShift,
	double,addOsub);

endmodule

module ASM(clock,reset,SW,is_zero,x,
	transSW,transMpend,transAcc,transAddOSub,
	ldAcc,ldMpend,ldMplier,ldCount,ldShift,
	double,AddOSub);
	
	input[7:0] SW;
	input clock,reset,transSW,transMpend,transAcc,transAddOSub,
	ldAcc,ldMpend,ldMplier,ldCount,ldShift,
	double,AddOSub;
	output is_zero;
	output[2:0] x;

	wire[7:0] u1,u2,u3,u6,u7;
	wire[8:0] u4,u8;
	wire[2:0] u5;
	wire[7:0] outputBus1,outputBus2,inputBus; 
	wire double,AddOSub;

	assign x = {mplier.memory[2],mplier.memory[1],mplier.memory[0]};

	register8bit mpend(u1,clock,reset);
	register8bit acc(u3,clock,reset);
	register9bit mplier(u8,clock,reset);
	register3bit count(u5,clock,reset);
	
	triStateBuffer SW1(transMpend,mpend.memory,outputBus1);
	triStateBuffer SW2(transAcc,acc.memory,outputBus2);
	triStateBuffer SW3(transAddOSub,u7,inputBus);
	triStateBuffer SW4(ldDirect1,outputBus1,inputBus);
	triStateBuffer SW5(ldDirect2,outputBus2,inputBus);
	triStateBuffer SW6(transSW,SW,inputBus);

	MUX8 M1(ldMpend,mpend.memory,inputBus,u1);
	MUX8 M2(ldAcc,acc.memory,inputBus,u2);
	MUX8 M3(ldShift,u2,{u2[7],u2[7],u2[7:2]},u3);
	MUX9 M4(ldMplier,mplier.memory,{inputBus,1'b0},u4);
	MUX9 M5(ldShift,u4,{u2[1],u2[0],u4[8:2]},u8);	

	doubleV M6(double,outputBus1,u6);
	addSub M7(AddOSub,u6,outputBus2,u7);
	checkZero M8(count.memory,is_zero);

	decrement3Bit M9(ldCount,count.memory,u5);

endmodule

module controller(clock,reset,is_zero,go,multi3,
	transSW,transMpend,transAcc,transAddOSub,
	ldAcc,ldMpend,ldMplier,ldCount,ldShift,
	double,AddOSub);

	input clock,reset,go,is_zero;
	input[2:0] multi3;

	output transSW,transMpend,transAcc,transAddOSub;
	output ldAcc,ldMpend,ldMplier,ldCount,ldShift;
	output double,AddOSub;

	wire clock,reset;
	wire[9:0] PS,NS;

	delay CM1(NS,clock,reset,PS);
	controllerFsm CM2(PS,go,is_zero,multi3,NS);
	controllerSignals CM3(PS,transSW,transMpend,transAcc,transAddOSub,ldAcc,ldMpend,ldMplier,ldCount,ldShift,double,AddOSub);

endmodule

module delay(NS,clock,reset,PS);

    input[9:0] NS;
    input clock;
    input reset;
    output[9:0] PS;
    assign PS = state.memory;
    register10bit state(NS,clock,reset);

endmodule

module controllerFsm(PS,go,is_zero,x,NS);

    input wire[9:0] PS;
    input go,is_zero;
    input wire[2:0] x;
    output wire[9:0] NS;
   
    assign NS[0] = (PS[0]&(!go)) | (PS[4]&(!go));
    assign NS[1] = (PS[0]&go) | (PS[1]&(go));
    assign NS[2] = (PS[1]&(!go)) | (PS[2]&(!go));
    assign NS[3] = PS[2]&go;
    assign NS[4] = (PS[3]&(!is_zero)) | (PS[4]&go);
    assign NS[5] = (PS[3] & is_zero & ( ((!x[2])&(!x[1])& x[0]) | ((!x[2])&(x[1])& (!x[0]))));
    assign NS[6] = (PS[3] & is_zero & ( ((x[2])&(!x[1])& x[0]) | ((x[2])&(x[1])& (!x[0]))));
    assign NS[7] = (PS[3] & is_zero & ((!x[2])&(x[1])& x[0]));
    assign NS[8] = (PS[3] & is_zero & ((x[2])&(!x[1])& (!x[0])));
    assign NS[9] = ((PS[3] & is_zero & ( ((x[2])&(x[1])& x[0]) | ((!x[2])&(!x[1])& (!x[0]))))) | PS[5] | PS[6] | PS[7] | PS[8];

endmodule

module controllerSignals(PS,transSW,transMpend,transAcc,transAddOSub,ldAcc,ldMpend,ldMplier,ldCount,ldShift,double,addOsub);

	input wire[9:0] PS;
	output wire transSW,transMpend,transAcc,transAddOSub;
	output wire ldAcc,ldMpend,ldMplier,ldCount,ldShift;
	output wire double,addOsub;

	assign transSW = PS[0]|PS[2];
	assign transMpend = PS[5] | PS[6] | PS[7] | PS[8];
	assign transAcc = PS[5] | PS[6] | PS[7] | PS[8];
	assign transAddOSub = PS[5] | PS[6] | PS[7] | PS[8];
	assign ldAcc = PS[5] | PS[6] | PS[7] | PS[8];
	assign ldMpend = PS[0];
	assign ldMplier = PS[2];
	assign ldCount = PS[3];
	assign double = PS[7] | PS[8];
	assign addOsub = PS[5] | PS[7];
	assign ldShift = PS[9];

endmodule

module checkZero(count,is_zero);
	input[2:0] count;
	output is_zero;
	assign is_zero = |count;
endmodule

module addSub(AddOSub,inp1,inp2,out);
	input AddOSub;
	input[7:0] inp1,inp2;
	output[7:0] out;
	assign out = AddOSub?(inp1+inp2):(inp1-inp2);
endmodule

module doubleV(control,inp,out);
	input control;
	input[7:0] inp;
	output[7:0] out;
	assign out = control ? (inp<<1):(inp);
endmodule

module triStateBuffer(enable,inp,out);
	input[7:0] inp;
	input enable;
	output[7:0] out;
	assign out = enable?inp:'bz;
endmodule 

module MUX8(enable,inp1,inp2,out);
	input[7:0] inp1,inp2;
	input enable;
	output[7:0] out;
	assign out = enable?inp2:inp1;
endmodule

module MUX9(enable,inp1,inp2,out);
	input[8:0] inp1,inp2;
	input enable;
	output[8:0] out;
	assign out = enable?inp2:inp1;
endmodule

module decrement3Bit(enable,inp,out);
	input enable;
	input[2:0] inp;
	output[2:0] out;
	assign out = enable?(inp - 1):inp;
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

module register10bit(update,clock,reset);
	input[9:0] update;
	input clock,reset;
	reg[9:0] memory;
	always @(posedge clock) begin
		if(reset == 1)
			memory <= 10'b0;
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