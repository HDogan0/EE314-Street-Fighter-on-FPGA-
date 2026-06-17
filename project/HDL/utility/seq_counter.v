// Hasan Doğan
module seq_counter 
// default 4-bits
#(parameter W=4) 
(
input [1:0] control,
input clk, rst,
output reg[W-1:0] count
);
/*
    control => 1x : hold current counter value
    control => 01 : increment counter
    control => 00 : decrement counter
*/
always @(posedge clk) begin
    if(rst) begin 
        count <= {W{1'b0}};
    end
    if(control[1])begin 
        // do nothing
    end
    else begin 
        if(control[0]) begin
        // increase count by 1 if control => 01
            count <= count + 1;
        end
        else begin 
        // decrease count by 1 if control => 00
            count <= count - 1;
        end
    end
end

endmodule