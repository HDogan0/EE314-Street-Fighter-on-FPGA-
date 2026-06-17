module char_positioning(
    input game_clk,
    input rst,
    input [2:0] p_facing_left_state,   // P2 State SAĞ
    input [2:0] p_facing_right_state,  // P1 State SOL
    output reg [9:0] px_facing_left,   // P2 X
    output reg [9:0] px_facing_right   // P1 X
);

    localparam CHAR_WIDTH = 10'd64;
    localparam SCREEN_WIDTH = 10'd640;

    localparam s_idle = 3'b000;
    localparam s_move_forward = 3'b001;
    localparam s_move_backward = 3'b010;
    localparam s_special_attack = 3'b100;
    
    reg [9:0] next_x_facing_left;
    reg [9:0] next_x_facing_right;

    initial begin
        px_facing_left  = 10'd476;   // P2 starts on the right side of the screen
        px_facing_right = 10'd100;   // P1 starts on the left side of the screen
    end

    always @(posedge game_clk or posedge rst) begin 
        if(rst) begin 
            px_facing_left <= 10'd476;   
            px_facing_right <= 10'd100;  
        end
        else begin 
            // 1. Default to staying still
            next_x_facing_right = px_facing_right;
            next_x_facing_left  = px_facing_left;

            // 2. P1 Movement (Facing Right)
            if (p_facing_right_state == s_move_forward) begin
                next_x_facing_right = px_facing_right + 10'd3; 
            end 
            else if (p_facing_right_state == s_move_backward) begin
                if (px_facing_right >= 10'd2) // Underflow Protection
                    next_x_facing_right = px_facing_right - 10'd2;
                else 
                    next_x_facing_right = 10'd0;
            end
            else if (p_facing_right_state == s_special_attack) begin
                next_x_facing_right = px_facing_right + 10'd1; 
            end

            // 3. P2 Movement (Facing Left)
            if (p_facing_left_state == s_move_forward) begin
                if (px_facing_left >= 10'd3) // Underflow Protection
                    next_x_facing_left = px_facing_left - 10'd3;
                else 
                    next_x_facing_left = 10'd0;
            end 
            else if (p_facing_left_state == s_move_backward) begin
                next_x_facing_left = px_facing_left + 10'd2; 
            end
            else if (p_facing_left_state == s_special_attack) begin
                if (px_facing_left >= 10'd1) // Underflow Protection
                    next_x_facing_left = px_facing_left - 10'd1;
                else 
                    next_x_facing_left = 10'd0;
            end

            // 4. Wall Collisions (Right Edge Only, Left Edge is handled by Underflow Protection)
            if (next_x_facing_right + CHAR_WIDTH >= SCREEN_WIDTH) begin
                next_x_facing_right = SCREEN_WIDTH - CHAR_WIDTH; 
            end
            if (next_x_facing_left + CHAR_WIDTH >= SCREEN_WIDTH) begin
                next_x_facing_left = SCREEN_WIDTH - CHAR_WIDTH; 
            end

            // 5. Body Collisions (Only block forward/attacking movements, allow retreating)
            if (next_x_facing_right + CHAR_WIDTH >= next_x_facing_left) begin
                
                // If P1 is pushing right into P2, cancel P1's movement
                if (p_facing_right_state == s_move_forward || p_facing_right_state == s_special_attack) begin
                    next_x_facing_right = px_facing_right;
                end
                
                // If P2 is pushing left into P1, cancel P2's movement
                if (p_facing_left_state == s_move_forward || p_facing_left_state == s_special_attack) begin
                    next_x_facing_left  = px_facing_left;
                end
            end

            // 6. Update Registers
            px_facing_right <= next_x_facing_right;
            px_facing_left  <= next_x_facing_left;
        end
    end
endmodule