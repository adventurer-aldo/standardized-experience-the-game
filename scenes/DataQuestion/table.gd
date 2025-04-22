extends HBoxContainer

@export var cell_scene: PackedScene

func _on_add_column_pressed() -> void:
	var new_column = $Base/Rows.get_child(0).duplicate()
	for cell in new_column.get_children():
		cell.text = ''
	$Base/Rows.add_child(new_column)

func _on_delete_column_pressed() -> void:
	if $Base/Rows.get_child_count() > 1:
		$Base/Rows.get_child(-1).queue_free()

func _on_add_row_pressed() -> void:
	for column in $Base/Rows.get_children():
		column.add_child(cell_scene.instantiate())

func _on_delete_row_pressed() -> void:
	if $Base/Rows.get_child(0).get_child_count() > 1:
		for column in $Base/Rows.get_children():
			column.get_child(-1).queue_free()
