extends StaticBody3D

# Aradığımız eşyanın adı (Senin kutudaki isimle AYNI olmalı)
@export var gerekli_anahtar: String = "Anahtar"

var kapi_acik_mi: bool = false

# Player kapıya bakıp 'E'ye basınca senin RayCast sistemin bunu çalıştırır
func etkilesim_yap(oyuncu):
	if kapi_acik_mi:
		print("Kapı zaten açık.")
		return

	# 1. Oyuncunun Player scriptinde o kontrol fonksiyonu var mı?
	if oyuncu.has_method("envanterde_var_mi"):
		
		# 2. Cebinde "Anahtar" var mı?
		if oyuncu.envanterde_var_mi(gerekli_anahtar):
			print("Kilit Açıldı! Hoş geldin.")
			kapiyi_ac()
		else:
			print("Kilitli! Şu lazım: " + gerekli_anahtar)
	else:
		print("HATA: Player scriptine 'envanterde_var_mi' fonksiyonunu eklememişsin!")

func kapiyi_ac():
	kapi_acik_mi = true
	# Kapıyı 1 saniyede 3 metre yukarı kaydır
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 3.0, 1.0).set_trans(Tween.TRANS_BOUNCE)
