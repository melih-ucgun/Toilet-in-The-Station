extends RigidBody3D

var leke_sahnesi = load("res://scenes/Leke/leke.tscn")
var raycast_ref: RayCast3D = null # Değişkeni boş başlatıyoruz

func _ready():
	# --- GÜVENLİ RAYCAST BULMA ---
	# İsmi "RayCast3D" de olsa "RayCast3D2" de olsa türünden bulur.
	for child in get_children():
		if child is RayCast3D:
			raycast_ref = child
			raycast_ref.enabled = true # Kodla zorla açıyoruz
			print("RayCast Bulundu!")
			break
	
	# Ayarlar
	contact_monitor = true
	max_contacts_reported = 1
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# 5 saniye sonra yok ol
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(_delta):
	# raycast_ref boşsa bu satırı atlar ve ÇÖKMEZ
	if raycast_ref and linear_velocity.length() > 0.1:
		raycast_ref.target_position = linear_velocity.normalized() * 0.6

func _on_body_entered(body):
	# 1. KENDİMİZİ VURMAYALIM
	if body is CharacterBody3D:
		return 

	# 2. HAREKETLİ NESNELERE (TOP GİBİ) LEKE YAPIŞTIRMA
	if body is RigidBody3D:
		queue_free()
		return

	# 3. SU DOLDURMA KONTROLÜ
	if body.has_method("su_doldur"):
		body.su_doldur(10)
		queue_free()
		return

	# 4. DUVARA LEKE YAPIŞTIRMA
	var normal = Vector3.UP
	
	# Burada 'raycast' yerine 'raycast_ref' kullanıyoruz
	if raycast_ref and raycast_ref.is_colliding():
		normal = raycast_ref.get_collision_normal()
	elif linear_velocity.length() > 0:
		normal = -linear_velocity.normalized()
		
	spawn_decal(normal)
	queue_free()

func spawn_decal(normal_vector: Vector3):
	var leke = leke_sahnesi.instantiate()
	
	# current_scene kullanarak ekliyoruz
	get_tree().current_scene.add_child(leke)
	
	leke.global_position = global_position
	
	# Lekenin yönünü duvara çevir
	if normal_vector.is_equal_approx(Vector3.UP) or normal_vector.is_equal_approx(Vector3.DOWN):
		leke.look_at(global_position + normal_vector, Vector3.RIGHT)
	else:
		leke.look_at(global_position + normal_vector, Vector3.UP)
	
	# Leke modeline göre düzeltme açısı
	leke.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
