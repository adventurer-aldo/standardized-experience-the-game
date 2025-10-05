extends HBoxContainer

func fetch() -> String:
	return $Text.text

func _on_delete_alt_pressed() -> void:
	queue_free()

func get_focus() -> void:
	$Text.grab_focus()

func reset() -> void:
	$Text.text = ""

func set_text(to: String) -> void:
	$Text.text = to
