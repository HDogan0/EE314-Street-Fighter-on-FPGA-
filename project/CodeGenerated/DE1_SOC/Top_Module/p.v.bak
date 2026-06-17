module p (
    input wire [4:0] x,       // 0-17 (18 columns wide)
    input wire [3:0] y,       // 0-11 (12 rows high)
    input wire select_p2,     // 0 = Draw P1, 1 = Draw P2
    output reg pixel_on
);

    reg [17:0] row_data;

    always @(*) begin
        case(y)
            // Format: [P] + [2 empty spaces] + [1 or 2]
            4'd0:  row_data = select_p2 ? 18'b11111110_00_01111110 : 18'b11111110_00_00011000;
            4'd1:  row_data = select_p2 ? 18'b11111111_00_11111111 : 18'b11111111_00_00111000;
            4'd2:  row_data = select_p2 ? 18'b11000011_00_11000011 : 18'b11000011_00_01111000;
            4'd3:  row_data = select_p2 ? 18'b11000011_00_00000110 : 18'b11000011_00_11111000;
            4'd4:  row_data = select_p2 ? 18'b11111111_00_00001100 : 18'b11111111_00_00011000;
            4'd5:  row_data = select_p2 ? 18'b11111110_00_00011000 : 18'b11111110_00_00011000;
            4'd6:  row_data = select_p2 ? 18'b11000000_00_00110000 : 18'b11000000_00_00011000;
            4'd7:  row_data = select_p2 ? 18'b11000000_00_01100000 : 18'b11000000_00_00011000;
            4'd8:  row_data = select_p2 ? 18'b11000000_00_11111111 : 18'b11000000_00_00011000;
            4'd9:  row_data = select_p2 ? 18'b11000000_00_11111111 : 18'b11000000_00_00011000;
            4'd10: row_data = 18'b10000000_00_00000000;
            4'd11: row_data = 18'b10000000_00_00000000;
            default: row_data = 18'b0;
        endcase
        
        // Safely index the 18-bit row from left-to-right
        pixel_on = row_data[5'd17 - x];
    end
endmodule