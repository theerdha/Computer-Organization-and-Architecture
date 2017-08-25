module fsm_tb;
    
    reg clk,reset;
    wire out;
    integer i;
    integer j;
    
    reg in;
    
    fsm_struct m2(clk,reset,in,out);
    initial
        begin
            clk = 0;
             reset = 1;
             #1;
             reset = 0;
            
            for(j = 0; j < 20; j = j + 1)
            begin
               
                for(i = 0 ; i < $random % 40; i = i + 1) 
                begin
                    in = 0;
                    #10 clk = 1;
                    #10 clk = 0;
                     //reset = 0;
                   // $display("state = ",m1.state," input = ",in," output = " ,out);
                   //$display("========================");
                end
                
                for(i = 0 ; i < $random % 40 ; i = i + 1) in = 1;
                begin
                    in = 1;
                    #10 clk = 1;
                    #10 clk = 0;
                    //reset = 0;
                    //$display("state = ",m1.state," input = ",in," output = " ,out);
                    //$display("========================");
                end
                
            end            
        end
endmodule

module fsm_struct(clk,reset,in,out);
    input in,clk,reset;
    output out;
    
    wire z1,z2;
    wire y1,y2;
    
  
    
    fsm_struct_state fss(y1,y2,in,z1,z2);
    fsm_struct_output fso(y1,y2,in,out);
    fsm_struct_delay fsd(y1,y2,z1,z2,clk,reset);
endmodule
    


module fsm_struct_state(y1,y2,in,z1,z2);
    input y1,y2,in;
    output z1,z2;
    
    wire a1,a2;
    
    not(a1,y1);
    xor(a2,in,y2);
    or(z1,a1,a2);
    
   // assign z1 = (~y1)+(in^y2);
    assign z2 = in ;
    
endmodule

module fsm_struct_output(y1,y2,in,out);
    input y1,y2,in;
    output out;
    
    wire y1bar,y2bar,inbar,term1,term2;
    
    not(y1bar,y1);
    not(y2bar,y2);
    not(inbar,in);
    and(term1,y1bar,y2,inbar);
    and(term2,y1,y2bar,in);
    or(out,term1,term2);
    
   // assign out = ((~y1)&(y2)&(~in))+((y1)&(~y2)&(in));
    
endmodule  

module DFF(D,clk,reset,Q,Qbar);
    input D,clk,reset;
    output reg Q;
    output Qbar;
    assign Qbar = ~Q;   
    always @(posedge clk or posedge reset)
        begin
        if(reset) Q <= 0;
        else Q <= D;
    end
endmodule
    

module fsm_struct_delay(y1,y2,z1,z2,clk,reset);
    input z1,z2,clk,reset;
    output y1,y2;
    wire y1,y2;
    wire y1bar,y2bar;
    
    DFF d1(z1,clk,reset,y1,y1bar);
    DFF d2(z2,clk,reset,y2,y2bar);
    
//    always @(posedge clk)
//    begin
//    if(reset) 
//        begin
//        y1 <= 1'b0;
//        y2 <= 1'b0;
//        end
//    else
//        begin
//        y1 <= z1;
//        y2 <= z2;
//        end
//     end
endmodule