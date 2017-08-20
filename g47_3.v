// `timescale 1ns / 1ps

module testBench;
    reg clock,reset,go;
    reg[7:0] SW;
    wire[15:0] display;
    initial begin
    	$dumpfile ("shifter.vcd");
		$dumpvars;
		clock = 0;
		reset = 1;
		go = 0;
		#10 reset = 0;
		#10 SW = 8'b00000010;
		#10 go = 1;
		#10 go = 0;
		#10 SW = 8'b00000110;
		#10 go = 1;
	end
     
    always begin
       #5 clock <= ~clock;
      
    end
    breadBoard BB(clock,reset,SW,go,display);
endmodule

module breadBoard(clock,reset,SW,go,display);
	 
    input clock,reset,go;
    input[7:0] SW;
    output wire[15:0] display;
 
    wire is_zero;
    wire[2:0] x;
    wire transSW,transMpend,transAcc,transAddOSub,
    ldAcc,ldMpend,ldMplier,ldCount,ldShift,
    double,addOsub,ldDisplay;

    ASM m1(clock,reset,SW,is_zero,x,
    transSW,transMpend,transAcc,transAddOSub,
    ldAcc,ldMpend,ldMplier,ldCount,ldShift,ldDisplay,
    double,addOsub,display);
   
    controller m2(clock,reset,is_zero,go,x,
    transSW,transMpend,transAcc,transAddOSub,
    ldAcc,ldMpend,ldMplier,ldCount,ldShift,ldDisplay,
    double,addOsub);
   
   
   
endmodule

module ASM(clock,reset,SW,is_zero,x,
    transSW,transMpend,transAcc,transAddOSub,
    ldAcc,ldMpend,ldMplier,ldCount,ldShift,ldDisplay,
    double,AddOSub,display);
   
    input[7:0] SW;
    input clock,reset,transSW,transMpend,transAcc,transAddOSub,
    ldAcc,ldMpend,ldMplier,ldCount,ldShift,ldDisplay,
    double,AddOSub;
    output is_zero;
    output[2:0] x;
    output[15:0] display;

    wire[7:0] u1,u2,u3,u6,u7,accReg,mpendReg;
    wire[8:0] u4,u8,mplierReg;
    wire[2:0] u5,countReg;
    wire[7:0] outputBus1,outputBus2,inputBus;
    wire double,AddOSub;

    register8bit mpend(u1,clock,reset,mpendReg);
    register8bit acc(u3,clock,reset,accReg);
    register9bit mplier(u8,clock,reset,mplierReg);
    register3bit count(u5,clock,reset,countReg);

    assign x = {mplierReg[2],mplierReg[1],mplierReg[0]};
   
    triStateBuffer SW1(transMpend,mpendReg,outputBus1);
    triStateBuffer SW2(transAcc,accReg,outputBus2);
    triStateBuffer SW3(transAddOSub,u7,inputBus);
//    triStateBuffer SW4(ldDirect1,outputBus1,inputBus);
//    triStateBuffer SW5(ldDirect2,outputBus2,inputBus);
    triStateBuffer SW6(transSW,SW,inputBus);

    MUX8 M1(ldMpend,mpendReg,inputBus,u1);
    MUX8 M2(ldAcc,accReg,inputBus,u2);
    MUX8 M3(ldShift,u2,{u2[7],u2[7],u2[7:2]},u3);
    MUX9 M4(ldMplier,mplierReg,{inputBus,1'b0},u4);
    MUX9 M5(ldShift,u4,{u2[1],u2[0],u4[8:2]},u8);   

    doubleV M6(double,outputBus1,u6);
    addSub M7(AddOSub,outputBus2,u6,u7);
    checkZero M8(countReg,is_zero);

    decrement3Bit M9(ldCount,countReg,u5);
   
    showOutput m3(ldDisplay,{accReg[7:0],mplierReg[8:1]},display);

endmodule

module controller(clock,reset,is_zero,go,multi3,
    transSW,transMpend,transAcc,transAddOSub,
    ldAcc,ldMpend,ldMplier,ldCount,ldShift,ldDisplay,
    double,AddOSub);

    input clock,reset,go,is_zero;
    input[2:0] multi3;

    output transSW,transMpend,transAcc,transAddOSub;
    output ldAcc,ldMpend,ldMplier,ldCount,ldShift,ldDisplay;
    output double,AddOSub;

    wire clock,reset;
    wire[9:0] PS,NS;

    delay CM1(NS,clock,reset,PS);
    controllerFsm CM2(PS,go,is_zero,multi3,NS);
    controllerSignals CM3(PS,transSW,transMpend,transAcc,transAddOSub,ldAcc,ldMpend,ldMplier,ldCount,ldShift,ldDisplay,double,AddOSub);

endmodule

module delay(NS,clock,reset,PS);

    input[9:0] NS;
    input clock;
    input reset;
    output[9:0] PS;
    register10bit state(NS,clock,reset,PS);

endmodule

module controllerFsm(PS,go,is_zero,x,NS);

    input wire[9:0] PS;
    input go,is_zero;
    input wire[2:0] x;
    output wire[9:0] NS;
  
    assign NS[0] = (PS[0]&(!go)) | (PS[4]&(!go));
    assign NS[1] = (PS[0]&go) | (PS[1]&(go));
    assign NS[2] = (PS[1]&(!go)) | (PS[2]&(!go));
    assign NS[3] = PS[2]&go | PS[9];
    assign NS[4] = (PS[3]&(!is_zero)) | (PS[4]&go);
    assign NS[5] = (PS[3] & is_zero & ( ((!x[2])&(!x[1])& x[0]) | ((!x[2])&(x[1])& (!x[0]))));
    assign NS[6] = (PS[3] & is_zero & ( ((x[2])&(!x[1])& x[0]) | ((x[2])&(x[1])& (!x[0]))));
    assign NS[7] = (PS[3] & is_zero & ((!x[2])&(x[1])& x[0]));
    assign NS[8] = (PS[3] & is_zero & ((x[2])&(!x[1])& (!x[0])));
    assign NS[9] = ((PS[3] & is_zero & ( ((x[2])&(x[1])& x[0]) | ((!x[2])&(!x[1])& (!x[0]))))) | PS[5] | PS[6] | PS[7] | PS[8];

endmodule

module controllerSignals(PS,transSW,transMpend,transAcc,transAddOSub,ldAcc,ldMpend,ldMplier,ldCount,ldShift,ldDisplay,double,addOsub);

    input wire[9:0] PS;
    output wire transSW,transMpend,transAcc,transAddOSub;
    output wire ldAcc,ldMpend,ldMplier,ldCount,ldShift,ldDisplay;
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
    assign ldDisplay = PS[4];

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

module showOutput(enable,inp,out);
    input enable;
    input[15:0] inp;
    output[15:0] out;
    assign out = enable?inp:16'b0;
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

module register8bit(update,clock,reset,data);
    input clock,reset;
    input[7:0] update;
    output[7:0] data;
    (*keep = "true"*)reg[7:0] memory;
    assign data = memory;
    always @(negedge clock) begin
        if(reset == 1)
            memory = 8'b0;
        else
            memory = update[7:0];
    end
endmodule

module register9bit(update,clock,reset,data);
    input[8:0] update;
    input clock,reset;
    output[8:0] data;
    (*keep = "true"*)reg[8:0] memory;
    assign data = memory;
    always @(negedge clock) begin
		if(reset == 1)
	    	memory = 9'b0;
		else
		    memory = update[8:0];
    end
endmodule

module register10bit(update,clock,reset,data);
    input[9:0] update;
    input clock,reset;
    output[9:0] data;
    (*keep = "true"*)reg[9:0] memory;
    assign data = memory;
    always @(posedge clock) begin
		if(reset == 1)
    		memory = 10'b0000000001;
        else
            memory = update[9:0];
    end
endmodule

module register3bit(update,clock,reset,data);
    input[2:0] update;
    input clock,reset;
    output[2:0] data;
    (*keep = "true"*)reg[2:0] memory;
    assign data = memory;
    always @(negedge clock) begin
		if(reset == 1)
		    memory = 3'b101;
		else
		    memory = update[2:0];
    end
endmodule