extends HBoxContainer

func fetch() -> String:
	return $MainText.text

func _on_delete_button_pressed() -> void:
	queue_free()
