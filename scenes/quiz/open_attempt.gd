extends VBoxContainer

@export var attempt_row_scene: PackedScene
@export var id:= 0
@export var question_id:= 0
@export var question: Question
@export var edit_shortcut: PackedScene

signal add_to_might(value: int)

var type_controls: VBoxContainer

func _on_add_row_button_pressed() -> HBoxContainer:
	var new_child = attempt_row_scene.instantiate()
	_wire_row(new_child)
	$Elements/OpensRow.add_child(new_child)
	new_child.call_deferred("get_focus")
	return new_child

func a_text_has_changed(difference: int) -> void:
	add_to_might.emit(difference)

func set_description(text: String) -> void:
	if question.is_ambush || question.is_rush:
		$ID/Number.text = "X. "
	else:
		$ID/Number.text = str(question.attempt_index + 1) + ". "
	$ID/Description.text = text

func prepare(with_question: Question):
	question = with_question
	question_id = with_question.id
	if question.has_media(): 
		$Image.texture = question.get_mediaset().images[0]
	set_description(question.get_display_question())
	for child in $Elements/OpensRow.get_children():
		_wire_row(child)
	_update_order_numbers()
	_prepare_type_controls()

func fetch() -> Array:
	if _uses_custom_attempt_controls():
		return _fetch_custom_attempt()
	var result = []
	for child in $Elements/OpensRow.get_children():
		result.push_back(child.fetch())
	return result

func replicate() -> void:
	randomize()
	var difference = question.answer.size() - $Elements/OpensRow.get_child_count()
	for remainder in difference:
		_on_add_row_button_pressed()
	# Make excess apparent by making text red
	if difference < 0:
		for i in range(difference * -1):
			$Elements/OpensRow.get_child(i - 1).make_text_red()
	for i in range(question.answer.size()):
		var ans = question.answer[i]["texts"].duplicate()
		ans.shuffle()
		$Elements/OpensRow.get_child(i).set_text(ans[0])
		# await get_tree().create_timer(10).timeout
		# $Elements/OpensRow.get_child(i).set_text("")

func map_array_to_lowercase(array: Array) -> Array:
	return array.map(func (element: String): return element.to_lower())

func map_string_to_lower(string: String) -> String:
	return string.to_lower()
	
func solve() -> bool:
	var attempts = fetch()
	var result = question.check_attempt(attempts)
	if _uses_custom_attempt_controls():
		_show_custom_result(result)
		return result["correct"]
	var wrong_attempts: Array = result["wrong_attempts"]
	var missing_answers: Array = result["missing_answers"]
	for attempt_i in range(attempts.size()):
		if wrong_attempts.has(attempts[attempt_i]):
			var correction = missing_answers.pop_front() if !missing_answers.is_empty() else ""
			$Elements/OpensRow.get_child(attempt_i).cross(correction)
		else:
			$Elements/OpensRow.get_child(attempt_i).tick()
	for answer_text in missing_answers:
		var new_correction = _on_add_row_button_pressed()
		new_correction.cross(answer_text, false)
	$Edit.show()
	if result["correct"]:
		print("--Correct--")
	else:
		print("--Wrong--")
	return result["correct"]

func edit() -> void:
	var edit_scene = edit_shortcut.instantiate()
	edit_scene.subject_id = question.subject_id
	edit_scene.silence = true
	add_child(edit_scene)
	edit_scene.on_edit_pressed(question.id)

func _on_attempt_text_focused() -> void:
	$Elements/AddRowButton.show()

func _on_attempt_text_unfocused() -> void:
	$Elements/AddRowButton.hide()

func _on_attempt_row_erase_if_empty_requested(row: Node) -> void:
	if row == null || row.fetch().strip_edges() != "":
		return
	if $Elements/OpensRow.get_child_count() <= 1:
		row.set_text("")
		return
	row.queue_free()
	_update_order_numbers.call_deferred()

func _wire_row(row: Node) -> void:
	if row == null || row.has_meta("open_attempt_wired"):
		return
	if !row.text_focused.is_connected(_on_attempt_text_focused):
		row.text_focused.connect(_on_attempt_text_focused)
	if !row.text_unfocused.is_connected(_on_attempt_text_unfocused):
		row.text_unfocused.connect(_on_attempt_text_unfocused)
	if !row.text_has_changed.is_connected(a_text_has_changed):
		row.text_has_changed.connect(a_text_has_changed)
	if row.has_signal("add_row_requested"):
		row.add_row_requested.connect(_on_add_row_button_pressed)
	if row.has_signal("erase_if_empty_requested"):
		row.erase_if_empty_requested.connect(_on_attempt_row_erase_if_empty_requested.bind(row))
	row.set_meta("open_attempt_wired", true)
	_update_order_numbers()

func _update_order_numbers() -> void:
	for index in range($Elements/OpensRow.get_child_count()):
		var row = $Elements/OpensRow.get_child(index)
		if question != null && question.is_order && row.has_method("show_order"):
			row.show_order(index + 1)
		elif row.has_method("hide_order"):
			row.hide_order()

func _prepare_type_controls() -> void:
	if type_controls == null:
		type_controls = VBoxContainer.new()
		type_controls.name = "TypeControls"
		type_controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		type_controls.add_theme_constant_override("separation", 8)
		$Elements.add_child(type_controls)
	for child in type_controls.get_children():
		child.queue_free()
	var custom = _uses_custom_attempt_controls()
	$Elements/OpensRow.visible = !custom
	$Elements/AddRowButton.visible = false
	type_controls.visible = custom
	if !custom:
		return
	match question.attempt_type:
		"choice":
			_build_choice_controls(false)
		"veracity":
			_build_choice_controls(true)
		"table":
			_build_table_controls()
		"connect":
			_build_connect_controls()
		"label":
			_build_label_controls()
		"scheme":
			_build_scheme_controls()

func _uses_custom_attempt_controls() -> bool:
	return question != null && ["choice", "veracity", "table", "connect", "label", "scheme"].has(question.attempt_type)

func _build_choice_controls(veracity_mode: bool) -> void:
	for choice in question.formulated_choices:
		var text = str(choice.get("text", ""))
		if veracity_mode:
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 8)
			type_controls.add_child(row)
			var label = Label.new()
			label.text = text
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(label)
			var option = OptionButton.new()
			option.name = "VeracityChoice"
			option.add_item("False")
			option.set_item_metadata(0, false)
			option.add_item("True")
			option.set_item_metadata(1, true)
			option.set_meta("choice_text", text)
			row.add_child(option)
		else:
			var check = CheckBox.new()
			check.name = "Choice"
			check.text = text
			type_controls.add_child(check)

func _build_table_controls() -> void:
	var columns = question.formulated_variables if !question.formulated_variables.is_empty() else question.columns
	var grid = GridContainer.new()
	grid.columns = max(1, columns.size())
	type_controls.add_child(grid)
	for column_index in range(columns.size()):
		var column = Array(columns[column_index])
		for row_index in range(column.size()):
			var cell = column[row_index]
			if cell is Dictionary && bool(cell.get("is_open", false)):
				var input = LineEdit.new()
				input.name = "TableGap"
				input.placeholder_text = "Answer"
				input.set_meta("column", column_index)
				input.set_meta("row", row_index)
				grid.add_child(input)
			else:
				var label = Label.new()
				label.text = _cell_to_text(cell)
				grid.add_child(label)

func _build_connect_controls() -> void:
	var a = question.match_a
	var b = question.match_b
	if question.formulated_variables.size() >= 2:
		a = question.formulated_variables[0]
		b = question.formulated_variables[1]
	var b_values = []
	for key in b.keys():
		b_values.push_back(str(b[key]))
	b_values.shuffle()
	for key in a.keys():
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		type_controls.add_child(row)
		var label = Label.new()
		label.text = str(a[key])
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var option = OptionButton.new()
		option.name = "MatchChoice"
		option.set_meta("match_a", str(a[key]))
		for value in b_values:
			option.add_item(value)
			option.set_item_metadata(option.item_count - 1, value)
		row.add_child(option)

func _build_label_controls() -> void:
	var label_count = max(1, question.labels.size())
	for label_index in range(label_count):
		var input = LineEdit.new()
		input.name = "LabelAttempt"
		input.placeholder_text = "Label"
		input.set_meta("label_index", label_index)
		type_controls.add_child(input)

func _build_scheme_controls() -> void:
	var nodes = question.scheme_nodes
	var links = question.scheme_links
	if question.formulated_variables.size() >= 2:
		nodes = question.formulated_variables[0]
		links = question.formulated_variables[1]
	var node_names = nodes.map(func(node): return _scheme_node_text(node))
	for link_index in range(max(1, links.size())):
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		type_controls.add_child(row)
		var from_option = _make_node_option(node_names)
		from_option.name = "SchemeFrom"
		row.add_child(from_option)
		var to_option = _make_node_option(node_names)
		to_option.name = "SchemeTo"
		row.add_child(to_option)
		var label = LineEdit.new()
		label.name = "SchemeLabel"
		label.placeholder_text = "Label"
		row.add_child(label)

func _make_node_option(node_names: Array) -> OptionButton:
	var option = OptionButton.new()
	for node_name in node_names:
		option.add_item(str(node_name))
		option.set_item_metadata(option.item_count - 1, str(node_name))
	return option

func _fetch_custom_attempt() -> Array:
	match question.attempt_type:
		"choice":
			var selected = []
			for child in type_controls.get_children():
				if child is CheckBox && child.button_pressed:
					selected.push_back(child.text)
			return selected
		"veracity":
			var veracity = []
			for row in type_controls.get_children():
				var option = row.get_node_or_null("VeracityChoice")
				if option != null:
					veracity.push_back({"text": str(option.get_meta("choice_text")), "veracity": bool(option.get_selected_metadata())})
			return veracity
		"table":
			var table = []
			for grid in type_controls.get_children():
				for child in grid.get_children():
					if child is LineEdit && child.name == "TableGap":
						table.push_back({"column": int(child.get_meta("column")), "row": int(child.get_meta("row")), "text": child.text})
			return table
		"connect":
			var pairs = []
			for row in type_controls.get_children():
				var option = row.get_node_or_null("MatchChoice")
				if option != null:
					pairs.push_back({"a": str(option.get_meta("match_a")), "b": str(option.get_selected_metadata())})
			return pairs
		"label":
			var labels_attempt = []
			for child in type_controls.get_children():
				if child is LineEdit:
					labels_attempt.push_back({"text": child.text})
			return labels_attempt
		"scheme":
			var links_attempt = []
			for row in type_controls.get_children():
				var from_option = row.get_node_or_null("SchemeFrom")
				var to_option = row.get_node_or_null("SchemeTo")
				var label = row.get_node_or_null("SchemeLabel")
				if from_option != null && to_option != null:
					links_attempt.push_back({
						"from": str(from_option.get_selected_metadata()),
						"to": str(to_option.get_selected_metadata()),
						"label": label.text if label != null else "",
					})
			return links_attempt
	return []

func _show_custom_result(result: Dictionary) -> void:
	var label = type_controls.get_node_or_null("Result")
	if label == null:
		label = Label.new()
		label.name = "Result"
		type_controls.add_child(label)
	label.text = "Correct" if bool(result.get("correct", false)) else "Wrong"
	$Edit.show()
	if result["correct"]:
		print("--Correct--")
	else:
		print("--Wrong--")

func _cell_to_text(cell) -> String:
	if cell is Dictionary:
		return str(cell.get("display", cell.get("text", "")))
	return str(cell)

func _scheme_node_text(node) -> String:
	if node is Dictionary:
		return str(node.get("id", node.get("text", node.get("name", ""))))
	return str(node)
