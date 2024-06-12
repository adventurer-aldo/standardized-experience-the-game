extends Button

signal subject_selected(key)
@export var key: int = -1

func _on_pressed():
	subject_selected.emit(key)
