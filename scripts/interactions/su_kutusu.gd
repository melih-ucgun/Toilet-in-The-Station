extends StaticBody3D

@export var esya_adi: String = "Su Kutusu"
@export var ikon: Texture2D # <-- YENİ EKLENEN: İkon resmi için değişken

func etkilesim_yap(oyuncu):
	if oyuncu.has_method("envantere_ekle"):
		# Artık hem ismi hem de ikonu gönderiyoruz
		oyuncu.envantere_ekle(esya_adi, ikon)
		print(esya_adi + " alındı!")
		queue_free()
