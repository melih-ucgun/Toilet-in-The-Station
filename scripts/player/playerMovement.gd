extends CharacterBody3D

var su_damlasi_sahnesi = load("res://su_damlasi.tscn") # Dosya yolunu doğru seç
@export var firlatma_gucu = 10.0

@onready var camera: Camera3D = $Camera3D

@onready var interaction_ray: RayCast3D = $Camera3D/RayCast3D

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_strength: float = 4.5 # Biraz artırdım, daha tok hissettirsin
@export var mouse_sensitivity: float = 0.002

# --- YENİ EKLENEN DEĞİŞKENLER ---
@export var acceleration: float = 40.0  # Hızlanma ne kadar çabuk olsun?
@export var friction: float = 50.0      # Durma ne kadar çabuk olsun? (Sürtünme)
# --------------------------------
@export var atis_hizi: float = 0.2 # Saniyede kaç mermi atacağı (küçüldükçe hızlanır)
var ates_edebilir: bool = true     # Kilidin açık olup olmadığını kontrol eder

var gravity_force: float = ProjectSettings.get_setting("physics/3d/default_gravity")*2

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		rotation.y -= mouse_event.relative.x * mouse_sensitivity
		var new_pitch: float = camera.rotation.x - mouse_event.relative.y * mouse_sensitivity
		new_pitch = clamp(new_pitch, deg_to_rad(-80.0), deg_to_rad(80.0))
		camera.rotation.x = new_pitch

func _physics_process(delta: float) -> void:
	# Yön girdisi (WASD)
	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction: Vector3 = Vector3.ZERO

	if move_input.length() > 0.0:
		move_direction = (transform.basis * Vector3(move_input.x, 0.0, move_input.y)).normalized()

	# Yürüyüş / koşu hızı
	var current_speed: float = walk_speed
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
	
	# --- BURASI DEĞİŞTİ (İVME VE SÜRTÜNME MANTIĞI) ---
	
	if move_direction != Vector3.ZERO:
		# Eğer bir tuşa basılıyorsa: Yavaş yavaş o yöndeki hıza ulaş (Acceleration)
		# velocity.x değerini, hedeflenen hıza, acceleration * delta kadar yaklaştırır.
		velocity.x = move_toward(velocity.x, move_direction.x * current_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, move_direction.z * current_speed, acceleration * delta)
	else:
		# Eğer tuşa basılmıyorsa: Yavaş yavaş 0 hızına düş (Friction)
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		
	# --------------------------------------------------

	# Yerçekimi
	if not is_on_floor():
		velocity.y -= gravity_force * delta

	# Zıplama
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength

# Eğer "interact" tuşuna (E) basılırsa, aşağıdaki fonksiyonu çağır
	if Input.is_action_just_pressed("interact"):
		check_interaction()
	
	move_and_slide()
	
	# --- İTME KODU (SON HALİ) ---
	# Sadece oyuncu hareket etmeye çalışıyorsa itme gerçekleşsin.
	# Böylece topun üstünde dururken (hareket etmezken) kod çalışmaz ve seni fırlatmaz.
	if move_direction != Vector3.ZERO:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			
			if collision.get_collider() is RigidBody3D:
				var body = collision.get_collider()
				var push_force = 2.0 
				
				var normal = collision.get_normal()
				
				# normal.y < 0.5 ise (Yani cisme yanlardan çarpıyorsak)
				# Ve karakterimiz yerdeyse (Havadan düşerken itmesin)
				if normal.y < 0.5 and is_on_floor():
					var itis_yonu = -normal
					itis_yonu.y = 0 # Y eksenini sıfırla (havaya fırlatmayı engeller)
					itis_yonu = itis_yonu.normalized()
					
					body.apply_central_impulse(itis_yonu * push_force)
	# ----------------------------

# --- ATEŞ ETME MEKANİĞİ (OTOMATİK) ---
	# "is_action_pressed" basılı tutmayı algılar. "ates_edebilir" ise süreyi kontrol eder.
	if Input.is_action_pressed("fire") and ates_edebilir:
		
		# 1. Kilidi hemen kapat, tekrar ateş edemesin
		ates_edebilir = false
		
		# 2. Mermiden bir kopya yarat
		var damla = su_damlasi_sahnesi.instantiate()
		
		# 3. Mermiyi sahneye ekle
		get_parent().add_child(damla)
		
		# 4. Merminin çıkış pozisyonunu ayarla
		damla.global_position = $Camera3D.global_position - $Camera3D.global_transform.basis.z * 1.5
		
		# 5. Mermiyi fırlat
		var atis_yonu = -$Camera3D.global_transform.basis.z
		damla.apply_central_impulse(atis_yonu * firlatma_gucu)
		
		# 6. BEKLEME SÜRESİ
		# Belirlenen süre (atis_hizi) kadar bekle, sonra kilidi aç
		await get_tree().create_timer(atis_hizi).timeout
		ates_edebilir = true
	# --------------------------
	
func check_interaction():
	# Lazer bir şeye çarpıyor mu?
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		
		# Çarptığı şeyin "etkilesim_yap" özelliği var mı?
		if collider.has_method("etkilesim_yap"):
			collider.etkilesim_yap()
