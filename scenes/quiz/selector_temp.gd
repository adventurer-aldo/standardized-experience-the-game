extends Button

signal subject_selected(key)
@export var key: int

func _on_pressed():
	emit_signal("subject_selected", key)
