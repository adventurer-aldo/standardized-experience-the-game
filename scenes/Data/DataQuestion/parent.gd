extends HBoxContainer

signal delete_pressed(id: int)

var id: int

func _ready() -> void:
	$ID.text = str(id)

func _on_delete_pressed() -> void:
	delete_pressed.emit(id)
