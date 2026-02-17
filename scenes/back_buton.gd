extends Button


func _on_mouse_entered() -> void:
	grab_focus()

func _on_pressed() -> void:
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
