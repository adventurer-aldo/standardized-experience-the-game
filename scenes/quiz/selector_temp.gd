extends Button

signal subject_selected(key)
@export var key: int = -1

func _on_pressed():
	emit_signal("subject_selected", key)
