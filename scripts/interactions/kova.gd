extends RigidBody3D

@onready var su_mesh = get_node_or_null("SuMesh") 

# AYARLAR (Bunları kovanın boyutuna göre deneme yanılma ile bulacağız)
var max_yukseklik: float = 1.0 # Suyun ulaşacağı maksimum görsel yükseklik (Scale)
var su_miktari: float = 0.0    # 0 ile 100 arası

func _ready():
	if su_mesh:
		# Başlangıçta suyu neredeyse yok et
		su_mesh.scale.y = 0.01 
		# Suyun pozisyonunu kovanın en dibine çek (Burası önemli!)
		# Eğer kovanın merkezi (0,0,0) ise, dibi yaklaşık -0.5 civarıdır.
		# Bunu editörden bakıp ayarlamak en iyisidir ama kodla şöyle deneyelim:
		su_mesh.position.y = -0.45 
		su_mesh.visible = true

func su_doldur(miktar):
	if su_miktari >= 100: return
	
	su_miktari += miktar
	print("Su Seviyesi: ", su_miktari)
	
	if su_mesh:
		# 1. HEDEF BOYUTU HESAPLA
		var hedef_scale = (su_miktari / 100.0) * max_yukseklik
		if hedef_scale < 0.01: hedef_scale = 0.01
		
		# 2. HEDEF POZİSYONU HESAPLA (PİVOT DÜZELTME)
		# Silindir ortadan büyüdüğü için, boyu ne kadar artarsa,
		# yarısı kadar yukarı kaldırmalıyız ki tabanı sabit kalsın.
		# Başlangıç dip noktası (-0.45) + (Boyun Yarısı)
		var dip_noktasi = -0.45
		var hedef_pozisyon = dip_noktasi + (hedef_scale * 1.0) # 1.0 silindirin varsayılan boyu varsayımıyla
		
		# 3. ANİMASYON (TWEEN)
		var tween = create_tween()
		tween.set_parallel(true) # Aynı anda çalışsınlar
		tween.tween_property(su_mesh, "scale:y", hedef_scale, 0.3)
		tween.tween_property(su_mesh, "position:y", hedef_pozisyon, 0.3)
