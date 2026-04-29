extends VBoxContainer

@export var cell_scene: PackedScene
@export var button_scene: PackedScene

func _on_add_column_pressed() -> void:
	var new_column = $Writable/Table/Base/Rows.get_child(0).duplicate()
	for cell in new_column.get_children():
		cell.text = ''
	$Writable/Table/Base/Rows.add_child(new_column)
	$Editable/Table/Base/Rows.add_child($Editable/Table/Base/Rows.get_child(0).duplicate())

func _on_delete_column_pressed() -> void:
	if $Writable/Table/Base/Rows.get_child_count() > 1:
		$Writable/Table/Base/Rows.get_child(-1).queue_free()
		$Editable/Table/Base/Rows.get_child(-1).queue_free()

func _on_add_row_pressed() -> void:
	for column in $Writable/Table/Base/Rows.get_children():
		column.add_child(cell_scene.instantiate())
	for column in $Editable/Table/Base/Rows.get_children():
		column.add_child(button_scene.instantiate())

func _on_delete_row_pressed() -> void:
	if $Writable/Table/Base/Rows.get_child(0).get_child_count() > 1:
		for column in $Writable/Table/Base/Rows.get_children():
			column.get_child(-1).queue_free()
		for column in $Editable/Table/Base/Rows.get_children():
			column.get_child(-1).queue_free()

func flip_openness(x: int, y: int) -> void:
	$Writable/Table/Base/Rows.get_child(x).get_child(y).flip_open()

func fetch():
	var columns = $Writable/Table/Base/Rows.get_children().map(func (column):
		return column.get_children().map(func (cell): return {"text": cell.text,
		 "is_open": cell.is_open})
	)
	return columns
