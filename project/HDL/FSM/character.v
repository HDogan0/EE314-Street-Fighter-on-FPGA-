module character(
    input clk,                                          // input clk of the module
    input rst,                                          // reset of the module
    input default_attack_trigger,                       // default attack flag coming from "attack_input" module
	input special_attack_trigger,                       // special attack flag coming from "attack_input" module (CHARGED ATTACK NOT THE DOUBLE) (DOUBLE IS IN THIS FILE)
    input move_forward,                                 // user move forward input
    input move_backward,                                // user move backwatd input
    input hit_flag,                                     // normal attack flag
    input special_hit_flag,                             // special attack flag
    input attack_success,                               // attack collision box overlapped with opponent hurtbox flag
    output reg KO_flag,                                 // knocked-out output flag
    output reg [2:0] current_state,                     // state indicator according to localparam below
    output reg [6:0] frame_tick,								  // frame tick counter output
    output reg [1:0] remaining_blockings                // remaining block chances
);

    localparam default_attack_frame_number = 24;                        // 24 frames default
    localparam default_attack_startup_frame_number = 5;
    localparam default_attack_active_frame_number = 2;
    localparam default_attack_recovery_frame_number = 17; 
    localparam hitstun_default_attack_frame_number = 16;                // -1
    localparam blockstun_default_attack_frame_number = 14;              // -3
    localparam guard_break_default_attack_frame_number = 34;            // +17

    localparam special_attack_frame_number = 47;                        // 47 frames default
    localparam special_attack_startup_frame_number = 14;
    localparam special_attack_active_frame_number = 2;
    localparam special_attack_recovery_frame_number = 31;
    localparam blockstun_special_attack_frame_number = 19;              // -12
    localparam guard_break_special_attack_frame_number = 34;            // +3


    //  to obtain 60Hz clock from 50MHz FPGA clock
    localparam SIXTY_HZ_DIV = 833333;
    //  60Hz character state transition clock
    wire game_clk;
    prescaler #(.div_param(SIXTY_HZ_DIV)) clock_60hz(
        .clk(clk),
        .out(game_clk)
    );

    //  FSM states
    // implemented according to section 2.2 of project outline 
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
    reg [6:0] frame_counter;

    // special-hit long-time memory for hitstun/blockstun/guard_break states
    reg hit_by_special;

    //  FSM implementation for combinational circuit
    always @(*) begin:COMB
        // to avoid additional latches
        next_state = state;

        case(state) 
            
            //
            //  IDLE STATE IMPLEMENTATION
            //  
            s_idle:begin
                if(special_attack_trigger) begin 
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
				else if(hit_flag || special_hit_flag) begin
					next_state = s_hitstun;
				end
                else begin 
                    //  default case should be added for safety
                    next_state = s_idle;
                end
            end

            // 
            //  MOVE FORWARD STATE IMPLEMENTATION
            // 
            s_move_forward:begin 
                if(!move_forward) begin
                    next_state = s_idle;
                end
				else if(hit_flag || special_hit_flag) begin
					next_state = s_hitstun;
				end
                else begin 
                    next_state = s_move_forward;
                end
            end

            //
            //  MOVE BACKWARD STATE IMPLEMENTATION
            //                  
            s_move_backward:begin
                //  if somehow the character is hit while moving back  
                if(hit_flag || special_hit_flag) begin
                    if(remaining_blockings > 0) begin 
                        next_state = s_blockstun;
                    end 
                    else begin 
                        // remaining_blockings == 0
                        next_state = s_guard_break;
                    end
                end
                else if(!move_backward) begin 
                    next_state = s_idle;
                end
                else begin 
                    next_state = s_move_backward;
                end
            end

            //
            //  DEFAULT ATTACK STATE IMPLEMENTATION
            //  
            s_default_attack:begin
                //  if character is hit while attacking
                if(hit_flag || special_hit_flag) begin 
                    next_state = s_hitstun;
                end
                //  successfully attacked with no interruption
                else if(frame_counter >= default_attack_frame_number - 1)begin 
                    next_state = s_idle;
                end
                //  if character spammed default attack in recovery phase of a successful attack
                else if(frame_counter >= (default_attack_startup_frame_number + default_attack_active_frame_number) && default_attack_trigger && attack_success) begin 
                    next_state = s_special_attack;
                end
				//burada speciala geçmek attack_inputta speciala geçirmiyor o sebeple special_hit_flag de 1 olmuyor ve KO olmuyor.
				//ek değişken tanımlayıp attack_input.v a input verilebilir default=0 gibi yapıp ama inst loop içinde olmazsa o da çalışmaz. 
                else begin 
                    next_state = s_default_attack;
                end
            end

            //
            //  SPECIAL ATTACK STATE IMPLEMENTATION
            //  
            s_special_attack:begin
                //  if character is hit while attacking
                if(hit_flag || special_hit_flag) begin 
                    next_state = s_hitstun;
                end
                //  successfully attacked with no interruption
                else if(frame_counter >= special_attack_frame_number - 1) begin 
                    next_state = s_idle;
                end
                else begin 
                    next_state = s_special_attack;
                end
            end

            //
            //  HITSTUN STATE IMPLEMENTATION
            //  
            s_hitstun:begin
                //  IF HIT BY DEFAULT ATTACK, OTHERWISE IT IS A KO
                if((frame_counter >= hitstun_default_attack_frame_number - 1) && !hit_by_special) begin 
                    next_state = s_idle;
                end
                else begin 
                    next_state = s_hitstun;
                end
            end

            //
            //  BLOCKSTUN STATE IMPLEMENTATION
            //  
            s_blockstun:begin
                //  if hit by default attack
                if((frame_counter >= blockstun_default_attack_frame_number - 1) && !hit_by_special) begin 
                    next_state = s_idle;
                end
                //  if hit by special attack
                else if((frame_counter >= blockstun_special_attack_frame_number - 1) && hit_by_special) begin 
                    next_state = s_idle;
                end
                else begin 
                    next_state = s_blockstun;
                end
            end

            //
            //  GUARD BREAK STATE IMPLEMENTATION
            //  
            s_guard_break:begin
                //  if hit by default attack 
                if((frame_counter >= guard_break_default_attack_frame_number - 1) && !hit_by_special) begin 
                    next_state = s_idle;
                end
                //  if hit by special attack
                else if((frame_counter >= guard_break_special_attack_frame_number - 1) && hit_by_special) begin 
                    next_state = s_idle;
                end

                else begin 
                    next_state = s_guard_break;
                end
            end

        endcase
    end

    always @(posedge game_clk or posedge rst) begin:SEQ
        if(rst) begin 
            state <= s_idle;
            frame_counter <= 0;
            remaining_blockings <= 3;
            hit_by_special <= 0;
        end
        else begin
		  state <= next_state;
            //  remainin blockings logic
            if(state==s_move_backward && (hit_flag || special_hit_flag) && remaining_blockings >0) begin 
                remaining_blockings <= remaining_blockings - 1;
            end

            //  hit by special logic
            if(special_hit_flag)begin 
                hit_by_special <= 1;
            end
            else if(hit_flag) begin 
                hit_by_special <= 0;
            end

            //  frame counter logic
            //  if a state change occurs, then we must reset frame_counter to keep up correct "ticking" for each state
            if(state != next_state) begin 
                frame_counter <= 0;
            end
            //  if current state requires a timing 
            else if (state == s_default_attack || state == s_special_attack || state == s_blockstun || state == s_hitstun || state == s_guard_break) begin 
                frame_counter <= frame_counter + 1
                ;
            end 
            else begin
                frame_counter <= 0;
            end

        end
    end

	always @(*) begin:OUT
			KO_flag = 0;
		  // if the character is hit by special attack and it is not moving backward it gets knocked-out
        // no matter the current state is. 
        if (special_hit_flag && state != s_move_backward) begin 
            KO_flag = 1;
        end 
		current_state = state;
		frame_tick = frame_counter;
	end
	 
endmodule
