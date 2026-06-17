`include "states.vh"
module hitbox (
    // ============================================================
    //                    SİSTEM SİNYALLERİ
    // ============================================================
    input  wire  [2:0]  player_state,

    // player karakterinin sol-üst köşesinin X koordinatı (0..639).
    input  wire [9:0]  player_x,
    // ============================================================
    //  Diğer modüle GİDEN HİTBOX/HURTBOX KOORDİNATLARI (Debug görüntü)
    // ============================================================
    // Tüm kutular: sol-üst köşe (x,y) + genişlik w + yükseklik h.
    // 10-bit, hepsi pozitif değer.
    
    // player ana gövde hurtbox: her zaman aktif, sabit boyut
    // ayak/kol kısmı, gövdeyi büyütmek yerine ayrı bir kutu olarak eklenir. ama bunu dışarıya ekstra bir output olarak değil hit detectora kontrol vererek yap.
    // yani hitbox sonradan hurtboxa dönüşüyor ya, onu burada ayrı bir external hurtbox olarak tanımlamaya gerek yok, top modül frame ticke bakıp hangi statede 
    // olduğunu bulsun ve ona göre desin ki tamam artık recovery statede o zaman hitboxu da hurtbox olarak alıyım kesişimler ona göre kontrol edilsin.

    // player hitbox: sadece s_default_attack / s_special_attack state'lerinde aktif.
    output wire [9:0]  player_hitbox_x,
    output wire [9:0]  player_hitbox_y,
    output wire [9:0]  player_hitbox_w,
    output wire [9:0]  player_hitbox_h
);

//reg ve diğer parametre tanımları
localparam SCREEN_W = 640;
localparam SCREEN_H = 480;
localparam PLAYER_W = 64;
localparam PLAYER_H = 240;
localparam PLAYER_Y_OFFSET = 30;          // playerin ayakları ekranın en altından ne kadar yukarıda olacak...

localparam HITBOX_H = 80;                   // hitbox yüksekliği
localparam HITBOX_HEIGTH_DIFFERENCE = 140;     // basic attack ile sp attack yaparken hitboxların y eksenindeki konumları farklı. specialın basicten ne kadar yüksekte olduğunu gösteriyor bu

localparam HITBOX_W_BASIC = 64;            // basic atak yaparken hitbox genişliği
localparam HITBOX_W_SPECIAL = 64;            // sp atak yaparken hitbox genişliği

//DİKKAT4: VGA koordinat sisteminde Y üstten aşağıya artar. Ondan SCREEN_H (yani 480) - ... yazıldı HITBOX_Y_BASIC
localparam HITBOX_Y_BASIC = SCREEN_H - HITBOX_H - PLAYER_Y_OFFSET;            // basic atak yaparken hitbox sol üst köşe y'si
localparam HITBOX_Y_SPECIAL = SCREEN_H - HITBOX_H - PLAYER_Y_OFFSET - HITBOX_HEIGTH_DIFFERENCE;     
reg [9:0]  player_hitbox_y_reg;
// ============= HITBOX TANIMLARI ===================
assign player_hitbox_x = player_x + PLAYER_W / 2; // basic veya sp. atak yaparken hitbox sol üst köşe x kordinatı, playerin konumuna göre gelir
always @(*)begin
	if (player_state == `s_special_attack)begin 
		player_hitbox_y_reg = HITBOX_Y_SPECIAL;
	end else if (player_state == `s_default_attack) begin 
		player_hitbox_y_reg= HITBOX_Y_BASIC;
	end else begin
	player_hitbox_y_reg=0;
	end
end

assign player_hitbox_y = player_hitbox_y_reg;

assign player_hitbox_w = (player_state == `s_special_attack || player_state == `s_default_attack) ? HITBOX_W_SPECIAL : 0;

assign player_hitbox_h = HITBOX_H;

endmodule
