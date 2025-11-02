extends HBoxContainer

signal text_has_changed

func fetch() -> String:
	return $Text.text

func _on_delete_button_pressed() -> void:
	queue_free()

func set_text(text: String) -> void:
	$Text.text = text

func get_focus() -> void:
	$Text.grab_focus()


func _on_text_text_changed() -> void:
	text_has_changed.emit()
