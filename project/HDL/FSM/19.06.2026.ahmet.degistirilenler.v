
//===========================================================================================================
//===========================================================================================================
//===========================================================================================================

TOP MODULE'DA:

//===========================================================================================================
//===========================================================================================================
//===========================================================================================================
YORUM EKLENDİ
wire [1:0] p1_block, p2_block; // block point adedi

//===========================================================================================================
//===========================================================================================================
//===========================================================================================================
// HITPOINT INDICATORU BASLAT BURDA
hitpts_indicator hp_inst(.pixel_x(next_x), .pixel_y(next_y),
                         .p1_block(p1_block), .p2_block(p2_block),
                         .write_left_hitpt(hp_left_on), .write_right_hitpt(hp_right_on));
//===========================================================================================================
//===========================================================================================================
//===========================================================================================================
START yazısını büyütmek için rom koyma

// START word positioning (48x12) boyutu 4x artırıldı
wire [9:0] start_x = 10'd224; // center roughly 
wire [9:0] start_y = 10'd216;
wire in_start_bounds = (next_x >= start_x) && (next_x < start_x + 10'd192) &&
					  (next_y >= start_y) && (next_y < start_y + 10'd48);
wire [5:0] start_rom_x = (next_x - start_x) >> 2;
wire [3:0] start_rom_y = (next_y - start_y) >> 2;

ve en altta instantiationu değiştirme
start start_inst(.x(start_rom_x), .y(start_rom_y), .pixel_on(start_on));


//===========================================================================================================
//===========================================================================================================
//===========================================================================================================
game fsm state=GAME logici
  
    end else if (game_fsm_state == GAME) begin
        if (in_p1_charge_bar_fill) begin
            color_in1 = 8'b000_111_00; // P1 charge fill (green)
        end else if (in_p1_charge_bar_bg) begin
            color_in1 = 8'b011_011_01; // P1 charge bar background (gray)
        end else if (in_p2_charge_bar_fill) begin
            color_in1 = 8'b000_111_00; // P2 charge fill (green)
        end else if (in_p2_charge_bar_bg) begin
            color_in1 = 8'b011_011_01; // P2 charge bar background (gray)
        end else if (in_p1_bounds) begin
            color_in1 = 8'b111_000_00; // P1 main body (Solid Red)
        end else if (in_p2_bounds) begin
            color_in1 = 8'b000_000_11; // P2 main body (Solid Blue)
        end else if (write_left_hitpt) begin
            color_in1 = 8'b111_111_00; // sarı renkli p1 hitpoints
        end else if (write_right_hitpt) begin
            color_in1 = 8'b111_111_00; // sarı renkli p2 hitpoints					
        end else if (in_p1_atk_hit) begin
            color_in1 = 8'b111_111_00; // P1 attack hitbox (Solid Yellow)
        end else if (in_p1_def_hurt) begin
            color_in1 = 8'b111_001_00; // P1 defensive hurtbox (Solid Orange)
        end else if (in_p2_atk_hit) begin
            color_in1 = 8'b000_111_11; // P2 attack hitbox (Solid Cyan)
        end else if (in_p2_def_hurt) begin
            color_in1 = 8'b001_111_11; // P2 defensive hurtbox (Solid Light Cyan)
        end else if (next_y >= 10'd320) begin
            color_in1 = 8'b000_111_00; // Ground (Green)
        end else begin
            color_in1 = 8'b001_001_01; // Game background (Dark Gray)
        end
        
    end else begin
        color_in1 = 8'b001_001_01; // Neutral background for END or undefined states
    end