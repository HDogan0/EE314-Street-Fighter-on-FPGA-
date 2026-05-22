module character(
    input clk,
    input rst,
    input default_attack_trigger, 
    input special_attack_trigger,
    input move_forward,
    input move_backward,
    input hit_flag
);

    //  to obtain 60Hz clock from 50mHz FPGA clock
    localparam SIXTY_HZ_DIV = 833333;
    //  60Hz character state transition clock
    wire game_clk;
    prescaler #(.div_param(SIXTY_HZ_DIV)) clock_60hz(
        .clk(clk),
        .out(game_clk)
    );

    //  FSM states
    localparam [2:0]
    s_idle = 3'b000,
    s_move_forward = 3'b001,
    s_move_backward = 3'b010,
    s_default_attack = 3'b011,
    s_special_attack = 3'b100,
    s_hitstun = 3'b101,
    s_blockstun = 3'b110,
    s_guard_break = 3'b111
    ;

    //  state & next_state
    reg [2:0] state, next_state;

    //  frame counter for correct timing
    reg [7:0] frame_counter;

    //  FSM implementation for combinational circuit
    always @(*) begin 
        next_state = state;

        case(state) 

            s_idle:begin 
                if(attack==0 && move_backward==0 && move_forward==0) begin 
                    next_state = s_idle;
                end
                else if(special_attack_trigger) begin 
                    next_state = s_special_attack;
                end
                else if(default_attack_trigger) begin 
                    next_state = s_default_attack;
                end
                else if(move_forward) begin 
                    next_state = s_move_forward;
                end
                else if(move_backward) begin 
                    next_state = s_move_backward;
                end
                else begin 
                    //  IDK
                    next_state = s_idle;
                end
            end

            s_move_forward:begin 
                if(!move_forward) begin
                    next_state = s_idle;
                end
            end
            
            s_move_backward:begin 
                if(!move_backward) begin 
                    next_state = s_idle;
                end
            end

            s_default_attack:begin 

                if(hit_flag) begin 
                    next_state = s_hitstun;
                end

                else if(frame_counter == 24)begin 
                    next_state = s_idle;
                end

            end

            s_special_attack:begin 
                
                if(hit_flag) begin 
                    next_state = s_hitstun;
                end
                
                else if(frame_counter == 47) begin 
                    next_state = s_idle;
                end

            end

            s_hitstun:begin 

            end

            s_blockstun :begin 

            end

            s_guard_break:begin 

            end

        endcase
    end

    always @(posedge game_clk || posedge rst) begin 
        if(rst) begin 

        end
        else begin 

        end
    end

endmodule
