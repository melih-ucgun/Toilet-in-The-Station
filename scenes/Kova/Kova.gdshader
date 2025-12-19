shader_type spatial;
render_mode cull_disabled, unshaded, depth_draw_always;

uniform vec4 su_rengi : source_color = vec4(0.0, 0.5, 0.9, 0.6); // Mavi
uniform float doluluk : hint_range(-2.0, 2.0) = 0.0; // Ayar çubuğu

// "Postacı" değişken: Veriyi vertex'ten fragment'a taşır
varying float yerel_yukseklik;

void vertex() {
    // BURASI ÇOK ÖNEMLİ!
    // Modelin kendi yerel koordinatını burada yakalıyoruz.
    // Senin modelin yan yattığı için Y yerine Z'yi alıyoruz.
    yerel_yukseklik = VERTEX.y; 
}

void fragment() {
    ALBEDO = su_rengi.rgb;
    ALPHA = su_rengi.a;

    // Yakaladığımız yerel yüksekliği kullanıyoruz
    // Kameradan veya dünyadan etkilenmez, sadece modele bakar.
    if (yerel_yukseklik > doluluk) {
        discard;
    }
}