// states.vh
`ifndef STATES_VH
`define STATES_VH

`define s_idle            3'b000
`define s_move_forward    3'b001
`define s_move_backward   3'b010
`define s_default_attack  3'b011
`define s_special_attack  3'b100
`define s_hitstun         3'b101
`define s_blockstun       3'b110
`define s_guard_break     3'b111

`endif