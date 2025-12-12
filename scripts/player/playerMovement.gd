extends CharacterBody3D

# --- AYARLAR VE SAHNELER ---
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

@export_group("Silah Ayarları")
@export var firlatma_gucu: float = 10.0
@export var atis_hizi: float = 0.2

# --- NODE BAĞLANTILARI ---
@onready var camera: Camera3D = $Camera3D
@onready var interaction_ray: RayCast3D = $Camera3D/RayCast3D

# DİKKAT: Hotbar'ı kodla aramak yerine Inspector'dan sürükleyeceğiz.
# Bu sayede "Node not found" hatası almayacaksın.
@export var hotbar_container: HBoxContainer 

# --- ENVANTER DEĞİŞKENLERİ ---
var secili_slot_index: int = 0
# 6 slotluk boş envanter verisi
var envanter_verisi = [null, null, null, null, null, null]

var ates_edebilir: bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Eğer Hotbar'ı atamayı unuttuysan oyun çökmesin diye uyarı
	if hotbar_container == null:
		print("UYARI: Hotbar Container atanmamış! Lütfen Player Inspector'ına bak.")
	else:
		arayuzu_guncelle()

# --- GİRDİLER (Input) ---
func _unhandled_input(event: InputEvent) -> void:
	# Mouse ile Bakış
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		camera.rotation.x -= event.relative.y * mouse_sensitivity
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))

func _input(event: InputEvent) -> void:
	# Envanter Seçimi (Mouse Tekerleği)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			slot_degistir(-1) # Sola
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			slot_degistir(1)  # Sağa

	# Envanter Seçimi (Rakamlar 1-6)
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_6:
			secili_slot_index = event.keycode - KEY_1
			arayuzu_guncelle()

# --- FİZİK DÖNGÜSÜ ---
func _physics_process(delta: float) -> void:
	# Yön Girdisi
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Koşma Kontrolü
	var target_speed = walk_speed
	if Input.is_action_pressed("sprint"):
		target_speed = sprint_speed

	# Hareket ve Sürtünme
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	# Yerçekimi
	if not is_on_floor():
		velocity.y -= gravity_force * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength

	move_and_slide()

	# --- ETKİLEŞİMLER ---
	
	# "E" Tuşu ile Eşya Toplama
	if Input.is_action_just_pressed("interact"):
		check_interaction()
	
	# Nesneleri İtme (Top, Kutu vs.)
	if direction != Vector3.ZERO:
		push_rigid_bodies()

	# Ateş Etme
	if Input.is_action_pressed("fire") and ates_edebilir:
		shoot()

# --- FONKSİYONLAR ---

func check_interaction():
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		
		# Kutuya "Beni al" diyoruz. (self = Player)
		# Böylece kutu bizim 'envantere_ekle' fonksiyonumuzu çalıştırabilir.
		if collider.has_method("etkilesim_yap"):
			collider.etkilesim_yap(self)

func push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody3D:
			var normal = collision.get_normal()
			if normal.y < 0.5: # Sadece yanlardan it, üstüne çıkınca itme
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
	
	# Sahnenin köküne ekle (Child sorunu olmasın)
	get_tree().current_scene.add_child(damla)
	
	damla.global_position = camera.global_position - camera.global_transform.basis.z * 1.5
	damla.global_transform.basis = camera.global_transform.basis 
	damla.apply_central_impulse(-camera.global_transform.basis.z * firlatma_gucu)
	
	await get_tree().create_timer(atis_hizi).timeout
	ates_edebilir = true

# --- ENVANTER MANTIĞI ---

func slot_degistir(yon: int):
	secili_slot_index += yon
	# Döngüsel geçiş (Sondan başa, baştan sona)
	if hotbar_container:
		secili_slot_index = posmod(secili_slot_index, hotbar_container.get_child_count())
		arayuzu_guncelle()

func arayuzu_guncelle():
	if not hotbar_container: return # Hata koruması
	
	var slotlar = hotbar_container.get_children()
	
	for i in range(slotlar.size()):
		var slot = slotlar[i]
		
		# Veriyi al
		var veri = null
		if i < envanter_verisi.size():
			veri = envanter_verisi[i]
		
		# Görsel parçaları bul
		var icon_node = slot.get_node("Icon")
		var miktar_node = slot.get_node("Miktar")
		var secim_node = slot.get_node("SecimCercevesi") # DİKKAT: Slot içindeki isim bu olmalı!
		
		# Seçim Çerçevesi
		secim_node.visible = (i == secili_slot_index)
		
		# İkon ve Miktar
		if veri != null:
			icon_node.visible = true
			if veri["ikon"]: 
				icon_node.texture = veri["ikon"]
			
			miktar_node.text = str(veri["miktar"])
			miktar_node.visible = (veri["miktar"] > 1)
		else:
			icon_node.visible = false
			miktar_node.visible = false

# Kutu bu fonksiyonu çağıracak
func envantere_ekle(esya_adi: String, ikon_resmi = null):
	# 1. Zaten varsa üstüne ekle
	for slot in envanter_verisi:
		if slot != null and slot["isim"] == esya_adi:
			slot["miktar"] += 1
			arayuzu_guncelle()
			return

	# 2. Yoksa boş yere koy
	for i in range(envanter_verisi.size()):
		if envanter_verisi[i] == null:
			envanter_verisi[i] = {"isim": esya_adi, "miktar": 1, "ikon": ikon_resmi}
			arayuzu_guncelle()
			return
			
	print("Çanta Dolu!")
