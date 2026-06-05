`include "states.vh"
module hurtbox (
    // SORUN OLMA İHTİMALİ OLAN YERLERDE "DİKKAT" NOTLARI VAR. özellikle DİKKAT6'ya bir daha bakın açıklamaya
    // HURTBOX'U ŞÖYLE TASARLADIK. BU MODÜLDEKİ HURTBOX SADECE KİŞİNİN KENDİ BODYSİ, YANİ RECOVER OLURKEN HITBOX HANI HURTBOXA DÖNÜŞÜYOR YA, O KONTROL BURADA DEĞİL, ONU TOP MODÜLDE AYARLAMALISINIZ.
    // KULLANICININ HANGI STATEDE OLDUĞUNA BAKARAK. EĞER ŞU STATEDE İSE HITBOXU HURTBOXA DÖNÜŞTÜR O ŞEKİLDE AL olacak mantık.
    // ============================================================
    //                    SİSTEM SİNYALLERİ
    // ============================================================
    input  wire        player_left,
    input  wire        player_right,
    input  wire        player_hitbox_active,
	input  wire  [2:0] player_state,

    // player karakterinin sol-üst köşesinin X koordinatı (0..639).
    output reg  [9:0]  player_x,   

    // ============================================================
    //  Diğer modüle GİDEN HİTBOX/HURTBOX KOORDİNATLARI (Debug görüntü)
    // ============================================================
    // Tüm kutular: sol-üst köşe (x,y) + genişlik w + yükseklik h.
    // 10-bit, hepsi pozitif değer.
    
    // player hurtbox: state'e bağlı olarak dinamik boyut.
    // Idle/yürüme'de normal, recovery'de genişlemiş (whiff-punish için).
    output wire [9:0]  player_hurtbox_x,
    output wire [9:0]  player_hurtbox_y, 
    output wire [9:0]  player_hurtbox_w,
    output wire [9:0]  player_hurtbox_h,
	 output wire [9:0]  attack_hurtbox_x,
    output wire [9:0]  attack_hurtbox_y, 
    output wire [9:0]  attack_hurtbox_w,
    output wire [9:0]  attack_hurtbox_h
);

// reg ve diğer parametre tanımları
localparam SCREEN_W = 640;
localparam SCREEN_H = 480;
localparam PLAYER_W = 64;
localparam PLAYER_H = 240;
localparam PLAYER_Y_OFFSET = 30;          // playerin ayakları ekranın en altından ne kadar yukarıda olacak...

localparam HURTBOX_W = 60;           
localparam HURTBOX_H = 90;                 

localparam HURTBOX_HEIGTH_DIFFERENCE = 135;

localparam HURTBOX_Y_BASIC = SCREEN_H - HURTBOX_H - PLAYER_Y_OFFSET;
localparam HURTBOX_Y_SPECIAL = SCREEN_H - HURTBOX_H - PLAYER_Y_OFFSET - HURTBOX_HEIGTH_DIFFERENCE;     
// ============= HURTBOX TANIMLARI ===================
assign player_hurtbox_x = player_x;

assign player_hurtbox_y = SCREEN_H - PLAYER_Y_OFFSET - PLAYER_H;  // tabandan da biraz boşluk. sol üst köşenin konumu bu dikkat et. p2 için de aynısı geçerli

assign player_hurtbox_w = PLAYER_W;

assign player_hurtbox_h = PLAYER_H; //DİKKAT2: burada böyle yapınca hurtbox oyuncu biraz elevationa sahip olduğu için ekranın en altından başlayabilir. ama sorun değil orayla kimsenin işi yok nolacak. p2 için de aynısı geçerli
//ek hurtbox
assign attack_hurtbox_x = player_x + PLAYER_W / 2 + 10;

assign attack_hurtbox_y = (player_state == `s_special_attack) ? HURTBOX_Y_SPECIAL :
                          (player_state == `s_default_attack) ? HURTBOX_Y_BASIC   : 0;
assign attack_hurtbox_w = HURTBOX_W;

assign attack_hurtbox_h = HURTBOX_H

endmodule
