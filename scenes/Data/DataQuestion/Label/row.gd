extends HBoxContainer

signal delete_pressed(index)

func _on_delete_pressed() -> void:
	delete_pressed.emit(get_index())
	queue_free()
