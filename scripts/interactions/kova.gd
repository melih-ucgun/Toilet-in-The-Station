extends RigidBody3D

# --- GÖRSEL AYARLAR ---
@onready var su_mesh = get_node_or_null("SuMesh") 

# AYARLAR
var max_su_kapasitesi: int = 100
var su_miktari: int = 0

# Görsel ayarlar (Kovanın boyutuna göre)
var max_yukseklik: float = 1.0 # Suyun max scale değeri
var dip_noktasi: float = -0.45 # Kovanın en dibi (Y pozisyonu)

func _ready():
	if su_mesh:
		# Başlangıçta suyu görsel olarak sıfırla
		su_mesh.scale.y = 0.01 
		su_mesh.position.y = dip_noktasi 
		su_mesh.visible = true
	
	print("Kova hazır. Su: ", su_miktari)

# --- MERMİ BU FONKSİYONU ÇAĞIRIR (SU DOLDURMA) ---
func su_doldur(miktar: int):
	if su_miktari >= max_su_kapasitesi:
		return
	
	su_miktari += miktar
	
	# Taşmayı engelle
	if su_miktari > max_su_kapasitesi:
		su_miktari = max_su_kapasitesi
	
	print("Kova Doluyor... Seviye: ", su_miktari)
	gorseli_guncelle()

# --- PLAYER BU FONKSİYONU ÇAĞIRIR (SU ALMA) ---
# (Bunu unutmuşsun, geri ekledim!)
func su_ver(istenen_miktar: int) -> int:
	if su_miktari <= 0:
		return 0
	
	var verilecek = min(istenen_miktar, su_miktari)
	su_miktari -= verilecek
	
	print("Kovadan su alındı. Kalan: ", su_miktari)
	gorseli_guncelle()
	
	return verilecek

# --- GÖRSEL GÜNCELLEME (ORTAK FONKSİYON) ---
func gorseli_guncelle():
	if not su_mesh: return
	
	# 1. Hedef Boyut (0 ile 1 arası oranla hesapla)
	var oran = float(su_miktari) / float(max_su_kapasitesi)
	var hedef_scale = oran * max_yukseklik
	if hedef_scale < 0.01: hedef_scale = 0.01
	
	# 2. Hedef Pozisyon (Pivot Düzeltme)
	# Silindir ortadan büyüdüğü için yukarı kaydırıyoruz
	var hedef_pozisyon = dip_noktasi + (hedef_scale * 1.0) 
	
	# 3. Animasyon
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(su_mesh, "scale:y", hedef_scale, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(su_mesh, "position:y", hedef_pozisyon, 0.3)
