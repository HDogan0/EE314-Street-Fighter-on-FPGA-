module collision_detector(
    input [9:0] atk_hit_x, atk_hit_y, atk_hit_w, atk_hit_h,
    input [9:0] def_hurt_x, def_hurt_y, def_hurt_w, def_hurt_h,
    input [9:0] def_recovery_hurt_x, def_recovery_hurt_y, def_recovery_hurt_w, def_recovery_hurt_h,
    input def_active,
    input atk_active,
    input hurt_recovery,
    output wire hit
);

    wire [9:0] atk_hit_top, atk_hit_bottom, atk_hit_left, atk_hit_right;
    wire [9:0] def_hurt_top, def_hurt_bottom, def_hurt_left, def_hurt_right;
    wire [9:0] def_recovery_hurt_top, def_recovery_hurt_bottom, def_recovery_hurt_left, def_recovery_hurt_right;

    // 1. Attacker Hitbox Assignments
    assign atk_hit_top    = atk_hit_y;
    assign atk_hit_bottom = atk_hit_y + atk_hit_h;
    assign atk_hit_left   = atk_hit_x;
    assign atk_hit_right  = atk_hit_x + atk_hit_w;

    // 2. Defender Hurtbox Assignments
    
    assign def_hurt_top    = def_hurt_y; 
    assign def_hurt_bottom = def_hurt_y + def_hurt_h;
    assign def_hurt_left   = def_hurt_x;
    assign def_hurt_right  = def_hurt_x + def_hurt_w; // Assuming def_hurt_x acts as width here, or adjust based on your exact input meaning

    // 3. Defender Recovery Hurtbox Assignments
    assign def_recovery_hurt_top    = def_recovery_hurt_y;
    assign def_recovery_hurt_bottom = def_recovery_hurt_y + def_recovery_hurt_h;
    assign def_recovery_hurt_left   = def_recovery_hurt_x;
    assign def_recovery_hurt_right  = def_recovery_hurt_x + def_recovery_hurt_w;
    //  main hurt-box flag
    wire hit_main = (atk_hit_left < def_hurt_right)   && 
                    (atk_hit_right > def_hurt_left)   && 
                    (atk_hit_top < def_hurt_bottom)   && 
                    (atk_hit_bottom > def_hurt_top);

    //  additional hurt-box caused by recovery
    wire hit_second = (atk_hit_left < def_recovery_hurt_right)   && 
                      (atk_hit_right > def_recovery_hurt_left)   && 
                      (atk_hit_top < def_recovery_hurt_bottom)   && 
                      (atk_hit_bottom > def_recovery_hurt_top);

    //  assign hit flag
    assign hit = def_active && atk_active && (hit_main || (hurt_recovery && hit_second));

endmodule
