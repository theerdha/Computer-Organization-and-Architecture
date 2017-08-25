`timescale 1ns / 1ps

module sqrt2(in,reset,go,clk,over,out);
    output [3:0] out;
    output over;
    input clk,go,reset;
    input[7:0] in;
    wire transSw,transCount,transSq,transK;
    wire ldCount,ldSq,ldK;
    wire[8:0] inBus;
    wire[8:0] outBus1;
    wire[8:0] outBus2;
    wire[2:0] func;
    assign over = inBus[8];
    ASM m1(clk,in,reset,ldSq,ldK,ldCount,transSw,transSq,transK,transCount,inBus,outBus1,outBus2,out);
    ALU m2(outBus1,outBus2,func,inBus);
controller m3(ldSq,ldK,ldCount,transSw,transSq,transK,transCount,func,go,clk,reset,inBus[8]);
endmodule

module testBench;
    reg clock,rst;
    reg[7:0] SW;
    reg go;
    wire over;
    wire[3:0] out; 
    initial
    begin
        $dumpfile ("shifter.vcd");
        $dumpvars;

        rst = 0;
        go = 0;
        clock = 0;
        #10 rst = 1;
        #10 rst = 0;
        #10 SW = 8'b01000000;
        #10 go = 1;
    end
    always
    begin
        #5 clock = ~clock;
    end
sqrt2 M1(SW,rst,go,clock,over,out);
endmodule


module ASM(
         clk,in,reset,
         ldSq,ldK,ldCount,
         transSw,transSq,transK,transCount,
         inBus,outBus1,outBus2,
         count
    );

    input[7:0] in;
    input[8:0] inBus;
    input reset,clk;
    input ldSq,ldK,ldCount;
    input transSw,transSq,transK,transCount;
    output reg[8:0] outBus1;
    output reg[8:0] outBus2;
    output reg[3:0] count;

    reg[8:0] sq;
    reg[8:0] k;


    always @(negedge clk) begin
    if(reset == 1)
        sq <= 9'b0;          
    else if(ldSq == 1)
        sq <= inBus; 
    end
    always @(negedge clk) begin 
    if(reset == 1)
        k <= 9'b0;
    else if(ldK == 1)
    k <= inBus;
    end
    always @(negedge clk) begin
    if(reset == 1)
         count <= 4'b0;
    else if(ldCount == 1)
    count <= inBus[3:0];
    end

    always @(posedge clk) begin
        if(reset == 1) begin
            outBus1 <= 9'b0;
            outBus2 <= 9'b0;
        end
        else if (transSq == 1) 
            outBus1 <= sq;
        else if(transSw == 1)
            outBus1 <= {1'b0,in};
        else if( transCount == 1)
            outBus1 <= {5'b0,count};
        else 
            outBus1 <= sq;
        if(transK == 1)
            outBus2 <= k;
    end
endmodule

module ALU(x,y,f,z);

    input[8:0] x;
    input[8:0] y;
    input[2:0] f;
    output[8:0] z;
    
    wire[8:0] add1;
    wire[8:0] add2;
    wire[8:0] sub;

    assign add1 = x + 9'b000000001;
    assign sub = x - y;
    assign add2 = y + 9'b000000010;  

    assign z[0] = ((~f[2])&(~f[1])&(~f[0])&x[0]) + ((~f[2])&(~f[1])&(f[0])&0) + ((~f[2])&(f[1])&(~f[0])&1) + ((~f[2])&(f[1])&(f[0])&(add1[0])) + ((f[2])&(~f[1])&(~f[0])&(sub[0])) + ((f[2])&(~f[1])&(f[0])&(add2[0]));
    assign z[1] = ((~f[2])&(~f[1])&(~f[0])&x[1]) + ((~f[2])&(~f[1])&(f[0])&0) + ((~f[2])&(f[1])&(~f[0])&0) + ((~f[2])&(f[1])&(f[0])&(add1[1])) + ((f[2])&(~f[1])&(~f[0])&(sub[1])) + ((f[2])&(~f[1])&(f[0])&(add2[1]));
    assign z[2] = ((~f[2])&(~f[1])&(~f[0])&x[2]) + ((~f[2])&(~f[1])&(f[0])&0) + ((~f[2])&(f[1])&(~f[0])&0) + ((~f[2])&(f[1])&(f[0])&(add1[2])) + ((f[2])&(~f[1])&(~f[0])&(sub[2])) + ((f[2])&(~f[1])&(f[0])&(add2[2]));
    assign z[3] = ((~f[2])&(~f[1])&(~f[0])&x[3]) + ((~f[2])&(~f[1])&(f[0])&0) + ((~f[2])&(f[1])&(~f[0])&0) + ((~f[2])&(f[1])&(f[0])&(add1[3])) + ((f[2])&(~f[1])&(~f[0])&(sub[3])) + ((f[2])&(~f[1])&(f[0])&(add2[3]));
    assign z[4] = ((~f[2])&(~f[1])&(~f[0])&x[4]) + ((~f[2])&(~f[1])&(f[0])&0) + ((~f[2])&(f[1])&(~f[0])&0) + ((~f[2])&(f[1])&(f[0])&(add1[4])) + ((f[2])&(~f[1])&(~f[0])&(sub[4])) + ((f[2])&(~f[1])&(f[0])&(add2[4]));
    assign z[5] = ((~f[2])&(~f[1])&(~f[0])&x[5]) + ((~f[2])&(~f[1])&(f[0])&0) + ((~f[2])&(f[1])&(~f[0])&0) + ((~f[2])&(f[1])&(f[0])&(add1[5])) + ((f[2])&(~f[1])&(~f[0])&(sub[5])) + ((f[2])&(~f[1])&(f[0])&(add2[5]));
    assign z[6] = ((~f[2])&(~f[1])&(~f[0])&x[6]) + ((~f[2])&(~f[1])&(f[0])&0) + ((~f[2])&(f[1])&(~f[0])&0) + ((~f[2])&(f[1])&(f[0])&(add1[6])) + ((f[2])&(~f[1])&(~f[0])&(sub[6])) + ((f[2])&(~f[1])&(f[0])&(add2[6]));
    assign z[7] = ((~f[2])&(~f[1])&(~f[0])&x[7]) + ((~f[2])&(~f[1])&(f[0])&0) + ((~f[2])&(f[1])&(~f[0])&0) + ((~f[2])&(f[1])&(f[0])&(add1[7])) + ((f[2])&(~f[1])&(~f[0])&(sub[7])) + ((f[2])&(~f[1])&(f[0])&(add2[7]));
    assign z[8] = ((~f[2])&(~f[1])&(~f[0])&x[8]) + ((~f[2])&(~f[1])&(f[0])&0) + ((~f[2])&(f[1])&(~f[0])&0) + ((~f[2])&(f[1])&(f[0])&(add1[8])) + ((f[2])&(~f[1])&(~f[0])&(sub[8])) + ((f[2])&(~f[1])&(f[0])&(add2[8]));

endmodule   

module controller(
             ldSq,ldK,ldCount,
             transSw,transSq,transK,transCount,
             func,Go,clk,reset,over
             );

    input Go,clk,over,reset;
    output[2:0] func;
    output reg ldSq,ldK,ldCount;
    output reg transSq,transSw,transCount,transK;

    wire[6:0] NS;
    reg[6:0] PS;
        
    always @(posedge clk)begin 
        if(reset == 1)
            PS = 7'b0000001;
        else 
            PS = NS;
    end

    always @(negedge clk) begin
        if(NS[0])
            transSw = 1;
        else 
            transSw = 0;
    end

    always @(negedge clk) begin
        if(NS[3])
            transSq = 1;
        else 
            transSq = 0;
    end

    always @(negedge clk) begin
        if(NS[3] || NS[5])
            transK = 1;
        else 
            transK = 0;
    end

    always @(negedge clk) begin           
        if(NS[4])
            transCount = 1;
        else 
            transCount = 0;
    end

    always @(posedge clk) begin
        if(NS[0] || NS[3])
            ldSq <= 1;
        else
            ldSq <= 0;
    end

    always @(posedge clk) begin
        if( NS[1] || NS[5])
            ldK = 1;
        else    
            ldK = 0;
    end

    always @(posedge clk) begin
        if(NS[2] || NS[4])
            ldCount = 1;
        else 
            ldCount = 0;
    end

    assign NS[0] = PS[0]&(~Go);
    assign NS[1] = PS[0]&Go;
    assign NS[2] = PS[1];
    assign NS[3] = PS[2] | PS[5];
    assign NS[4] = PS[3]&(~over);
    assign NS[5] = PS[4];
    assign NS[6] = PS[3]&over;
    
    assign func[0] = PS[2] | PS[4] | PS[5];
    assign func[1] = PS[1] | PS[4];
    assign func[2] = PS[3] | PS[5] | PS[6];
    
endmodule
