module digit_0 (
    input wire [2:0] x, // 0-7
    input wire [3:0] y, // 0-11
    output reg pixel_on
);
    reg [7:0] row_data;

    always @(*) begin
        case(y)
            4'd0:  row_data = 8'b00111100;
            4'd1:  row_data = 8'b01111110;
            4'd2:  row_data = 8'b11100111;
            4'd3:  row_data = 8'b11000011;
            4'd4:  row_data = 8'b11000011;
            4'd5:  row_data = 8'b11000011;
            4'd6:  row_data = 8'b11000011;
            4'd7:  row_data = 8'b11000011;
            4'd8:  row_data = 8'b11000011;
            4'd9:  row_data = 8'b11100111;
            4'd10: row_data = 8'b01111110;
            4'd11: row_data = 8'b00111100;
            default: row_data = 8'b00000000;
        endcase

        pixel_on = row_data[3'd7 - x];
    end
endmodule