extends RigidBody3D

var leke_sahnesi = load("res://leke.tscn")

func _ready():
	# 5 saniye sonra yok olsun
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _on_body_entered(body):
	
	# --- KENDİMİZİ VURMAYALIM ---
	# Eğer çarptığımız şey "CharacterBody3D" (yani bizsek) hiçbir şey yapma.
	if body is CharacterBody3D:
		return 
	# ----------------------------

	if body.has_method("su_doldur"):
		body.su_doldur(10)
		queue_free()
	else:
		spawn_decal()
		queue_free()

func spawn_decal():
	var leke = leke_sahnesi.instantiate()
	get_tree().root.add_child(leke)
	leke.global_position = global_position
	
	# Lekeyi duvara çevir
	if linear_velocity.length() > 0.1:
		leke.look_at(global_position + linear_velocity, Vector3.UP)
		leke.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
