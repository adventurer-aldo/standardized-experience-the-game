extends Button

signal subject_pressed(id: int)
@export var subject_id:= 0

func _on_pressed() -> void:
	subject_pressed.emit(subject_id)

func set_title(to: String) -> void:
	text = to
