module char_positioning(
    input game_clk,
    input rst,
    input [2:0] p_facing_left_state,   // State of the character on the RIGHT side
    input [2:0] p_facing_right_state,  // State of the character on the LEFT side
    output reg [9:0] px_facing_left,   // Current X of the character on the RIGHT
    output reg [9:0] px_facing_right   // Current X of the character on the LEFT
);

    localparam CHAR_WIDTH = 10'd64;
    localparam SCREEN_WIDTH = 10'd640;

    localparam s_move_forward = 3'b001;
    localparam s_move_backward = 3'b010;
    localparam s_special_attack = 3'b100;
	// 1. Calculate intended NEXT positions (ignoring collisions for a microsecond)
	reg [9:0] next_x_facing_left;
	reg [9:0] next_x_facing_right;
    
    always @(posedge game_clk or posedge rst) begin 
        if(rst) begin 
            px_facing_left <= 10'd476;   // character on RIGHT
            px_facing_right <= 10'd100;  // character on LEFT
        end
        else begin 
            
            // --- Character on LEFT (logical name: "facing_right") ---
            // Use safe clamping to avoid unsigned underflow/overflow
            if (p_facing_right_state == s_move_forward) begin
                // move right, clamp to screen (character right edge <= SCREEN_WIDTH)
                if (px_facing_right >= SCREEN_WIDTH - CHAR_WIDTH - 10'd3)
                    next_x_facing_right = SCREEN_WIDTH - CHAR_WIDTH;
                else
                    next_x_facing_right = px_facing_right + 10'd3;
            end else if (p_facing_right_state == s_move_backward) begin
                // move left, avoid underflow
                if (px_facing_right <= 10'd2)
                    next_x_facing_right = 10'd0;
                else
                    next_x_facing_right = px_facing_right - 10'd2;
            end else if (p_facing_right_state == s_special_attack) begin
                if (px_facing_right >= SCREEN_WIDTH - CHAR_WIDTH - 10'd1)
                    next_x_facing_right = SCREEN_WIDTH - CHAR_WIDTH;
                else
                    next_x_facing_right = px_facing_right + 10'd1;
            end else begin
                next_x_facing_right = px_facing_right;
            end

            // --- Character on RIGHT (logical name: "facing_left") ---
            // Use safe clamping to avoid unsigned underflow/overflow
            if (p_facing_left_state == s_move_forward) begin
                // move left, avoid underflow
                if (px_facing_left <= 10'd3)
                    next_x_facing_left = 10'd0;
                else
                    next_x_facing_left = px_facing_left - 10'd3;
            end else if (p_facing_left_state == s_move_backward) begin
                // move right, clamp to screen
                if (px_facing_left >= SCREEN_WIDTH - CHAR_WIDTH - 10'd2)
                    next_x_facing_left = SCREEN_WIDTH - CHAR_WIDTH;
                else
                    next_x_facing_left = px_facing_left + 10'd2;
            end else if (p_facing_left_state == s_special_attack) begin
                if (px_facing_left <= 10'd1)
                    next_x_facing_left = 10'd0;
                else
                    next_x_facing_left = px_facing_left - 10'd1;
            end else begin
                next_x_facing_left = px_facing_left;
            end

            // 2. Resolve Collisions

            // Wall Collisions
            if (next_x_facing_right <= 0) begin
                next_x_facing_right = 0; // Hits the left edge of the VGA screen
            end
            if (next_x_facing_left + CHAR_WIDTH >= SCREEN_WIDTH) begin
                next_x_facing_left = SCREEN_WIDTH - CHAR_WIDTH; // Hits the right edge
            end

            // Body Collisions (The character on the left cannot pass the character on the right)
            if (next_x_facing_right + CHAR_WIDTH >= next_x_facing_left) begin
                //  keep them still, do not change their x_pos
                next_x_facing_right = px_facing_right;
                next_x_facing_left  = px_facing_left;
            end

            // 
            px_facing_right <= next_x_facing_right;
            px_facing_left  <= next_x_facing_left;
        end
    end

endmodule