module P7seg (output reg [6:0] hexn,input [2:0] hex);
	//P1 P2 kolay yazılsın diye
	always @ (hex) begin
			case (hex)
				0 : hexn = 7'b0010100; //P
				1 : hexn = 7'b1111001; //1
				2 : hexn = 7'b0100100; //2
			endcase
	end

endmodule
