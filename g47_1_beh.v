module fsm_tb;
    reg clk,reset;
    wire out;
    integer i;
    integer j;
    
    reg in;
    
    fsm1 m1(clk,reset,in,out);
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
                 //  $display("========================");
                end
                
                for(i = 0 ; i < $random % 40 ; i = i + 1) in = 1;
                begin
                    in = 1;
                    #10 clk = 1;
                    #10 clk = 0;
                    //reset = 0;
                   // $display("state = ",m1.state," input = ",in," output = " ,out);
                    //$display("========================");
                end
                
            end            
        end
endmodule

module fsm1(clk,reset,in,out);
    input clk,reset,in;
    output out;
    
    wire[1:0] state;
    wire[1:0] nextstate;
    wire out;
    
     output_beh ob (state,in,out);
     nextstate_beh nb(in,nextstate,state);
     delay_beh db(clk,reset,nextstate,state);
    
endmodule
    
        
module delay_beh(clk,reset,nextstate,state);
    input clk,reset,nextstate; 
    output state;
    reg state;   
    always @(posedge clk, posedge reset)
        if(reset) state <= 2'b00;
        else state <= nextstate;

endmodule
 
module nextstate_beh(in,nextstate,state);       
    input in,state;
    output reg[1:0] nextstate;
    always @(state)
    begin
        case(state)
        2'b00 :
            if(in)
            nextstate <= 2'b11;
            else 
            nextstate <= 2'b10;
            
         2'b01 :
           if(in)
           nextstate <= 2'b11;
           else 
           nextstate <= 2'b10;

         2'b10 :
            if(in)
            nextstate <= 2'b11;
            else 
            nextstate <= 2'b00;
        
        2'b11 :
            if(in)
            nextstate <= 2'b01;
            else 
            nextstate <= 2'b10;
      
        endcase
    end
endmodule

module output_beh(state,in,out);
    input state,in;
    output reg out;
    
    always @(state or in)
    begin
         case(state)
            
            2'b00 :
                if(in)
                 out <= 1'b0;
                else 
                 out <= 1'b0;
                
             2'b01 :
               if(in)
               out <= 1'b0;
               else 
               out <= 1'b1;
    
             2'b10 :
                if(in)
                out <= 1'b1;
                else 
                out <= 1'b0;
            
            2'b11 :
                if(in)
                out <= 1'b0;
                else 
                out <= 1'b0;
         endcase
         
    end 
endmodule