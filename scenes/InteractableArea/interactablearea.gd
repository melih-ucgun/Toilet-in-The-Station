extends Area3D

signal on_interact

# Değişkeni tanımlıyoruz ama editörden beklemiyoruz
var hayalet_yazi: Label3D 
var player_in_range = false

func _ready():
	print("🔧 SİSTEM BAŞLATILIYOR...")
	
	# --- LABEL'I KOD İLE YARATIYORUZ (Editöre güvenmiyoruz) ---
	hayalet_yazi = Label3D.new()
	hayalet_yazi.text = " [ E ] "       # Ekranda ne yazacak
	hayalet_yazi.font_size = 64         # Kocaman olsun
	hayalet_yazi.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Bize dönsün
	hayalet_yazi.no_depth_test = true 
	hayalet_yazi.position.y = 2.0       # Kutunun tepesinde dursun
	hayalet_yazi.modulate = Color(1, 0, 0) # KIRMIZI olsun ki kesin görelim
	
	# Yarattığımız yazıyı sahneye ekliyoruz
	add_child(hayalet_yazi)
	
	# Başlangıçta gizliyoruz
	hayalet_yazi.visible = false
	print("✅ Label kod ile oluşturuldu ve sahneye eklendi!")

func _on_body_entered(body):
	if body.is_in_group("Player"): 
		print("👀 OYUNCU GÖZÜKTÜ! Yazı açılıyor...")
		player_in_range = true
		hayalet_yazi.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		print("👋 OYUNCU GİTTİ! Yazı kapanıyor...")
		player_in_range = false
		hayalet_yazi.visible = false

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		print("🔘 TUŞA BASILDI! Sinyal gidiyor...")
		on_interact.emit()
