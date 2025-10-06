extends HBoxContainer

signal delete_pressed(text: String)

func set_text(text: String) -> void:
	$TextButton.text = text

func _on_delete_button_pressed() -> void:
	delete_pressed.emit($TextButton.text)
	queue_free()

func fetch() -> String:
	return $TextButton.text
