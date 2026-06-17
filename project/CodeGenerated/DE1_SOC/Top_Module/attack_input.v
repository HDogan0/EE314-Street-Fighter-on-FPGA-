module attack_input(
    input clk,             // 50 MHz system clock
    input attack,          // Raw button input
    input rst,
    output reg special_attack,
    output reg default_attack
);

    // 100Hz clock for attack button input
    localparam HUNDRED_HZ_DIV = 500000;
    wire btn_input_clk;
    
    prescaler #(.div_param(HUNDRED_HZ_DIV)) clock_100hz(
        .clk(clk),
        .out(btn_input_clk)
    );

    //  Edge Detection and State Registers
    reg attack_prev;
    reg [7:0] charge_timer; 
    localparam CHARGE_THRESHOLD = 200; // 200 cycles @ 100Hz = 2 seconds

    // SEQUENTIAL STATE TRANSITION
    always @(posedge btn_input_clk or posedge rst) begin 
        if (rst) begin 
            attack_prev <= 0;
            charge_timer <= 0;
            special_attack <= 0;
            default_attack <= 0;
        end 
        
        else begin 
            // Default pulse states to 0 so they only last 1 clock cycle
            special_attack <= 0;
            default_attack <= 0;
            
            // Shift the current button state into the previous state register
            attack_prev <= attack;

            // When button pressed
            if (attack == 1 && attack_prev == 0) begin
                charge_timer <= 0; // Reset timer on new press
            end
            
            // Hold button
            else if (attack == 1 && attack_prev == 1) begin
                if (charge_timer < 255) begin
                    charge_timer <= charge_timer + 1;
                end
            end
            
            // When button released
            else if (attack == 0 && attack_prev == 1) begin
                // Evaluate the charge duration
                if (charge_timer >= CHARGE_THRESHOLD) begin
                    special_attack <= 1; // special attack flag
                end else begin
                    default_attack <= 1; // default attack flag
                end
            end
        end
    end

endmodule