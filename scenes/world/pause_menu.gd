extends CanvasLayer

func _ready():
	# Oyun başladığında menüyü gizle
	visible = false 

func _input(event):
	# Eğer "ui_cancel" (varsayılan olarak ESC tuşudur) basılırsa
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	
	if is_paused:
		# Oyun DURDUĞUNDA: Mouse'u görünür yap ve serbest bırak
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# Oyun DEVAM ETTİĞİNDE: Mouse'u tekrar gizle ve kilitle (FPS ise)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_button_pressed() -> void:
	pass # Replace with function body.
	toggle_pause()

func _on_button_2_pressed() -> void:
	pass # Replace with function body.
	get_tree().paused = false # Önce zamanı tekrar akıt, yoksa ana menü de donuk açılır!
	get_tree().change_scene_to_file("res://scenes/MainMenu/mainmenu.tscn") # Menü dosyanın yolu
