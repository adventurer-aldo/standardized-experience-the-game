extends HBoxContainer

signal text_has_changed(difference: int)
signal text_focused
signal text_unfocused
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
	var diff = $Text.text.strip_edges().length() - text.strip_edges().length()
	text = $Text.text
	if diff!= 0: text_has_changed.emit(diff)

func _on_text_focus_entered() -> void:
	text_focused.emit()
	$DeleteButton.show()

func _on_text_focus_exited() -> void:
	text_unfocused.emit()
	$DeleteButton.hide()
