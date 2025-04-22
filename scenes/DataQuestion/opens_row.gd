extends HBoxContainer

signal delete_pressed

@export var alt_scene: PackedScene

func _on_add_alt_pressed() -> void:
	$Answer/Alts.add_child(alt_scene.instantiate())

func _on_delete_answer_pressed() -> void:
	if get_parent().get_child_count() > 1:
		queue_free()
		delete_pressed.emit()

func should_delete_hide() -> void:
	if get_parent().get_child_count() > 1:
		$Answer/Set/DeleteAnswer.show()
	else:
		$Answer/Set/DeleteAnswer.hide()
