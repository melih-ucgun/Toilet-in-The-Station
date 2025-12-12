extends Decal  # <-- Eskiden "extends Node3D" idi, şimdi "Decal" yaptık.

func _ready():
	# --- RASTGELELİK AYARLARI ---
	# Kendimizi rastgele çevirelim (Z ekseni Decal'in yüzey eksenidir)
	rotate_z(randf_range(0, 2 * PI))
	
	# 5 saniye bekle
	await get_tree().create_timer(5.0).timeout
	destroy_sequence()

func destroy_sequence():
	# Güvenlik kontrolü (silinmişse işlem yapma)
	if not is_instance_valid(self):
		return

	var tween = create_tween()
	
	# Artık "decal" değişkeni yok, "self" (kendimiz) var.
	# Decal'in şeffaflık ayarı "albedo_mix"tir.
	tween.tween_property(self, "albedo_mix", 0.0, 2.0)
	
	# İşlem bitince sil
	tween.tween_callback(queue_free)
