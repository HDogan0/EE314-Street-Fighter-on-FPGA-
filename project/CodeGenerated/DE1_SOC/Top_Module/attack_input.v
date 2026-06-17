module attack_input(
    input clk_60hz,        // Clock for sampling button input (60Hz for responsive input without excessive CPU usage)
    input attack,          // Raw button input
    input rst,
    output reg special_attack,
    output reg default_attack,
    output reg [7:0] charge_value
);

    //  Edge Detection and State Registers
    reg attack_prev;
    reg [7:0] charge_timer; 
    localparam CHARGE_THRESHOLD = 120; // 120 cycles @ 60Hz = 2 seconds

    // SEQUENTIAL STATE TRANSITION
    always @(posedge clk_60hz or posedge rst) begin 
        if (rst) begin 
            attack_prev <= 0;
            charge_timer <= 0;
            special_attack <= 0;
            default_attack <= 0;
            charge_value <= 0;
        end 
        else begin 
            // Default pulse states to 0 so they only last 1 clock cycle
            special_attack <= 0;
            default_attack <= 0;

            // Store charge value BEFORE potentially resetting
            charge_value <= charge_timer;

            // Detect edges on the sampled attack input
            if (attack && !attack_prev) begin
                // Button was just pressed
                charge_timer <= 8'd1;
            end 
            else if (attack && attack_prev) begin
                // Button remains held - increment if below threshold
                if (charge_timer < CHARGE_THRESHOLD) begin
                    charge_timer <= charge_timer + 1;
                end
            end 
            else if (!attack && attack_prev) begin
                // Button was just released
                if (charge_timer >= CHARGE_THRESHOLD) begin
                    special_attack <= 1;
                end else if (charge_timer > 8'd0) begin
                    default_attack <= 1;
                end
                charge_timer <= 8'd0;
            end 
            else if (!attack && !attack_prev) begin
                // Button not pressed - keep timer at 0
                charge_timer <= 8'd0;
            end

            attack_prev <= attack;
        end
    end

endmodule