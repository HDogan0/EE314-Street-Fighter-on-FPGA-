module s_hit_flag(
	input hit, special_attack,default_attack,
	output hit_flag, special_hit_flag
);

assign hit_flag=hit||default_attack;
assign special_hit_flag=hit||special_attack;