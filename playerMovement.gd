extends CharacterBody3D

@onready var camera: Camera3D = $Camera3D

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_strength: float = 3.5
@export var mouse_sensitivity: float = 0.002

var gravity_force: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion

		# Yaw (sağa–sola bakış) → gövdeye
		rotation.y -= mouse_event.relative.x * mouse_sensitivity

		# Pitch (yukarı–aşağı bakış) → kameraya
		var new_pitch: float = camera.rotation.x - mouse_event.relative.y * mouse_sensitivity
		new_pitch = clamp(new_pitch, deg_to_rad(-80.0), deg_to_rad(80.0))
		camera.rotation.x = new_pitch


func _physics_process(delta: float) -> void:
	# Yön girdisi (WASD)
	var move_input: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
        "move_back"
	)

	var move_direction: Vector3 = Vector3.ZERO

	if move_input.length() > 0.0:
		move_direction = (transform.basis * Vector3(move_input.x, 0.0, move_input.y)).normalized()

	# Yürüyüş / koşu hızı
	var current_speed: float = walk_speed
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	velocity.x = move_direction.x * current_speed
	velocity.z = move_direction.z * current_speed

	# Yerçekimi
	if not is_on_floor():
		velocity.y -= gravity_force * delta

	# Zıplama
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength

	move_and_slide()
