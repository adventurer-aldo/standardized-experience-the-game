extends HBoxContainer

signal text_has_changed(difference: int)
var text:= ""

func fetch() -> String:
	return $Text.text

func _on_delete_button_pressed() -> void:
	queue_free()

func set_text(to: String) -> void:
	$Text.text = to

func get_focus() -> void:
	$Text.grab_focus()

func _on_text_text_changed() -> void:
	var diff = text.strip_edges().length() - $Text.text.strip_edges().length()
	text = $Text.text
	text_has_changed.emit(diff)
