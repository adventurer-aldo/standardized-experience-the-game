extends HBoxContainer

func fetch() -> String:
	return $Text.text

func _on_delete_alt_pressed() -> void:
	queue_free()
