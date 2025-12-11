extends CharacterBody3D

@export_group("Sahne Ayarları")
@export var su_damlasi_sahnesi: PackedScene

@export_group("Hareket Ayarları")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 40.0
@export var friction: float = 50.0
@export var jump_strength: float = 4.5
@export var gravity_force: float = 9.8 * 2 # ProjectSettings yerine manuel de verilebilir, seninki de doğru.

@export_group("Kamera ve Etkileşim")
@export var mouse_sensitivity: float = 0.002
@export var push_force: float = 2.0 # İtme gücü buraya taşındı

@export_group("Silah Ayarları")
@export var firlatma_gucu: float = 10.0
@export var atis_hizi: float = 0.2

@onready var camera: Camera3D = $Camera3D
@onready var interaction_ray: RayCast3D = $Camera3D/RayCast3D

var ates_edebilir: bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		camera.rotation.x -= event.relative.y * mouse_sensitivity
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))

func _physics_process(delta: float) -> void:
	# --- HAREKET ---
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var target_speed = walk_speed
	if Input.is_action_pressed("sprint"):
		target_speed = sprint_speed

	if direction:
		velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	# --- YERÇEKİMİ VE ZIPLAMA ---
	if not is_on_floor():
		velocity.y -= gravity_force * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength

	# --- ETKİLEŞİM ---
	if Input.is_action_just_pressed("interact"):
		check_interaction()

	move_and_slide() # Hareketi uygula

	# --- FİZİKSEL İTME (MOVE AND SLIDE SONRASI) ---
	if direction != Vector3.ZERO:
		push_rigid_bodies()

	# --- ATEŞ ETME ---
	if Input.is_action_pressed("fire") and ates_edebilir:
		shoot()

func push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody3D:
			var normal = collision.get_normal()
			# Sadece yatay itme uygula (Yere doğru itmeyi engelle)
			if normal.y < 0.5: 
				var push_dir = -normal
				push_dir.y = 0
				push_dir = push_dir.normalized()
				collider.apply_central_impulse(push_dir * push_force)

func shoot():
	if not su_damlasi_sahnesi:
		print("HATA: Su damlası sahnesi atanmamış!")
		return

	ates_edebilir = false
	var damla = su_damlasi_sahnesi.instantiate()
	
	# Düzeltme: Mermiyi sahne köküne ekle
	get_tree().current_scene.add_child(damla)
	
	# Mermiyi kameranın baktığı yerden ve yönden çıkar
	damla.global_position = camera.global_position - camera.global_transform.basis.z * 1.5
	damla.global_transform.basis = camera.global_transform.basis # Merminin yönünü kameraya eşitle
	
	damla.apply_central_impulse(-camera.global_transform.basis.z * firlatma_gucu)
	
	await get_tree().create_timer(atis_hizi).timeout
	ates_edebilir = true

func check_interaction():
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider.has_method("etkilesim_yap"):
			collider.etkilesim_yap()
