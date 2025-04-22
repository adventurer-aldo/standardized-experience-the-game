extends HBoxContainer

func _on_delete_row_pressed() -> void:
	if get_parent().get_child_count() > 1:
		queue_free()
