`timescale 1ns / 1ps

module sqrt(
    input [7:0] in,
    input reset,
    input go,
    output [4:0] count,
    output over
    );

    wire transSw,transCount,transSq,transK;
    wire ldCount,ldSq,ldK;
    wire clk;
    wire[8:0] inBus;
    wire[8:0] outBus1;
    wire[8:0] outBus2;
    wire[2:0] func;
    assign over = inBus[8];
    ASM_beh m1(in,go,reset,inBus,ldSq,ldK,ldCount,transSw,transSq,transK,transCount,outBus1,outBus2,count);
    ALU m2(outBus1,outBus2,func,inBus);
    controller m3(ldSq,ldK,ldCount,transSw,transSq,transK,transCount,func,go,clk,reset,inBus[8]);
endmodule

module ASM_beh(
        in,go,reset,inBus,
        ldSq,ldK,ldCount,
        transSw,transSq,transK,transCount,
        outBus1,outBus2,
        count
    );

    input[7:0] in;
    input[8:0] inBus;
    input go,reset;
    input ldSq,ldK,ldCount;
    input transSw,transSq,transK,transCount;
    output reg[8:0] outBus1;
    output reg[8:0] outBus2;
    output reg[3:0] count;

    reg[8:0] sq;
    reg[8:0] k;


    always @(ldSq or reset) begin
        if(ldSq == 1)
            sq <= inBus;
        else if(reset)
            sq <= 9'b0;
    end
    always @(ldK or reset) begin
        if(ldK == 1)
            k <= inBus;
        else if(reset == 1)
            k <= 9'b0;
    end
    always @(ldCount or reset) begin
        if(ldCount == 1)
            count <= inBus;
        else if(reset == 1)
            count <= 4'b0;
    end
    always @(transSq or transSw or transCount or reset) begin
        if(transSq == 1)
            outBus1 <= sq;
        else if(transSw == 1)
            outBus1 <= {0,in};
        else if(transCount == 1)     
            outBus1 <= count;
        else if(reset == 1)
            outBus1 <= 9'b0;
    end
    always @(transK) begin
        if(transK == 1)
            outBus2 <= k;
        else if(reset == 1)
            outBus2 <= 9'b0;
    end
endmodule

module ALU(x,y,func,z);

    input[8:0] x;
    input[8:0] y;
    input[2:0] func;
    output reg[8:0] z;
    always @(x or y or func) begin
            case(func)
                3'b000 :
                z <= x;
                3'b001 :
                z <= 9'b0;
                3'b010 :
                z <= 1;
                3'b011 :
                z <= x + 9'b000000001;
                3'b100 :
                z <= x - y;
                3'b101 :
                z <= y + 9'b000000010;
            endcase
        end
endmodule   

module controller(
        ldSq,ldK,ldCount,
        transSw,transSq,transK,transCount,
        func,Go,clk,reset,over
        );

    reg go;
    reg[2:0] state;

    input Go,clk,over,reset;
    output reg[2:0] func;
    output reg ldSq,ldK,ldCount;
    output reg transSq,transSw,transCount,transK;

    always @(Go or reset) begin
        if(reset == 1)
            go = 0;
        else
            go = Go;
    end
    always @(clk or reset) begin
        if(clk == 1 && state == 3'b000)
            transSw = 1;
        else if(clk == 0 || reset == 1|| state == 3'b110)
            transSw = 0;
    end
    always @(clk or reset) begin
        if(clk == 1 && state == 3'b011)
            transSq = 1;
        else if(clk == 0 || reset == 1 || state == 3'b110)
            transSq = 0;
    end
    always @(clk or reset) begin
        if(clk == 1 && (state == 3'b011 || state == 3'b101) )
            transK = 1;
        else if(clk == 0 || reset == 1 || state == 3'b110)
            transK = 0;
    end
    always @(clk or reset) begin
        if(clk == 1 && state == 3'b100 )
            transCount = 1;
        else if(clk == 0 || reset == 1 || state == 3'b110)
            transCount = 0;
    end
    
    always @(clk or reset) begin
        if(clk == 0 && (state == 3'b000 || state == 3'b011 ))
            ldSq = 1;
        else if( clk == 1 || reset == 1)
            ldSq = 0;
    end
    always @(clk or reset) begin
        if(clk == 0 && (state == 3'b001 || state == 3'b101))
            ldK = 1;
        else if( clk == 1 || reset == 1)
            ldK = 0;
    end
    always @(clk or reset) begin
        if(clk == 0 && (state == 3'b010 || state == 3'b100))
            ldCount = 1;
        else if( clk == 1 || reset == 1)
            ldCount = 0;
    end

    
    always @(clk or reset) begin
        if(reset == 1)
            func = 000;
        else if(clk == 1) begin
            case(state)
                3'b000:
                    func = 000;
                3'b001:
                    func = 010;
                3'b010:
                    func = 001;
                3'b011:
                    func = 100;
                3'b100:
                    func = 011;
                3'b101:
                    func = 101;
            endcase
        end
    end

    always @(clk or reset ) begin
        if(reset == 1)
            state = 000;
        else if(clk == 0) begin
            case(state)
                3'b000:
                    if(go == 1)
                        state <= 001;
                3'b001:
                    state <= 010;
                
                3'b010:
                    state <= 011;
                3'b011:
                    if(over == 1)
                        state <= 110;
                    else
                        state <= 100;
                3'b100:
                    state <= 101;
                3'b101:
                    state <= 011;
                3'b110:
                    $display("GOOD WORK MODULE!");
            endcase
        end
    end
endmodule