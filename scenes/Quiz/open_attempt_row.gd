extends HBoxContainer

func fetch() -> String:
	return $Text.text

func _on_delete_button_pressed() -> void:
	queue_free()

func set_text(text: String) -> void:
	$Text.text = text
