extends VBoxContainer

signal parent_pressed(id: int)
signal edit_pressed(id: int)
signal delete_pressed(id: int)

var id:= 0

func set_text(to: String):
	$MainText.text = to

func set_id(to: int):
	id = to
	$Buttons/ID.text = str(to)

func _on_parent_pressed() -> void:
	parent_pressed.emit(id)

func _on_delete_pressed() -> void:
	delete_pressed.emit(id)
	queue_free()

func _on_edit_pressed() -> void:
	edit_pressed.emit(id)
