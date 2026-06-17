// Hasan Doğan
module prescaler #(parameter div_param=8)
(
input clk,
output reg out
);

reg[31: 0] prescale_ct = 0;

always @(posedge clk) begin 
    if(prescale_ct >= div_param - 1) begin 
        prescale_ct <= 0;
    end
    else begin 
        prescale_ct <= prescale_ct + 1;
    end
   
    if(prescale_ct < (div_param/2))begin 
        out <= 0;
    end
    else begin 
        out <= 1;
    end

end

endmodule