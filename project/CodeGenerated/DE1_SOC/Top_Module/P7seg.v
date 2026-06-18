module P7seg (output reg [6:0] hexn,input [2:0] hex);
	//P1 P2 kolay yazılsın diye
	always @ (hex) begin
			case (hex)
				0 : hexn = 7'b0001100; //P
				1 : hexn = 7'b1111001; //1
				2 : hexn = 7'b0100100; //2
				3 : hexn = 7'b1000001; //V
				4 : hexn = 7'b0010010; //S
				5 : hexn = 7'b0111111; //-
			endcase
	end

endmodule
