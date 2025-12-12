extends CharacterBody3D

# --- AYARLAR ---
@export var max_su_deposu: int = 50
var mevcut_su: int = 50

# --- UI BAĞLANTILARI ---
@export_group("UI Ayarları")
@export var su_bari: ProgressBar       # <-- EKSİKTİ, EKLENDİ (Inspector'dan ata!)
@export var hotbar_container: HBoxContainer # <-- Inspector'dan ata!

@export_group("Sahne Ayarları")
@export var su_damlasi_sahnesi: PackedScene

@export_group("Hareket Ayarları")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 40.0
@export var friction: float = 50.0
@export var jump_strength: float = 4.5
@export var gravity_force: float = 9.8 * 2

@export_group("Kamera ve Etkileşim")
@export var mouse_sensitivity: float = 0.002
@export var push_force: float = 2.0
@export var firlatma_gucu: float = 10.0
@export var atis_hizi: float = 0.2

# --- NODE BAĞLANTILARI ---
@onready var camera: Camera3D = $Camera3D
@onready var interaction_ray: RayCast3D = $Camera3D/RayCast3D

# --- ENVANTER DEĞİŞKENLERİ ---
var secili_slot_index: int = 0
var envanter_verisi = [null, null, null, null, null, null]
var ates_edebilir: bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 1. Envanter Kontrolü
	if hotbar_container:
		envanter_arayuzunu_guncelle()
	else:
		print("UYARI: Hotbar Container atanmamış!")

	# 2. Su Barı Kontrolü (YENİ EKLENDİ)
	mevcut_su = max_su_deposu
	if su_bari:
		su_bari.max_value = max_su_deposu
		su_bari.value = mevcut_su
	else:
		print("UYARI: Su Barı (ProgressBar) atanmamış!")

# --- GİRDİLER ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		camera.rotation.x -= event.relative.y * mouse_sensitivity
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))

func _input(event: InputEvent) -> void:
	# Mouse Tekerleği ile Slot Değişimi
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			slot_degistir(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			slot_degistir(1)

	# Rakamlarla Slot Değişimi
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_6:
			secili_slot_index = event.keycode - KEY_1
			envanter_arayuzunu_guncelle()

# --- FİZİK ---
func _physics_process(delta: float) -> void:
	# Hareket
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var target_speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	if direction:
		velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	if not is_on_floor():
		velocity.y -= gravity_force * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength

	move_and_slide()

	# Etkileşimler
	if Input.is_action_just_pressed("interact"):
		check_interaction()
	
	if direction != Vector3.ZERO:
		push_rigid_bodies()

	if Input.is_action_pressed("fire") and ates_edebilir:
		shoot()

# --- FONKSİYONLAR ---

func check_interaction():
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		
		# Eşya Toplama
		if collider.has_method("etkilesim_yap"):
			collider.etkilesim_yap(self)
			return

		# Su Doldurma
		if collider.has_method("su_ver"):
			var eksik_su = max_su_deposu - mevcut_su
			if eksik_su <= 0: return
			
			var alinan = collider.su_ver(eksik_su)
			if alinan > 0:
				mevcut_su += alinan
				su_bari_guncelle() # <-- EKSİKTİ, EKLENDİ

func shoot():
	if not su_damlasi_sahnesi: return
	if mevcut_su <= 0:
		print("Su bitti!")
		return
	
	# Mermi Azaltma
	mevcut_su -= 1
	su_bari_guncelle() # <-- EKSİKTİ, EKLENDİ
	
	ates_edebilir = false
	
	var damla = su_damlasi_sahnesi.instantiate()
	get_tree().current_scene.add_child(damla)
	damla.global_position = camera.global_position - camera.global_transform.basis.z * 1.5
	damla.global_transform.basis = camera.global_transform.basis 
	damla.apply_central_impulse(-camera.global_transform.basis.z * firlatma_gucu)
	
	await get_tree().create_timer(atis_hizi).timeout
	ates_edebilir = true

func push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			var normal = collision.get_normal()
			if normal.y < 0.5:
				var push_dir = -normal
				push_dir.y = 0
				collider.apply_central_impulse(push_dir.normalized() * push_force)

# --- UI GÜNCELLEME ---

func su_bari_guncelle():
	if su_bari:
		su_bari.value = mevcut_su # Barı anlık güncelle

func slot_degistir(yon: int):
	secili_slot_index += yon
	if hotbar_container:
		secili_slot_index = posmod(secili_slot_index, hotbar_container.get_child_count())
		envanter_arayuzunu_guncelle()

func envanter_arayuzunu_guncelle():
	if not hotbar_container: return
	
	var slotlar = hotbar_container.get_children()
	for i in range(slotlar.size()):
		var slot = slotlar[i]
		var veri = envanter_verisi[i] if i < envanter_verisi.size() else null
		
		# Node'ları bul (İsimlerin Godot ile aynı olduğundan emin ol!)
		var icon_node = slot.get_node("Icon")
		var miktar_node = slot.get_node("Miktar")
		var secim_node = slot.get_node("SecimCercevesi")
		
		secim_node.visible = (i == secili_slot_index)
		
		if veri:
			icon_node.visible = true
			icon_node.texture = veri["ikon"]
			miktar_node.text = str(veri["miktar"])
			miktar_node.visible = (veri["miktar"] > 1)
		else:
			icon_node.visible = false
			miktar_node.visible = false

func envantere_ekle(esya_adi: String, ikon_resmi = null):
	# Önce var olan slotu kontrol et
	for slot in envanter_verisi:
		if slot != null and slot["isim"] == esya_adi:
			slot["miktar"] += 1
			envanter_arayuzunu_guncelle()
			return

	# Yoksa boş slota ekle
	for i in range(envanter_verisi.size()):
		if envanter_verisi[i] == null:
			envanter_verisi[i] = {"isim": esya_adi, "miktar": 1, "ikon": ikon_resmi}
			envanter_arayuzunu_guncelle()
			return
