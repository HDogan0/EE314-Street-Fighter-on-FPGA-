module digit_3 (
    input wire [2:0] x, // 0-7 (3 bits wide)
    input wire [3:0] y, // 0-11 (4 bits wide)
    output reg pixel_on
);
    reg [7:0] row_data;
    always @(*) begin
        case(y)
            4'd0:  row_data = 8'b01111110;
            4'd1:  row_data = 8'b11111111;
            4'd2:  row_data = 8'b00000011;
            4'd3:  row_data = 8'b00000110;
            4'd4:  row_data = 8'b00111100;
            4'd5:  row_data = 8'b00000110;
            4'd6:  row_data = 8'b00000011;
            4'd7:  row_data = 8'b11000011;
            4'd8:  row_data = 8'b11111111;
            4'd9:  row_data = 8'b01111110;
            4'd10: row_data = 8'b00000000; // Flat bottom to prevent random screen dots
            4'd11: row_data = 8'b00000000;
            default: row_data = 8'b0;
        endcase
        pixel_on = row_data[3'd7 - x];
    end
endmodule