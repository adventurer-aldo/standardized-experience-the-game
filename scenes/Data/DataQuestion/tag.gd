extends MarginContainer

signal delete_pressed(text: String)

func set_text(text: String) -> void:
	$Tag/TextButton.text = text

func _on_delete_button_pressed() -> void:
	delete_pressed.emit($Tag/TextButton.text)
	queue_free()

func fetch() -> String:
	return $Tag/TextButton.text
