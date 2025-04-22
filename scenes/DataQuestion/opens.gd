extends HBoxContainer

signal row_count_changed

@export var row_scene: PackedScene

func _on_row_delete_pressed() -> void:
	row_count_changed.emit()

func _on_add_answer_pressed() -> void:
	$Rows.add_child(row_scene.instantiate())
