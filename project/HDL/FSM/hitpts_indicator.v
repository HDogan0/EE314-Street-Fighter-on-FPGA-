module hitpts_indicator(
    input  wire [9:0] pixel_x, pixel_y,   // o anki VGA pikseli (next_x/next_y)
    input  wire [1:0] p1_block, p2_block,     // kaç tane blok hakkı kaldı
    output reg        write_left_hitpt, write_right_hitpt // 1 => bu piksel sarı boyansın    
);


wire [9:0] left_indicator_start_x = 10'd20;
wire [9:0] left_indicator_start_y = 10'd20;
wire [9:0] right_indicator_start_x = 10'd588;
wire [9:0] right_indicator_start_y = 10'd20;

wire left_in_bounds = (pixel_x >= left_indicator_start_x) && (pixel_x < left_indicator_start_x + 10'd32) &&
					   (pixel_y >= left_indicator_start_y) && (pixel_y < left_indicator_start_y + 10'd48);

wire right_in_bounds = (pixel_x >= right_indicator_start_x) && (pixel_x < right_indicator_start_x + 10'd32) &&
					   (pixel_y >= right_indicator_start_y) && (pixel_y < right_indicator_start_y + 10'd48);   

wire [2:0] left_rom_x = (pixel_x - left_indicator_start_x) >> 2; // bunun genişliği 3 bit çünkü digit_XX dosyasında inputlar 3 ve 4 bit sırayla x,y
wire [3:0] left_rom_y = (pixel_x - left_indicator_start_y) >> 2;
wire [2:0] right_rom_x = (pixel_y - right_indicator_start_x) >> 2;
wire [3:0] right_rom_y = (pixel_y - right_indicator_start_y) >> 2;

// sol
digit_0 d0L(.x(left_rom_x), .y(left_rom_y), .pixel_on(d0L_on));
digit_1 d1L(.x(left_rom_x), .y(left_rom_y), .pixel_on(d1L_on));
digit_2 d2L(.x(left_rom_x), .y(left_rom_y), .pixel_on(d2L_on));
digit_3 d3L(.x(left_rom_x), .y(left_rom_y), .pixel_on(d3L_on));
// sağ
digit_0 d0R(.x(right_rom_x), .y(right_rom_y), .pixel_on(d0R_on));
digit_1 d1R(.x(right_rom_x), .y(right_rom_y), .pixel_on(d1R_on));
digit_2 d2R(.x(right_rom_x), .y(right_rom_y), .pixel_on(d2R_on));
digit_3 d3R(.x(right_rom_x), .y(right_rom_y), .pixel_on(d3R_on));

wire d0L_on, d1L_on, d2L_on, d3L_on;
wire d0R_on, d1R_on, d2R_on, d3R_on;
reg p1_digit_on, p2_digit_on; // normalde wire da olur aslında ama always içinde atama yapıldığı için reg olarak tanımlanması gerekiyor

always @(*) begin
    case (p1_block)
        2'd0: p1_digit_on = d0L_on; //örneklenen modüller sayıları yazdırmak için bit kontrolü yapıyor, ilgili noktada bit var mı yok mu ona bakar bu
        2'd1: p1_digit_on = d1L_on;
        2'd2: p1_digit_on = d2L_on;
        2'd3: p1_digit_on = d3L_on;
        default: p1_digit_on = 0;
    endcase
    case (p2_block)
        2'd0: p2_digit_on = d0R_on;
        2'd1: p2_digit_on = d1R_on;
        2'd2: p2_digit_on = d2R_on;
        2'd3: p2_digit_on = d3R_on;
        default: p2_digit_on = 0;
    endcase
    write_left_hitpt = (p1_digit_on && left_in_bounds); //örneklenen modül biti yak demiş mi, ve demişse şu anda kontrol edilen vga biti sınırlar içinde mi
    write_right_hitpt = (p2_digit_on && right_in_bounds);
end

endmodule