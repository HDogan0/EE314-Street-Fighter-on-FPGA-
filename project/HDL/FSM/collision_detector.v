module collision_detector(
    input [9:0] atk_hit_top, atk_hit_bottom, atk_hit_left, atk_hit_right,
    input [9:0] def_hurt_top, def_hurt_bottom, def_hurt_left, def_hurt_right,
    input [9:0] def_recovery_hurt_top, def_recovery_hurt_bottom, def_recovery_hurt_left, def_recovery_hurt_right,
    input def_active,
    input atk_active,
    input hurt_recovery,
    output wire hit
);

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
