`include "states.vh"
module hitbox (
    // ============================================================
    //                  SİSTEM SİNYALLERİ
    // ============================================================
    input  wire  [2:0]  player_state,
    
    // player karakterinin sol-üst köşesinin X koordinatı (0..639)
    input  wire  [9:0]  player_x,
    
    // Karakterin Yönü (0: Sağa Bakıyor/P1,  1: Sola Bakıyor/P2)
    // DİKKAT: Top_Module'de bu modülü çağırırken bu girişi P1 için 0, P2 için 1 yapmalısın.
    input  wire         is_facing_left,

    // ============================================================
    //        DİĞER MODÜLE GİDEN HİTBOX KOORDİNATLARI
    // ============================================================
    output reg  [9:0]  player_hitbox_x, // assign kullanmayacağımız için wire yerine reg yaptık
    output reg  [9:0]  player_hitbox_y,
    output reg  [9:0]  player_hitbox_w,
    output reg  [9:0]  player_hitbox_h
);

    // ============================================================
    //                      PARAMETRELER
    // ============================================================
    localparam PLAYER_W = 10'd64; // Top_Module'deki gövde genişliği ile aynı olmalı
    
    // Kutu Boyutları
    localparam HITBOX_H = 10'd40;
    localparam HITBOX_W_BASIC = 10'd40;
    localparam HITBOX_W_SPECIAL = 10'd64;

    // Y Koordinatları (Top_Module zeminine uygun: Gövde 200'den başlıyor)
    localparam HITBOX_Y_BASIC = 10'd230;
    localparam HITBOX_Y_SPECIAL = 10'd210;

    // ============================================================
    //                      MANTIKSAL ATAMALAR (Kombinasyonel)
    // ============================================================
    always @(*) begin
        // 1. Önce her şeyi sıfırla (Latch/Mandallama hatasını önlemek için)
        player_hitbox_x = 10'd0;
        player_hitbox_y = 10'd0;
        player_hitbox_w = 10'd0;
        player_hitbox_h = 10'd0;

        // 2. Sadece saldırı durumlarında değerleri ata
        if (player_state == `s_default_attack) begin
            
            player_hitbox_w = HITBOX_W_BASIC;
            player_hitbox_y = HITBOX_Y_BASIC;
            player_hitbox_h = HITBOX_H;

            // Yöne Göre X Koordinatı
            if (is_facing_left) begin
                // Sola bakıyorsa kutu soldan çıkar (X'ten genişliği çıkar)
                player_hitbox_x = player_x - HITBOX_W_BASIC; 
            end else begin
                // Sağa bakıyorsa kutu sağdan çıkar (X'e karakter genişliğini ekle)
                player_hitbox_x = player_x + PLAYER_W; 
            end

        end else if (player_state == `s_special_attack) begin
            
            player_hitbox_w = HITBOX_W_SPECIAL;
            player_hitbox_y = HITBOX_Y_SPECIAL;
            player_hitbox_h = HITBOX_H;

            // Yöne Göre X Koordinatı
            if (is_facing_left) begin
                // Sola bakıyorsa kutu soldan çıkar
                player_hitbox_x = player_x - HITBOX_W_SPECIAL;
            end else begin
                // Sağa bakıyorsa kutu sağdan çıkar
                player_hitbox_x = player_x + PLAYER_W;
            end
        end
        // Eğer state IDLE, FORWARD vs. ise zaten en baştaki sıfırlama işlemi geçerli olur.
    end

endmodule