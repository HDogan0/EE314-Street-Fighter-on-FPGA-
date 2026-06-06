`include "../utility/states.vh"
module game_logic(
input clk, rst,
input p1_forward, p2_forward,
input p1_backward, p2_backward,
input p1_attack, p2_attack,
output p1_block, p2_block
);



//  attack logic for p1
wire p1_special_attack, p1_default_attack;
attack_input attack_char_p1(
    .clk(clk),
    .btn_in(p1_attack),
    .rst(rst),
    .special_attack(p1_special_attack),
    .default_attack(p1_default_attack)
);

//  attack logic for p2
wire p2_special_attack, p2_default_attack;
attack_input attack_char_p2(
    .clk(clk),
    .btn_in(p2_attack),
    .rst(rst),
    .special_attack(p2_special_attack),
    .default_attack(p2_default_attack)
);

//  char. instantiation for p1
wire p1_hit_flag, p1_special_hit_flag;
wire p1_KO;
wire p1_CS;
wire p1_frame_tick;
wire p1_remaining_blockings;
character p1_character(
    .clk(clk),
    .rst(rst),
    .default_attack_trigger(p1_default_attack),
    .special_attack_trigger(p1_special_attack),
    .move_forward(p1_forward),
    .move_backward(p1_backward),
    .hit_flag(p1_hit_flag),
    .attack_success(p1_attack_success),
    .KO_flag(p1_KO),
    .current_state(p1_CS),
    .frame_tick(p1_frame_tick),
    .remaining_blockings(p1_remaining_blockings)
);

//  char. instantiation for p2
wire p2_hit_flag, p2_special_hit_flag;
wire p2_KO;
wire p2_CS;
wire p2_frame_tick;
wire p2_remaining_blockings;
character p2_character( 
    .clk(clk),
    .rst(rst),
    .default_attack_trigger(p2_default_attack),
    .special_attack_trigger(p2_special_attack),
    .move_forward(p2_forward),
    .move_backward(p2_backward),
    .hit_flag(p2_hit_flag),
    .attack_success(p2_attack_success),
    .KO_flag(p2_KO),
    .current_state(p2_CS),
    .frame_tick(p2_frame_tick),
    .remaining_blockings(p2_remaining_blockings)
);
wire p1_x;
wire p1_atk_hit_x, p1_atk_hit_y, 
p1_atk_hit_h, p1_atk_hit_w, p1_def_hurt_x,
p1_def_hurt_y, p1_def_hurt_h, p1_def_hurt_w,
p1_def_rec_hurt_x, p1_def_rec_hurt_y, 
p1_def_rec_hurt_h, p1_def_rec_hurt_w;
wire hit_success_p1;

wire p2_x;
wire p2_atk_hit_x, p2_atk_hit_y, 
p2_atk_hit_h, p2_atk_hit_w, p2_def_hurt_x,
p2_def_hurt_y, p2_def_hurt_h, p2_def_hurt_w,
p2_def_rec_hurt_x, p2_def_rec_hurt_y, 
p2_def_rec_hurt_h, p2_def_rec_hurt_w;
wire hit_success_p2;
wire p2_default_additional_hurt_box= (p2_CS == s_default_attack && p2_frame_tick >=5);//atak aktiflik ve sonrası
wire p2_special_additional_hurt_box= (P2_CS == s_special_attack && p2_frame_tick >= 14);

wire p1_default_additional_hurt_box= (p1_CS == s_default_attack && p1_frame_tick >=5);//atak aktiflik ve sonrası
wire p1_special_additional_hurt_box= (P1_CS == s_special_attack && p1_frame_tick >= 14);

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
    .player_hitbox_x(p1_atk_hit_x),
    .player_hitbox_y(p1_atk_hit_y),
    .player_hitbox_w(p1_atk_hit_w),
    .player_hitbox_h(p1_atk_hit_h)
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
always @(*) begin 
    if(p1_CS == s_default_attack && p1_frame_tick >= 5 && p1_frame_tick < 7) begin 
        if(p2_default_additional_hurt_box) begin 

        end
        else if(p2_special_additional_hurt_box) begin 

        end
    end
end


endmodule