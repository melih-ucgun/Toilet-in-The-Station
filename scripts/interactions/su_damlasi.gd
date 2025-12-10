extends RigidBody3D

var leke_sahnesi = load("res://scenes/Leke/leke.tscn")

@onready var raycast: RayCast3D = $RayCast3D # RayCast düğümünü bağladık

func _ready():
	# Çarpışmaları algılaması için bu ayarların açık olması şart
	contact_monitor = true
	max_contacts_reported = 1
	
	# 5 saniye sonra yok olsun (Bellek temizliği)
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(_delta):
	# RayCast her zaman merminin gittiği yöne baksın
	if linear_velocity.length() > 0.1:
		# Hız vektörünü normalize et ve RayCast'in hedefi yap
		# (0.6 birim ileriye baksın)
		raycast.target_position = linear_velocity.normalized() * 0.6

func _on_body_entered(body):
	# 1. KENDİMİZİ VURMAYALIM
	if body is CharacterBody3D:
		return 

	# 2. HAREKETLİ NESNELERE (TOP GİBİ) LEKE YAPIŞTIRMA
	# Eğer çarptığımız şey bir RigidBody3D ise (yani Top ise),
	# leke hesaplaması yapma, sadece mermiyi yok et.
	# (Fizik motoru çarpışmayı algıladığı için top zaten itilecektir)
	if body is RigidBody3D:
		queue_free()
		return

	# 3. SU DOLDURMA KONTROLÜ (İlerde lazım olur diye)
	if body.has_method("su_doldur"):
		body.su_doldur(10)
		queue_free()
		return

	# 4. DUVARA LEKE YAPIŞTIRMA (Sadece Duvarlar İçin)
	# Buraya kadar geldiyse çarptığı şey duvardır (StaticBody).
	var normal = Vector3.UP
	
	if raycast and raycast.is_colliding():
		normal = raycast.get_collision_normal()
	elif linear_velocity.length() > 0:
		normal = -linear_velocity.normalized()
		
	spawn_decal(normal)
	queue_free()

func spawn_decal(normal_vector: Vector3):
	var leke = leke_sahnesi.instantiate()
	
	# ÖNEMLİ: get_tree().root yerine current_scene kullanmak daha sağlıklıdır.
	# Böylece bölüm değişirse lekeler de silinir.
	get_tree().current_scene.add_child(leke)
	
	leke.global_position = global_position
	
	# --- LEKEYİ DUVARA YAPIŞTIRMA MATEMATİĞİ ---
	# "look_at", nesnenin -Z eksenini hedefe çevirir.
	# Hedef noktamız: Şu anki pozisyon + Normal Vektörü.
	# Bu işlem lekenin "yüzünü" duvardan dışarı baktırır.
	
	# Eğer normal vektör tam yukarı veya aşağı bakıyorsa look_at hata verebilir, 
	# bu yüzden küçük bir kontrol veya güvenli bir up_vector kullanırız.
	if normal_vector.is_equal_approx(Vector3.UP) or normal_vector.is_equal_approx(Vector3.DOWN):
		leke.look_at(global_position + normal_vector, Vector3.RIGHT)
	else:
		leke.look_at(global_position + normal_vector, Vector3.UP)
	
	# Senin orijinal kodundaki döndürme (Leke modeline göre değişebilir)
	# Eğer leken duvara dik geliyorsa bunu kullanmaya devam et:
	leke.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
