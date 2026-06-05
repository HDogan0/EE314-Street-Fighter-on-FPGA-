module P7seg (output reg [6:0] hexn,input [2:0] hex);
	
	always @ (hex) begin
			case (hex)
				0 : hexn = 7'b0010000;
				1 : hexn = 7'b1111001;
				2 : hexn = 7'b0100100;
			endcase
	end

endmodule