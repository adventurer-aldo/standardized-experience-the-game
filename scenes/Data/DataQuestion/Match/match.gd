extends HBoxContainer

@export var match_row_scene: PackedScene

func _on_add_row_pressed() -> void:
	$Rows.add_child(match_row_scene.instantiate())

func fetch() -> Dictionary:
	var match_a = {}
	var match_b = {}
	$Rows.get_children().map(func (row):
		var fetched = row.fetch()
		match_a[fetched["order"]] = fetched["a"]
		match_b[fetched["order"]] = fetched["b"]
	)
	return {"a": match_a, "b": match_b}
