extends RigidBody3D

# --- GÖRSEL AYARLAR ---
@onready var su_mesh = get_node_or_null("SuMesh") 

# AYARLAR
var max_su_kapasitesi: int = 100
var su_miktari: int = 0

# --- SHADER AYARLARI ---
# Deneme yanılma ile bulduğun değerler:
var shader_bos_seviye: float = -0.7 
var shader_dolu_seviye: float = 0.5

func _ready():
	print("Kova hazır. Başlangıç suyu: ", su_miktari)
	# Başlangıçta görüntüyü güncelle (0 su - animasyonsuz)
	gorseli_guncelle(false) 

# --- MERMİ BU FONKSİYONU ÇAĞIRIR (SU DOLDURMA) ---
func su_doldur(miktar: int):
	if su_miktari >= max_su_kapasitesi:
		return
	
	su_miktari += miktar
	
	# Taşmayı engelle
	if su_miktari > max_su_kapasitesi:
		su_miktari = max_su_kapasitesi
	
	print("Kova Doluyor... Seviye: ", su_miktari)
	gorseli_guncelle(true) # true = animasyonlu yüksel

# --- PLAYER BU FONKSİYONU ÇAĞIRIR (SU ALMA) ---
func su_ver(istenen_miktar: int) -> int:
	if su_miktari <= 0:
		return 0
	
	var verilecek = min(istenen_miktar, su_miktari)
	su_miktari -= verilecek
	
	print("Kovadan su alındı. Kalan: ", su_miktari)
	gorseli_guncelle(true)
	
	return verilecek

# --- GÖRSEL GÜNCELLEME (GÜNCELLENMİŞ HALİ) ---
func gorseli_guncelle(animasyonlu: bool = true):
	if not su_mesh: return
	
	# [ 1. ADIM: GÖRÜNMEZLİK KİLİDİ ]
	# Eğer su yoksa veya çok çok azsa, objeyi tamamen gizle.
	# Böylece dipteki yeşil kapak görüntüsü veya gölgeler asla görünmez.
	if su_miktari <= 0.1:
		su_mesh.visible = false
		return # Su yoksa aşağıyı hesaplama, çık.
	else:
		su_mesh.visible = true # Su varsa görünür yap.
	
	# [ 2. ADIM: MATERYAL KONTROLÜ ]
	# Materyali al (Shader'a ulaşmak için)
	var materyal = su_mesh.get_active_material(0)
	if not materyal:
		print("HATA: SuMesh üzerinde materyal yok!")
		return

	# [ 3. ADIM: ORAN HESAPLAMA ]
	# 0 ile 1 arasında bir oran bul
	var oran = float(su_miktari) / float(max_su_kapasitesi)
	
	# [ 4. ADIM: SHADER SEVİYESİ ]
	# Boş ile Dolu seviye arasında, oran kadar git (Lerp)
	var hedef_seviye = lerp(shader_bos_seviye, shader_dolu_seviye, oran)
	
	# [ 5. ADIM: GÖNDERME ]
	if animasyonlu:
		# Tween ile akıcı geçiş yap
		var tween = create_tween()
		tween.tween_property(materyal, "shader_parameter/doluluk", hedef_seviye, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		# Animasyonsuz direkt ayarla (Oyun başında)
		materyal.set_shader_parameter("doluluk", hedef_seviye)
