module game_logic (
    //DETAYLI YORUMLAR İÇİN EN ALTA BAK NEYİN NE İŞE YARADIĞI TANIMLAR VS
    //SORUN OLMA İHTİMALİ OLAN YERLERDE "DİKKAT" NOTLARI VAR. özellikle DİKKAT6'ya bir daha bakın açıklamaya
    // ============================================================
    //                    SİSTEM SİNYALLERİ
    // ============================================================
    input  wire        clk,
    input  wire        reset_n,
    input  wire        frame_tick,
    // ============================================================
    //                  Diğer modülden GELEN INPUTLAR
    // ============================================================
    // Global oyun durumu (Diğer modülün global FSM'i belirler):
    //   2'b00 = MENU        → bu modül uyur, çıkışlar sabit
    //   2'b01 = COUNTDOWN   → "3,2,1,START" ekranı, input alma
    //   2'b10 = FIGHT       → asıl oyun, bu modül aktif çalışır
    //   2'b11 = GAMEOVER    → maç bitti, karakterler donmuş
    input  wire [1:0]  game_state,
    input  wire        p1_left,
    input  wire        p1_right,
    input  wire        p1_attack_edge,
    input  wire        p1_attack_held,
    input  wire        p1_attack_release,

    input  wire        p2_left,
    input  wire        p2_right,
    input  wire        p2_attack_edge,
    input  wire        p2_attack_held,
    input  wire        p2_attack_release,    
    // ============================================================
    //                Diğer modüle GİDEN OUTPUTLAR (Render)
    // ============================================================
    // P1 karakterinin sol-üst köşesinin X koordinatı (0..639).
    output reg  [9:0]  p1_x,
    output reg  [9:0]  p2_x,
    
    // P1'in şu anki state'i, 4-bit (toplam 12 state, 4 bit yeterli).
    // Diğer modül bu state'e göre uygun sprite'ı seçer. Altta localparam state olarak tanımlılar
    output reg  [3:0]  p1_state,
    output reg  [3:0]  p2_state,
    // ============================================================
    //               Diğer modüle GİDEN OUTPUTLAR (Skor)
    // ============================================================
    output reg         round_end,
    // Round'u kim kazandı? round_end=1 olduğu cycle'da geçerli.
    //   2'b00 = DRAW   (simultaneous special, round resetlenir, skor değişmez)
    //   2'b01 = P1 KO  (P2'yi devirdi)
    //   2'b10 = P2 KO  (P1'i devirdi)
    output reg  [1:0]  round_winner,
    output wire [1:0]  p1_block_points,
    output wire [1:0]  p2_block_points,
    // ============================================================
    //  Diğer modüle GİDEN HİTBOX/HURTBOX KOORDİNATLARI (Debug görüntü)
    // ============================================================
    // Tüm kutular: sol-üst köşe (x,y) + genişlik w + yükseklik h.
    // 10-bit, hepsi pozitif değer.
    
    // P1 hurtbox: state'e bağlı olarak dinamik boyut.
    // Idle/yürüme'de normal, recovery'de genişlemiş (whiff-punish için).
    output wire [9:0]  p1_hurtbox_x,
    output wire [9:0]  p1_hurtbox_y, 
    output wire [9:0]  p1_hurtbox_w,
    output wire [9:0]  p1_hurtbox_h,

    // P1 hitbox: sadece ATK_ACTIVE / SP_ACTIVE state'lerinde aktif.
    output wire [9:0]  p1_hitbox_x,
    output wire [9:0]  p1_hitbox_y,
    output wire [9:0]  p1_hitbox_w,
    output wire [9:0]  p1_hitbox_h,
    
    // P1 hitbox şu an aktif mi? (yani çizilmeli mi)
    // Hitbox sadece active fazda görünür. Recovery'de kaybolur (hurtbox olur).
    output wire        p1_hitbox_active,
    
    // P2 için aynı kutular.
    output wire [9:0]  p2_hurtbox_x,
    output wire [9:0]  p2_hurtbox_y,
    output wire [9:0]  p2_hurtbox_w,
    output wire [9:0]  p2_hurtbox_h,

    output wire [9:0]  p2_hitbox_x,
    output wire [9:0]  p2_hitbox_y,
    output wire [9:0]  p2_hitbox_w,
    output wire [9:0]  p2_hitbox_h,

    output wire        p2_hitbox_active    
);

// State kodlamaları
localparam IDLE         = 4'd0;   // hareketsiz duruyor
localparam MOVING_FWD   = 4'd1;   // ileri yürüyor (rakibe doğru, +3 px/frame)
localparam MOVING_BWD   = 4'd2;   // geri yürüyor (rakipten uzağa, -2 px/frame)
                                  // NOT: bu state aynı zamanda "blok" anlamına gelir
localparam ATK_STARTUP  = 4'd3;   // basic attack başlangıcı (5 frame)
localparam ATK_ACTIVE   = 4'd4;   // basic attack aktif faz (2 frame), hitbox açık
localparam ATK_RECOVERY = 4'd5;   // basic attack toparlanma (17 frame), hurtbox uzar
localparam SP_STARTUP   = 4'd6;   // special attack başlangıcı (14 frame), ileri itme
localparam SP_ACTIVE    = 4'd7;   // special attack aktif (2 frame), hitbox açık
localparam SP_RECOVERY  = 4'd8;   // special attack toparlanma (31 frame)
localparam HITSTUN      = 4'd9;   // vuruldu, donmuş (16 frame)
localparam BLOCKSTUN    = 4'd10;  // blokladı, donmuş (14 frame)
localparam GUARD_BREAK  = 4'd11;  // kalkan kırıldı, uzun donmuş (34 frame)



//reg ve diğer parametre tanımları
localparam SCREEN_W = 640;
localparam SCREEN_H = 480;
localparam PLAYER_W = 64;
localparam PLAYER_H = 240;
localparam PLAYER_Y_OFFSET = 30;          // playerin ayakları ekranın en altından ne kadar yukarıda olacak...

localparam HITBOX_W_BASIC = 64;            // basic atak yaparken hitbox genişliği
localparam HITBOX_W_SPECIAL = 64;            // sp atak yaparken hitbox genişliği
localparam HITBOX_H = 80;                   // hitbox yüksekliği
localparam HITBOX_HEIGTH_DIFFERENCE = 140;     // basic attack ile sp attack yaparken hitboxların y eksenindeki konumları farklı. specialın basicten ne kadar yüksekte olduğunu gösteriyor bu

//DİKKAT4: VGA koordinat sisteminde Y üstten aşağıya artar. Ondan SCREEN_H (yani 480) - ... yazıldı HITBOX_Y_BASIC
localparam HITBOX_Y_BASIC = SCREEN_H - HITBOX_H - PLAYER_Y_OFFSET;            // basic atak yaparken hitbox sol üst köşe y'si
localparam HITBOX_Y_SPECIAL = SCREEN_H - HITBOX_H - PLAYER_Y_OFFSET - HITBOX_HEIGTH_DIFFERENCE;     

reg [3:0] p1_next_state, p2_next_state;
reg p1_lost_guard, p2_lost_guard = 0;
reg [9:0] p1_next_x, p2_next_x;
reg [4:0] p1_frame_counter, p2_frame_counter = 0; //default olarak 0'dan bbaşlıyor saymaya
reg p1_attack_type = (p1_state == SP_STARTUP) || (p1_state == SP_ACTIVE) || (p1_state == SP_RECOVERY); // herhangi bir special durum tespit edilirse
reg p2_attack_type = (p2_state == SP_STARTUP) || (p2_state == SP_ACTIVE) || (p2_state == SP_RECOVERY); // herhangi bir special durum tespit edilirse

// ============= HITBOX TANIMLARI ===================
assign p1_hitbox_x = p1_x + PLAYER_W / 2; // basic veya sp. atak yaparken hitbox sol üst köşe x kordinatı, playerin konumuna göre gelir
assign p2_hitbox_x = p2_x + PLAYER_W / 2; // DİKKAT3: burada hitbox P2 için sola uzanacak. x koordinatı tanımı bu şekilde ama FSM'de tanımlarken onun hitboxu için eksili ifade koymak gerek

assign p1_hitbox_y = p1_attack_type ? HITBOX_Y_SPECIAL : HITBOX_Y_BASIC; //1 ise special 0 ise basic
assign p2_hitbox_y = p2_attack_type ? HITBOX_Y_SPECIAL : HITBOX_Y_BASIC; //1 ise special 0 ise basic

assign p1_hitbox_w = p1_attack_type ? HITBOX_W_SPECIAL : HITBOX_W_BASIC; //1 ise special 0 ise basic
assign p2_hitbox_w = p2_attack_type ? HITBOX_W_SPECIAL : HITBOX_W_BASIC; //1 ise special 0 ise basic

assign p1_hitbox_h = HITBOX_H;
assign p2_hitbox_h = HITBOX_H;

assign p1_hitbox_active = (p1_state == ATK_ACTIVE) || (p1_state == SP_ACTIVE);
assign p2_hitbox_active = (p2_state == ATK_ACTIVE) || (p2_state == SP_ACTIVE);

// ============= HURTBOX TANIMLARI ===================
assign p1_hurtbox_x = p1_x;
assign p1_hurtbox_y = SCREEN_H - PLAYER_Y_OFFSET - PLAYER_H;  // tabandan da biraz boşluk. sol üst köşenin konumu bu dikkat et. p2 için de aynısı geçerli
assign p1_hurtbox_w = (p1_state == ATK_RECOVERY) ? PLAYER_W + HITBOX_W_BASIC :
                     (p1_state == SP_RECOVERY)  ? PLAYER_W + HITBOX_W_SPECIAL :
                                                  PLAYER_W;
assign p1_hurtbox_h = PLAYER_H; //DİKKAT2: burada böyle yapınca hurtbox oyuncu biraz elevationa sahip olduğu için ekranın en altından başlayabilir. ama sorun değil orayla kimsenin işi yok nolacak. p2 için de aynısı geçerli

assign p2_hurtbox_x = p2_x;
assign p2_hurtbox_y = SCREEN_H - PLAYER_Y_OFFSET - PLAYER_H; 
assign p2_hurtbox_w = (p2_state == ATK_RECOVERY) ? PLAYER_W + HITBOX_W_BASIC :
                     (p2_state == SP_RECOVERY)  ? PLAYER_W + HITBOX_W_SPECIAL :
                                                  PLAYER_W;
assign p2_hurtbox_h = PLAYER_H;

always @(posedge clk) begin //DİKKAT1: eğer sistem çalşırken saçmalamaya başlarsa buradaki clk sinyallerinden kaynaklı olabilr. hangi edge'e bakıldığı ve hangi saatin kullanıldığı önemli. mesela 60hz frame_tick yerine normal 50MHZ clk geliyor olabilr
    if (frame_tick) begin
        if (!reset_n) begin //reset gelirse sıfırla, öteki türlü kontrol yap.
            p1_x <= 0;
            p2_x <= 0;

            p1_state <= IDLE;
            p2_state <= IDLE;

            round_end <= 0;
            round_winner <= 2'b00;

            p1_block_points <= 2'b11;
            p2_block_points <= 2'b11;       
        end
        else begin
            p1_state <= p1_next_state;
            p2_state <= p2_next_state;
            // pozisyon güncellemeleri buraya:
            p1_x <= p1_next_x;
            p2_x <= p2_next_x;
        end
    end
end


/*
    output reg KO_flag,                                 // knocked-out output flag
    output reg [2:0] current_state,                     // state indicator according to localparam below
    output reg [6:0] frame_tick,								  // frame tick counter output
*/


always @(*) begin
    // varsayılan: aynı state'te kal
    p1_next_state = p1_state;
    p1_next_x = p1_x;
    
    case (p1_state)
        IDLE: begin
            if (p1_attack_edge) p1_next_state = ATK_STARTUP;
            else if (p1_attack_release) p1_next_state = SP_STARTUP;
            else if (p1_right)         p1_next_state = MOVING_FWD;
            else if (p1_left)          p1_next_state = MOVING_BWD;
        end
        MOVING_FWD: begin
            if ((p1_x + PLAYER_W) + 3 <= p2_x)  //  <=   işareti nonblocking de olur küçük eşittir de olur. burda küçük eşittir oluyr çünkü koşul içinde
                p1_next_x = p1_x + 3; // eğer çarpmıyorlarsa ileri git. p1 in sağ kenarı ile p2 nin sol kenarı karşılaştırılır
            else 
                p1_next_x = p2_x - PLAYER_W; // çarpacaklarsa 3 birim ileri gitme, onun yerine p2'ye kenarı tam yapıştır. -PLAYER_W geldi çünkü p1 next x p1 in sol kenarı

            if (p1_attack_edge) p1_next_state = ATK_STARTUP;
            else if (p1_attack_release) p1_next_state = SP_STARTUP;
            else if (p1_left)          p1_next_state = MOVING_BWD;
            else if (!p1_right)         p1_next_state = IDLE;            
        end
        MOVING_BWD: begin
            //DİKKAT5: şimdi bu statede hit yiyebilir ama block point azaltmayı burada yapmadım. hit yiyen kişi mesela bu statede hit yediğinde de b.p. azalabilir. veya vuran kişinin vurma statein'de de azaltılabilir. ama neticede tek bir yerde azalması lazım o da atk active'de yapılıyor. ama burada hit yerse o zaman block pointinin kaç tane kaldığına göre hitstun, blockstun, guard break durumlarına gidiyor
            if (p1_x - 2 >= 0)  //  ekrandan taşmasın
                p1_next_x = p1_x - 2; // eğer çarpmıyorlarsa ileri git. p1 in sağ kenarı ile p2 nin sol kenarı karşılaştırılır
            else 
                p1_next_x = 0; // ekrandan taşmadan en sola yapış

            if (p1_attack_edge) p1_next_state = ATK_STARTUP;
            else if (p1_attack_release) p1_next_state = SP_STARTUP;
            else if (p1_right)         p1_next_state = MOVING_FWD;            
            else if (!p1_left)          p1_next_state = IDLE;
        end        
        /*
        ATK_STARTUP: begin
            ÜSTTEN ALINACAK
        end
        */
        ATK_ACTIVE: begin // hitbox aktif, 2 frame say ve sayacı sıfırlayıp atk recovere geç
            p1_hitbox_active = 1;
            //=========================================================
            //                      HIT DETECTION
            //=========================================================
            //DİKKAT6: burada b.p. sıfırdan büyükken tamam 1 azalıyor. tam sıfır olduğunda da guard breake girecek. ama b.p. 0 iken guard break'e de 1 kere girdikten sonra mesela bir kere daha hit yerse o zaman yine mi guard break'e girecek yoksa hitstun'a mı? KO olamaz çünkü KO için special şart. şu an bu logic'de şey var mesela 3 hit yedi b.p. kalmadı. eğer block yaparken 4.kez vurulursa guard break'e giriyor. b.p. 0 iken block yapmadan vurulursa hitstuna giriyor.        
            //          ikisi aynı anda birbirine basic attack vurursa ikisi de hitstuna girecek. eğer biri basic vururken diğeri special vurusa KO
            if ((p1_hitbox_x + HITBOX_W_BASIC >= p2_hurtbox_x) && !(p2_state == MOVING_BWD || p2_state == ATK_ACTIVE || p2_state == SP_ACTIVE)) // p2 geri geri gitmezken yani kalkanı yokken vurdu. bu vurulduğu durum soldaki statementda bulunan durumlar hariç herhangi bir şey olabilir. idle, moving bwd, atk startup (belki karşıdaki de vurmaya hazırlanıyordu o anda)
                
                if ((p2_block_points >= 1) && !p2_lost_guard) begin // b.p. 0 dan büyük ve henüz guardını kaybetmemiş
                    //p2_block_points = p2_block_points - 1;
                    p2_next_state = HITSTUN;                
                end
                else if ((p2_block_points = 0) && !p2_lost_guard) begin
                    p2_lost_guard = 1;
                    p2_next_state = GUARD_BREAK;                
                end
                else if (p2_lost_guard) begin
                    p2_next_state = HITSTUN;
                end
            end

            if ((p1_hitbox_x + HITBOX_W_BASIC >= p2_hurtbox_x) && p2_state == MOVING_BWD) begin // p2 geri geri giderken kalkanı varken vurdu

                if ((p2_block_points >= 1) && !p2_lost_guard) begin // b.p. 0 dan büyük ve henüz guardını kaybetmemiş
                    p2_block_points = p2_block_points - 1;
                    p2_next_state = BLOCKSTUN;                
                end
                else if ((p2_block_points = 0) && !p2_lost_guard) begin
                    p2_lost_guard = 1;
                    p2_next_state = GUARD_BREAK;                
                end
                else if (p2_lost_guard) begin
                    p2_next_state = GUARD_BREAK;
                end
            end


            if (frame_tick) begin
                p1_frame_counter = 0;
                if (p1_frame_counter < 2)
                    p1_frame_counter = p1_frame_counter + 1;
                else if (p1_frame_counter = 2)
                    p1_frame_counter = 0;                    
                    p1_next_state = ATK_ACTIVE;
            end          
        end

    endcase
end



































endmodule


/*

    // ============================================================
    //                    SİSTEM SİNYALLERİ
    // ============================================================
    
    // Ana FPGA clock, 50 MHz. Tüm register'lar bu clock'la güncellenir.
    // Ama oyun mantığı sadece frame_tick aktif olduğunda işler.
    input  wire        clk,
    
    // Aktif-low senkron reset. Modüldeki tüm state'leri başlangıç
    // değerine döndürür (karakterler başlangıç pozisyonuna, state IDLE,
    // block point 3, round_winner 0, vs.)
    input  wire        reset_n,
    
    // 60 Hz pulse — VGA modülünden gelir.
    // Saniyede 60 kez sadece 1 clock cycle boyunca 1 olur, sonra 0.
    // Karakter hareketi, attack frame sayaçları, state geçişleri
    // SADECE bu sinyal 1 iken işlenir. Manuel: "Game logic runs with
    // a 60 Hz clock... character state changes occur solely between
    // consecutive frames."
    input  wire        frame_tick,
    
    // ============================================================
    //                  Diğer modülden GELEN INPUTLAR
    // ============================================================
    
    // Global oyun durumu (Diğer modülün global FSM'i belirler):
    //   2'b00 = MENU        → bu modül uyur, çıkışlar sabit
    //   2'b01 = COUNTDOWN   → "3,2,1,START" ekranı, input alma
    //   2'b10 = FIGHT       → asıl oyun, bu modül aktif çalışır
    //   2'b11 = GAMEOVER    → maç bitti, karakterler donmuş
    input  wire [1:0]  game_state,
    
    // P1 buton sinyalleri (debouncer geçmiş, temiz sinyaller).
    // Diğer modülün debouncer modülünden gelir.
    
    // Sol butonu BASILI mı? Level sinyali (1 = basılı, 0 = serbest).
    // Karakterin geri yürümesi için (P1 solda olduğu için sol = geri).
    input  wire        p1_left,
    
    // Sağ butonu BASILI mı? Level sinyali.
    // P1 için ileri yürüme (rakibe doğru).
    input  wire        p1_right,
    
    // Attack butonuna basılma ANI. 1 frame pulse (edge detect).
    // Manuel: "you are checking for the press of the button... 
    // If a player holds the button down the character should not 
    // continuously attack." Basic attack tetiklemek için bu kullanılır.
    input  wire        p1_attack_edge,
    
    // Attack butonu ŞU AN basılı mı? Level sinyal.
    // Special attack charge süresini sayabilmek için lazım.
    // Aslında bu modülde direkt kullanmayabilirsin — Diğer modül zaten
    // charge süresini sayıp p1_attack_release sinyali olarak iletecek.
    // Yine de debug için tutmakta fayda var.
    input  wire        p1_attack_held,
    
    // Attack butonu YETERLİ SÜRE basılı tutulup BIRAKILDIĞINDA
    // gelen 1 frame pulse. Yani charge tamamlanmış + butona bırakılmış.
    // Bu sinyal geldiğinde special attack tetiklenir.
    // Eğer kullanıcı yeterince basılı tutmadan bıraktıysa Diğer modül bu
    // sinyali ÜRETMEZ, yani burada görmezsin.
    input  wire        p1_attack_release,
    
    // P2 için tamamen aynı sinyaller. P2 sağda olduğu için:
    //   p2_left  = ileri yürüme (rakibe doğru, sola)
    //   p2_right = geri yürüme (rakipten uzaklaş, sağa)
    input  wire        p2_left,
    input  wire        p2_right,
    input  wire        p2_attack_edge,
    input  wire        p2_attack_held,
    input  wire        p2_attack_release,
    
    // ============================================================
    //                Diğer modüle GİDEN OUTPUTLAR (Render)
    // ============================================================
    
    // P1 karakterinin sol-üst köşesinin X koordinatı (0..639).
    // VGA çözünürlüğü 640×480 olduğu için 10-bit kullanıyoruz.
    // Her frame_tick'te state'e göre güncellenebilir.
    output reg  [9:0]  p1_x,
    
    // P2 karakterinin sol-üst köşesinin X koordinatı.
    output reg  [9:0]  p2_x,
    
    // P1'in şu anki state'i, 4-bit (toplam 12 state, 4 bit yeterli).
    // Diğer modül bu state'e göre uygun sprite'ı seçer.
    output reg  [3:0]  p1_state,
    output reg  [3:0]  p2_state,

    // ============================================================
    //               Diğer modüle GİDEN OUTPUTLAR (Skor)
    // ============================================================
    
    // Round bittiği anda 1 frame pulse. Diğer modül bu sinyali görünce
    // round_winner'a bakıp skor sayacını günceller, sonra global
    // FSM'i COUNTDOWN'a alıp yeni round başlatır.
    // KO veya simultaneous special hit (draw) durumunda 1 olur.
    output reg         round_end,
    
    // Round'u kim kazandı? round_end=1 olduğu cycle'da geçerli.
    //   2'b00 = DRAW   (simultaneous special, round resetlenir, skor değişmez)
    //   2'b01 = P1 KO  (P2'yi devirdi)
    //   2'b10 = P2 KO  (P1'i devirdi)
    output reg  [1:0]  round_winner,
    
    // P1'in kalan block point'i. 0..3 arası, 2-bit yeterli.
    // Diğer modül bu değeri HUD olarak ekranın üst kısmında göstermeli
    // (manuel: "Remaining block points for each player should be visible").
    // Her round başında 3'e resetlenir.
    output wire [1:0]  p1_block_points,
    output wire [1:0]  p2_block_points,

    // ============================================================
    //  Diğer modüle GİDEN HİTBOX/HURTBOX KOORDİNATLARI (Debug görüntü)
    // ============================================================
    // SW[0] açık ise Diğer modül bu kutuları sarı/kırmızı dikdörtgen
    // olarak ekrana çizer. SW[0] kapalıysa yok sayılır.
    // Tüm kutular: sol-üst köşe (x,y) + genişlik w + yükseklik h.
    // 10-bit, hepsi pozitif değer.
    
    // P1 hurtbox: state'e bağlı olarak dinamik boyut.
    // Idle/yürüme'de normal, recovery'de genişlemiş (whiff-punish için).
    output wire [9:0]  p1_hurtbox_x,
    output wire [9:0]  p1_hurtbox_y,
    output wire [9:0]  p1_hurtbox_w,
    output wire [9:0]  p1_hurtbox_h,
    
    // P1 hitbox: sadece ATK_ACTIVE / SP_ACTIVE state'lerinde aktif.
    output wire [9:0]  p1_hitbox_x,
    output wire [9:0]  p1_hitbox_y,
    output wire [9:0]  p1_hitbox_w,
    output wire [9:0]  p1_hitbox_h,
    
    // P1 hitbox şu an aktif mi? (yani çizilmeli mi)
    // Hitbox sadece active fazda görünür. Recovery'de kaybolur (hurtbox olur).
    output wire        p1_hitbox_active,
    
    // P2 için aynı kutular.
    output wire [9:0]  p2_hurtbox_x,
    output wire [9:0]  p2_hurtbox_y,
    output wire [9:0]  p2_hurtbox_w,
    output wire [9:0]  p2_hurtbox_h,
    output wire [9:0]  p2_hitbox_x,
    output wire [9:0]  p2_hitbox_y,
    output wire [9:0]  p2_hitbox_w,
    output wire [9:0]  p2_hitbox_h,
    output wire        p2_hitbox_active    

*/