extends HBoxContainer

signal parent_pressed(id: int)
signal delete_pressed(id: int)

@export var id: int = 0

func _ready() -> void:
	$ID.text = str(id)

func _on_erase_pressed() -> void:
	delete_pressed.emit(id)

func _on_id_pressed() -> void:
	parent_pressed.emit(id)
