extends "res://scenes/quiz/attempt_base.gd"

var dynamic_grid: GridContainer

func _build_attempt_controls() -> void:
	var columns = question.formulated_variables if !question.formulated_variables.is_empty() else question.columns
	if columns.is_empty():
		columns = [[{"text": "", "is_open": true}]]
	if _table_is_fully_open(columns):
		_build_dynamic_table()
	else:
		_build_fixed_table(columns)

func fetch() -> Array:
	var cells := []
	for node in body.find_children("*", "LineEdit", true, false):
		cells.push_back({
			"column": int(node.get_meta("column")),
			"row": int(node.get_meta("row")),
			"text": node.text,
		})
	return cells

func _show_checked_result(result: Dictionary) -> void:
	super._show_checked_result(result)
	var missing = result.get("missing_answers", [])
	for node in body.find_children("*", "LineEdit", true, false):
		node.editable = false
		var is_missing = missing.any(func(item):
			return item is Dictionary \
				&& int(item.get("column", -1)) == int(node.get_meta("column")) \
				&& int(item.get("row", -1)) == int(node.get_meta("row"))
		)
		node.add_theme_color_override("font_color", Color(0.72, 0.05, 0.07) if is_missing else Color(0.05, 0.42, 0.12))

func _build_fixed_table(columns: Array) -> void:
	var grid = GridContainer.new()
	grid.name = "Table"
	grid.columns = max(1, columns.size())
	body.add_child(grid)
	for column_index in range(columns.size()):
		var column = Array(columns[column_index])
		for row_index in range(column.size()):
			var cell = column[row_index]
			if cell is Dictionary && bool(cell.get("is_open", false)):
				grid.add_child(_make_cell_input(column_index, row_index))
			else:
				var label = _make_option_label(_cell_to_text(cell))
				label.custom_minimum_size = Vector2(130, 38)
				grid.add_child(label)

func _build_dynamic_table() -> void:
	var controls = HBoxContainer.new()
	controls.name = "DynamicControls"
	controls.add_theme_constant_override("separation", 8)
	body.add_child(controls)

	var add_row = Button.new()
	add_row.text = "+ Row"
	add_row.pressed.connect(_dynamic_table_add_row)
	controls.add_child(add_row)

	var add_column = Button.new()
	add_column.text = "+ Column"
	add_column.pressed.connect(_dynamic_table_add_column)
	controls.add_child(add_column)

	dynamic_grid = GridContainer.new()
	dynamic_grid.name = "DynamicTable"
	dynamic_grid.columns = 1
	body.add_child(dynamic_grid)
	_dynamic_table_add_cell(0, 0)

func _dynamic_table_add_row() -> void:
	var columns = max(1, dynamic_grid.columns)
	var rows = int(ceil(float(dynamic_grid.get_child_count()) / float(columns)))
	for column in range(columns):
		_dynamic_table_add_cell(column, rows)

func _dynamic_table_add_column() -> void:
	var old_columns = max(1, dynamic_grid.columns)
	var rows = max(1, int(ceil(float(dynamic_grid.get_child_count()) / float(old_columns))))
	dynamic_grid.columns = old_columns + 1
	for row in range(rows):
		_dynamic_table_add_cell(old_columns, row)

func _dynamic_table_add_cell(column: int, row: int) -> void:
	dynamic_grid.add_child(_make_cell_input(column, row))

func _make_cell_input(column: int, row: int) -> LineEdit:
	var input = LineEdit.new()
	input.placeholder_text = "Answer"
	input.custom_minimum_size = Vector2(130, 38)
	input.set_meta("column", column)
	input.set_meta("row", row)
	return input

func _table_is_fully_open(columns: Array) -> bool:
	var total := 0
	var open_count := 0
	for column in columns:
		for cell in Array(column):
			total += 1
			if cell is Dictionary && bool(cell.get("is_open", false)):
				open_count += 1
	return total > 0 && open_count == total

func _cell_to_text(cell) -> String:
	if cell is Dictionary:
		return str(cell.get("display", cell.get("text", "")))
	return str(cell)
