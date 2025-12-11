extends Node3D

@onready var decal: Decal = $Decal

func _ready():
	# --- 1. RASTGELELİK EKLE (Daha doğal görünüm) ---
	
	# Rastgele Boyut: %80 ile %120 arasında rastgele büyüklük
	var random_scale = randf_range(0.8, 1.2)
	scale = Vector3(random_scale, random_scale, random_scale)
	
	# Rastgele Dönüş: Kendi ekseni etrafında rastgele çevir (Z ekseni)
	# Decal duvara yapıştığında "saat yönünde" rastgele döner.
	rotate_z(randf_range(0, 2 * PI))
	
	# -----------------------------------------------

	# 5 saniye bekle
	await get_tree().create_timer(5.0).timeout
	destroy_sequence()

func destroy_sequence():
	# Eğer obje zaten silinme sürecindeyse veya yoksa hata vermesin
	if not is_instance_valid(decal):
		queue_free()
		return

	var tween = create_tween()
	
	# Decal'in "albedo_mix" değerini 1'den 0'a çek (Solma Efekti)
	tween.tween_property(decal, "albedo_mix", 0.0, 2.0)
	
	# Tween bitince nesneyi tamamen sil
	tween.tween_callback(queue_free)
