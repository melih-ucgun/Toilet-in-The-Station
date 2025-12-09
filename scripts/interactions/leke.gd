extends Node3D

@onready var decal = $Decal # Decal node'unu alıyoruz

func _ready():
	# 5 saniye bekle
	await get_tree().create_timer(5.0).timeout
	
	# --- SİLİNME EFEKTİ (TWEEN) ---
	# Tween: Bir değeri A'dan B'ye yavaşça değiştiren animasyon aracıdır.
	var tween = create_tween()
	
	# Decal'in "albedo_mix" (Görünürlük) değerini 1'den 0'a çek (2 saniye sürsün)
	tween.tween_property(decal, "albedo_mix", 0.0, 2.0)
	
	# Animasyon bitince nesneyi tamamen sil
	tween.tween_callback(queue_free)
