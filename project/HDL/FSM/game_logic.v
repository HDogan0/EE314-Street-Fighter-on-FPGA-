`include "states.vh"
module game_logic(
input clk_60hz, clk_50, rst, // clk_60hz: shared 60Hz, clk_50: system 50MHz
input p1_forward, p2_forward,
input p1_backward, p2_backward,
input p1_attack, p2_attack,
output reg [2:0] p1_state, p2_state,//al ver değişkeni top modülde takip için
output reg [6:0] p1_frame, p2_frame,//başka çözüm yolu bulamadım daha kısa ve kolay
output reg [1:0] p1_block, p2_block,
output reg [1:0] p1_ko_num, p2_ko_num,
output wire [7:0] p1_charge_value, p2_charge_value,
output wire [9:0] p1_current_x, p2_current_x,
output wire [9:0] p1_def_hurt_x, p1_def_hurt_y, p1_def_hurt_w, p1_def_hurt_h,
output wire [9:0] p1_def_rec_hurt_x, p1_def_rec_hurt_y, p1_def_rec_hurt_w, p1_def_rec_hurt_h,
output wire [9:0] p1_atk_hit_x, p1_atk_hit_y, p1_atk_hit_w, p1_atk_hit_h,
output wire [9:0] p2_def_hurt_x, p2_def_hurt_y, p2_def_hurt_w, p2_def_hurt_h,
output wire [9:0] p2_def_rec_hurt_x, p2_def_rec_hurt_y, p2_def_rec_hurt_w, p2_def_rec_hurt_h,
output wire [9:0] p2_atk_hit_x, p2_atk_hit_y, p2_atk_hit_w, p2_atk_hit_h,
output reg internal_rst_char_position
);

reg internal_rst;

//  attack logic for p1
wire p1_special_attack, p1_default_attack;
attack_input attack_char_p1(
    .clk_60hz(clk_60hz),
    .attack(p1_attack),
    .rst(rst),
    .special_attack(p1_special_attack),
    .default_attack(p1_default_attack),
    .charge_value(p1_charge_value)
);

//  attack logic for p2
wire p2_special_attack, p2_default_attack;
attack_input attack_char_p2(
    .clk_60hz(clk_60hz),
    .attack(p2_attack),
    .rst(rst),
    .special_attack(p2_special_attack),
    .default_attack(p2_default_attack),
    .charge_value(p2_charge_value)
);

//  char. instantiation for p1
reg p1_hit_flag, p1_special_hit_flag;
wire p1_KO;
wire [2:0] p1_CS;
wire [6:0] p1_frame_tick;
wire [1:0] p1_remaining_blockings;
character p1_character(
    .clk_60hz(clk_60hz),
    .rst(rst | internal_rst),
    .default_attack_trigger(p1_default_attack),
    .special_attack_trigger(p1_special_attack),
    .move_forward(p1_forward),
    .move_backward(p1_backward),
    .hit_flag(p1_hit_flag),
    .special_hit_flag(p1_special_hit_flag),
    .attack_success(p1_attack_success),
    .KO_flag(p1_KO),
    .current_state(p1_CS),
    .frame_tick(p1_frame_tick),
    .remaining_blockings(p1_remaining_blockings)
);

//  char. instantiation for p2
reg p2_hit_flag, p2_special_hit_flag;
wire p2_KO;
wire [2:0] p2_CS;
wire [6:0] p2_frame_tick;
wire [1:0] p2_remaining_blockings;
character p2_character( 
    .clk_60hz(clk_60hz),
    .rst(rst | internal_rst),
    .default_attack_trigger(p2_default_attack),
    .special_attack_trigger(p2_special_attack),
    .move_forward(p2_forward),
    .move_backward(p2_backward),
    .hit_flag(p2_hit_flag),
    .special_hit_flag(p2_special_hit_flag),
    .attack_success(p2_attack_success),
    .KO_flag(p2_KO),
    .current_state(p2_CS),
    .frame_tick(p2_frame_tick),
    .remaining_blockings(p2_remaining_blockings)
);
wire [9:0] p1_x;
wire hit_success_p1;

wire [9:0] p2_x;
wire hit_success_p2;
wire p2_default_additional_hurt_box= (p2_CS == `s_default_attack && p2_frame_tick >=5);//atak aktiflik ve sonrası
wire p2_special_additional_hurt_box= (p2_CS == `s_special_attack && p2_frame_tick >= 14);

wire p1_default_additional_hurt_box= (p1_CS == `s_default_attack && p1_frame_tick >=5);//atak aktiflik ve sonrası
wire p1_special_additional_hurt_box= (p1_CS == `s_special_attack && p1_frame_tick >= 14);

// hitbox ve hurtbox instantiatelenecek
hurtbox hurtbox_p1(
    .player_state(p1_CS),
    .player_x(p1_x),
    .player_hurtbox_x(p1_def_hurt_x),
    .player_hurtbox_y(p1_def_hurt_y),
    .player_hurtbox_w(p1_def_hurt_w),
    .player_hurtbox_h(p1_def_hurt_h),
    .attack_hurtbox_x(p1_def_rec_hurt_x),
    .attack_hurtbox_y(p1_def_rec_hurt_y),
    .attack_hurtbox_w(p1_def_rec_hurt_w),
    .attack_hurtbox_h(p1_def_rec_hurt_h)
);
hitbox hitbox_p1(
    .player_state(p1_CS),
    .player_x(p1_x),
    .is_facing_left(p1_x > p2_x), // P1 is facing left if its x position is greater than P2's x position
    .player_hitbox_x(p1_atk_hit_x),
    .player_hitbox_y(p1_atk_hit_y),
    .player_hitbox_w(p1_atk_hit_w),
    .player_hitbox_h(p1_atk_hit_h)
);

hurtbox hurtbox_p2(
    .player_state(p2_CS),
    .player_x(p2_x),
    .player_hurtbox_x(p2_def_hurt_x),
    .player_hurtbox_y(p2_def_hurt_y),
    .player_hurtbox_w(p2_def_hurt_w),
    .player_hurtbox_h(p2_def_hurt_h),
    .attack_hurtbox_x(p2_def_rec_hurt_x),
    .attack_hurtbox_y(p2_def_rec_hurt_y),
    .attack_hurtbox_w(p2_def_rec_hurt_w),
    .attack_hurtbox_h(p2_def_rec_hurt_h)
);
hitbox hitbox_p2(
    .player_state(p2_CS),
    .player_x(p2_x),
    .is_facing_left(p2_x > p1_x), // P2 is facing left if its x position is greater than P1's x position
    .player_hitbox_x(p2_atk_hit_x),
    .player_hitbox_y(p2_atk_hit_y),
    .player_hitbox_w(p2_atk_hit_w),
    .player_hitbox_h(p2_atk_hit_h)
);

collision_detector p1_coldet(
    .atk_hit_x(p1_atk_hit_x),
    .atk_hit_y(p1_atk_hit_y),
    .atk_hit_w(p1_atk_hit_w),
    .atk_hit_h(p1_atk_hit_h),
    .def_hurt_x(p2_def_hurt_x),
    .def_hurt_y(p2_def_hurt_y),
    .def_hurt_w(p2_def_hurt_w),
    .def_hurt_h(p2_def_hurt_h),
    .def_recovery_hurt_x(p2_def_rec_hurt_x),
    .def_recovery_hurt_y(p2_def_rec_hurt_y),
    .def_recovery_hurt_w(p2_def_rec_hurt_w),
    .def_recovery_hurt_h(p2_def_rec_hurt_h),
    .hurt_recovery(p2_default_additional_hurt_box || p2_special_additional_hurt_box),
    .hit(hit_success_p1)
);

collision_detector p2_coldet(
    .atk_hit_x(p2_atk_hit_x),
    .atk_hit_y(p2_atk_hit_y),
    .atk_hit_w(p2_atk_hit_w),
    .atk_hit_h(p2_atk_hit_h),
    .def_hurt_x(p1_def_hurt_x),
    .def_hurt_y(p1_def_hurt_y),
    .def_hurt_w(p1_def_hurt_w),
    .def_hurt_h(p1_def_hurt_h),
    .def_recovery_hurt_x(p1_def_rec_hurt_x),
    .def_recovery_hurt_y(p1_def_rec_hurt_y),
    .def_recovery_hurt_w(p1_def_rec_hurt_w),
    .def_recovery_hurt_h(p1_def_rec_hurt_h),
    .hurt_recovery(p1_default_additional_hurt_box || p1_special_additional_hurt_box),
    .hit(hit_success_p2)
);

char_positioning p1_p2_pos(
    .game_clk(clk_60hz),
    .rst(rst | internal_rst),
    .p_facing_left_state(p2_CS),
    .p_facing_right_state(p1_CS),
    .px_facing_left(p2_x),
    .px_facing_right(p1_x)
);

assign p1_current_x = p1_x;
assign p2_current_x = p2_x;

// Vuruş (Hit) Bayraklarını Latch'ten Kurtarıp Flip-Flop'a Çevirdik
always @(posedge clk_60hz or posedge rst) begin 
    if (rst) begin
        p1_hit_flag <= 1'b0;
        p1_special_hit_flag <= 1'b0;
        p2_hit_flag <= 1'b0;
        p2_special_hit_flag <= 1'b0;
    end else begin
        // Her karede varsayılan olarak sıfırla (Sadece 1 clock cycle aktif kalmasını sağlar)
        p1_hit_flag <= 1'b0;
        p1_special_hit_flag <= 1'b0;
        p2_hit_flag <= 1'b0;
        p2_special_hit_flag <= 1'b0;

        if(p1_CS == `s_default_attack && p1_frame_tick >= 5 && p1_frame_tick < 7) begin 
            if (hit_success_p1) p1_hit_flag <= 1'b1;
        end
        else if(p1_CS == `s_special_attack && p1_frame_tick >= 14 && p1_frame_tick < 16) begin 
            if (hit_success_p1) p1_special_hit_flag <= 1'b1;
        end
        
        if(p2_CS == `s_default_attack && p2_frame_tick >= 5 && p2_frame_tick < 7) begin 
            if (hit_success_p2) p2_hit_flag <= 1'b1;
        end
        else if(p2_CS == `s_special_attack && p2_frame_tick >= 14 && p2_frame_tick < 16) begin 
            if (hit_success_p2) p2_special_hit_flag <= 1'b1;
        end
    end
end

always @(posedge clk_60hz or posedge rst) begin //karşılıklı special hit
    if (rst) begin
        internal_rst <= 0;
    end
    else if(p1_CS == `s_special_attack && p1_frame_tick >= 14 && p1_frame_tick < 16) begin 
        if (hit_success_p1&&hit_success_p2)begin internal_rst<=1;end
    end
    else if(p2_CS == `s_special_attack && p2_frame_tick >= 14 && p2_frame_tick < 16) begin 
        if (hit_success_p1&&hit_success_p2)begin internal_rst<=1;end
    end
    else if(p1_KO) begin//biri KO olunca rounda sayısı artsın ama başa dönsün diye
        p1_ko_num<=p1_ko_num+1;
        internal_rst<=1;
    end
    else if(p2_KO) begin
        p2_ko_num<=p2_ko_num+1;
        internal_rst<=1;
    end
    else begin
        internal_rst <= 0;
    end
end
always @(*) begin
    p1_state = p1_CS;
    p2_state = p2_CS;
    p1_frame = p1_frame_tick;
    p2_frame = p2_frame_tick;
    p1_block = p1_remaining_blockings;
    p2_block = p2_remaining_blockings;
    internal_rst_char_position = internal_rst;
end

endmodule