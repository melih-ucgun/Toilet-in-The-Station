extends Control


func _on_button_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://scenes/world/terminal_exterior.tscn")


func _on_button_2_pressed() -> void:
	pass # Replace with function body.
	get_tree().quit()
