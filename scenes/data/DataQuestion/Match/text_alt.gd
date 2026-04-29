extends HBoxContainer

@export var alt_is_on_left = false

func _ready() -> void:
	if alt_is_on_left:
		move_child($DeleteAlt, 0)

func _on_delete_answer_pressed() -> void:
	queue_free()

func fetch() -> String:
	return $TextAlt.text
