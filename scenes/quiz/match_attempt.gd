extends "res://scenes/quiz/attempt_base.gd"

func _build_attempt_controls() -> void:
	var a = question.match_a
	var b = question.match_b
	if question.formulated_variables.size() >= 2:
		a = question.formulated_variables[0]
		b = question.formulated_variables[1]
	var b_values := []
	for key in b.keys():
		b_values.push_back(str(b[key]))
	var keys = a.keys()
	keys.sort()
	for row_index in range(keys.size()):
		var key = keys[row_index]
		var row = HBoxContainer.new()
		row.name = "MatchRow"
		row.add_theme_constant_override("separation", 10)
		body.add_child(row)
		row.add_child(_make_option_label(str(a[key])))

		var controls = VBoxContainer.new()
		controls.custom_minimum_size = Vector2(48, 0)
		row.add_child(controls)

		var up = Button.new()
		up.text = "Up"
		up.pressed.connect(_move_b_value.bind(row, -1))
		controls.add_child(up)

		var down = Button.new()
		down.text = "Down"
		down.pressed.connect(_move_b_value.bind(row, 1))
		controls.add_child(down)

		var value_label = _make_option_label(b_values[row_index] if row_index < b_values.size() else "")
		value_label.name = "MatchValue"
		value_label.set_meta("match_a", str(a[key]))
		row.add_child(value_label)

func fetch() -> Array:
	var pairs := []
	for row in body.get_children():
		var value_label = row.get_node_or_null("MatchValue")
		if value_label != null:
			pairs.push_back({"a": str(value_label.get_meta("match_a")), "b": value_label.text})
	return pairs

func _show_checked_result(result: Dictionary) -> void:
	super._show_checked_result(result)
	var missing = result.get("missing_answers", [])
	for row in body.get_children():
		var value_label = row.get_node_or_null("MatchValue")
		if value_label == null:
			continue
		var is_missing = missing.any(func(item):
			return item is Dictionary && str(item.get("a", "")) == str(value_label.get_meta("match_a"))
		)
		value_label.add_theme_color_override("font_color", Color(0.72, 0.05, 0.07) if is_missing else Color(0.05, 0.42, 0.12))

func _move_b_value(row: HBoxContainer, direction: int) -> void:
	var rows = body.get_children().filter(func(child): return child is HBoxContainer && child.name == "MatchRow")
	var index = rows.find(row)
	var target_index = index + direction
	if index < 0 || target_index < 0 || target_index >= rows.size():
		return
	var current_value = row.get_node("MatchValue")
	var target_value = rows[target_index].get_node("MatchValue")
	var text = current_value.text
	current_value.text = target_value.text
	target_value.text = text
