module breadBoard;
    wire[8:0] in;
    wire[3:0] count;
    wire transSw,transCount,transSq,transK;
    wire ldCount,ldSq,ldK;
    wire go,reset,clk;
    wire[8:0] inBus;
    wire[8:0] outBus1;
    wire[8:0] outBus2;
    wire[2:0] func;
    ASM_beh m1(in,go,reset,inBus,ldSq,ldK,ldCount,transSw,transSq,transK,transCount,outBus1,outBus2,count);
    ALU m2(outBus1,outBus2,func,inBus);
    controller m3(ldSq,ldK,ldCount,transSw,transSq,transK,transCount,func,go,clk,reset,inBus[8]);
    testBench m4(clk,go,reset,in);
endmodule

module testBench(clock,go,rst,SW);
    output reg clock,rst;
    output reg[8:0] SW;
    output reg go;
    initial
    begin
        $dumpfile ("shifter.vcd");
        $dumpvars;
        SW <= 9'b001000000;
        rst <= 0;
        go <= 0;
        clock <= 0;
        #2 rst <= 1;
        #5 rst <= 0;
        #5 go <= 1;
        
    end
   
    always
    begin
        #5 clock = ~clock;
    end
endmodule

module ASM_beh(
        in,go,reset,inBus,
        ldSq,ldK,ldCount,
        transSw,transSq,transK,transCount,
        outBus1,outBus2,
        count
    );

    input[8:0] in;
    input[8:0] inBus;
    input go,reset;
    input ldSq,ldK,ldCount;
    input transSw,transSq,transK,transCount;
    output reg[8:0]    outBus1,outBus2;
    output reg[3:0] count;

    reg[8:0] sq;
    reg[8:0] k;

    always @(posedge reset) begin
        outBus1 <= 9'b0;
        outBus2 <= 9'b0;
        count <= 4'b0;
        sq <= 9'b0;
        k <= 9'b0;
    end

    always @(posedge ldSq)
        sq <= inBus;
    always @(posedge ldK)
        k <= inBus;
    always @(posedge ldCount)
        count <= inBus;

    always @(posedge transSq)
        outBus1 <= sq;
    always @(posedge transSw)
        outBus1 <= in;
    always @(posedge transCount)
        outBus1 <= count;
    always @(posedge transK)
        outBus2 <= k;
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

    always @(posedge reset) begin
        func <= 3'b0;
        state <= 3'b0;
        go <= 0;
        ldSq <= 0;
        ldK <= 0;
        ldCount <= 0;
        transSq <= 0;
        transSw <= 0;
        transCount <= 0;
        transK <= 0;
    end

    always @(Go)
        go <= Go;

    always @(posedge clk) begin
        ldSq = 0;
        ldK = 0; 
        ldCount = 0;
        case(state)
            3'b000:
            begin
                transSw = 1;
                func = 000;
            end

            3'b001:
            begin
                func = 010;
            end

            3'b010:
            begin
                func = 001;
            end

            3'b011:
            begin
                transSq = 1; 
                transK = 1;
                func = 100;
            end

            3'b100:
            begin
                transCount = 1;
                func = 011;
            end

            3'b101:
            begin
                transK = 1;
                func = 101;
            end

            3'b110:
            begin
                ldSq = 0;
                ldK = 0; 
                ldCount = 0;
            end

        endcase
    end

    always @(negedge clk)
    begin
        transSq <= 0;
        transK <= 0;
        transCount <= 0;
        transSw <= 0;
        case(state)
            3'b000:
            begin
                ldSq <= 1;
                if(go == 1)
                    state <= 001;
            end

            3'b001:
            begin
                ldK <= 1; 
                state <= 010;
            end

            3'b010:
            begin
                ldCount <= 1;
                state <= 011;
            end

            3'b011:
            begin
                ldSq <= 1;
                if(over == 1)
                    state <= 110;
                else
                    state <= 100;
            end

            3'b100:
            begin
                ldCount <= 1;
                state <= 101;
            end

            3'b101:
            begin
                ldK <= 1;
                state <= 011;
            end

            3'b110:
            begin
                $display("GOOD WORK MODULE!");
            end
        endcase
    end
endmodule