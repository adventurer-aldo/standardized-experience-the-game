extends HBoxContainer

@export var match_row_scene: PackedScene

func _on_add_row_pressed() -> void:
	$Rows.add_child(match_row_scene.instantiate())
