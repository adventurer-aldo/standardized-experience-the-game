extends PanelContainer

signal insert_variable_requested(variable_key)

const KIND_NUMBER := "number"
const KIND_WORD := "word"
const KIND_GAP := "gap"

var rows_box: VBoxContainer
var empty_label: Label
var next_variable_id:= 1
var highlighted_row: Control

func _ready() -> void:
	_ensure_layout()

func set_variables(variable_entries: Array) -> void:
	_ensure_layout()
	for row_node in rows_box.get_children():
		row_node.free()
	next_variable_id = 1
	for variable_entry in variable_entries:
		if !(variable_entry is Dictionary):
			continue
		var variable_spec = variable_entry.duplicate(true)
		if str(variable_spec.get("id", "")).strip_edges() == "":
			variable_spec["id"] = next_variable_id
		next_variable_id = max(next_variable_id, int(variable_spec.get("id", 0)) + 1)
		_add_variable_row(variable_spec)
	_update_empty_state()

func fetch() -> Array:
	_ensure_layout()
	var variable_entries := []
	for row_node in rows_box.get_children():
		if !row_node.has_meta("variable_row"):
			continue
		var variable_key = int(row_node.get_meta("variable_id"))
		var kind_options: OptionButton = row_node.get_node("Body/Header/Kind")
		var variable_kind = str(kind_options.get_item_metadata(kind_options.selected))
		var label_input: LineEdit = row_node.get_node("Body/Header/VariableLabel")
		var variable_spec := {
			"id": variable_key,
			"label": label_input.text.strip_edges(),
			"kind": variable_kind,
		}
		match variable_kind:
			KIND_NUMBER:
				var minimum_spin: SpinBox = row_node.get_node("Body/NumberFields/Minimum")
				var maximum_spin: SpinBox = row_node.get_node("Body/NumberFields/Maximum")
				variable_spec["minimum"] = int(minimum_spin.value)
				variable_spec["maximum"] = int(maximum_spin.value)
			KIND_WORD:
				var words_input: TextEdit = row_node.get_node("Body/WordFields/Words")
				var from_answers_toggle: CheckButton = row_node.get_node("Body/WordFields/Options/FromAnswers")
				var consume_answer_toggle: CheckButton = row_node.get_node("Body/WordFields/Options/ConsumeAnswer")
				variable_spec["words"] = words_input.text
				variable_spec["from_answers"] = from_answers_toggle.button_pressed
				variable_spec["consume_answer"] = consume_answer_toggle.button_pressed
			KIND_GAP:
				var answer_index_spin: SpinBox = row_node.get_node("Body/GapFields/AnswerIndex")
				variable_spec["answer_index"] = max(0, int(answer_index_spin.value) - 1)
		variable_entries.push_back(variable_spec)
	return variable_entries

func get_variable_display_label(variable_key) -> String:
	_ensure_layout()
	for row_node in rows_box.get_children():
		if !row_node.has_meta("variable_row"):
			continue
		if int(row_node.get_meta("variable_id")) != int(variable_key):
			continue
		var label_input: LineEdit = row_node.get_node("Body/Header/VariableLabel")
		var label_text = label_input.text.strip_edges()
		return label_text if label_text != "" else "v" + str(variable_key)
	return "v" + str(variable_key)

func focus_variable(variable_key) -> void:
	_ensure_layout()
	if highlighted_row != null && is_instance_valid(highlighted_row):
		highlighted_row.remove_theme_stylebox_override("panel")
	for row_node in rows_box.get_children():
		if !row_node.has_meta("variable_row") || int(row_node.get_meta("variable_id")) != int(variable_key):
			continue
		highlighted_row = row_node
		var style = StyleBoxFlat.new()
		style.bg_color = Color(1.0, 0.88, 0.48, 1.0)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.12, 0.26, 0.42, 1.0)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_right = 4
		style.corner_radius_bottom_left = 4
		row_node.add_theme_stylebox_override("panel", style)
		var label_input: LineEdit = row_node.get_node("Body/Header/VariableLabel")
		label_input.grab_focus()
		return

func _ensure_layout() -> void:
	if rows_box != null && is_instance_valid(rows_box):
		return
	custom_minimum_size = Vector2(0, 90)
	var margin_node = MarginContainer.new()
	margin_node.add_theme_constant_override("margin_left", 8)
	margin_node.add_theme_constant_override("margin_top", 8)
	margin_node.add_theme_constant_override("margin_right", 8)
	margin_node.add_theme_constant_override("margin_bottom", 8)
	add_child(margin_node)
	var root_box = VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 6)
	margin_node.add_child(root_box)
	var header_box = HBoxContainer.new()
	header_box.add_theme_constant_override("separation", 6)
	root_box.add_child(header_box)
	var title_label = Label.new()
	title_label.text = "Variables"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_box.add_child(title_label)
	header_box.add_child(_make_add_button("Number", KIND_NUMBER))
	header_box.add_child(_make_add_button("Word", KIND_WORD))
	header_box.add_child(_make_add_button("Gap", KIND_GAP))
	rows_box = VBoxContainer.new()
	rows_box.add_theme_constant_override("separation", 6)
	root_box.add_child(rows_box)
	empty_label = Label.new()
	empty_label.text = "No variables yet."
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root_box.add_child(empty_label)
	_update_empty_state()

func _make_add_button(button_text: String, variable_kind: String) -> Button:
	var add_button = Button.new()
	add_button.text = "+" + button_text
	add_button.focus_mode = Control.FOCUS_NONE
	add_button.pressed.connect(_on_add_variable_pressed.bind(variable_kind))
	return add_button

func _on_add_variable_pressed(variable_kind: String) -> void:
	_ensure_layout()
	var variable_key = next_variable_id
	next_variable_id += 1
	var variable_spec := {
		"id": variable_key,
		"label": _default_label(variable_kind, variable_key),
		"kind": variable_kind,
		"minimum": 1,
		"maximum": 10,
		"words": "",
		"from_answers": false,
		"consume_answer": false,
		"answer_index": 0,
	}
	_add_variable_row(variable_spec)
	_update_empty_state()

func _add_variable_row(variable_spec: Dictionary) -> void:
	var row_panel = PanelContainer.new()
	row_panel.set_meta("variable_row", true)
	row_panel.set_meta("variable_id", int(variable_spec.get("id", next_variable_id)))
	var body_box = VBoxContainer.new()
	body_box.name = "Body"
	body_box.add_theme_constant_override("separation", 4)
	row_panel.add_child(body_box)
	var header_box = HBoxContainer.new()
	header_box.name = "Header"
	header_box.add_theme_constant_override("separation", 4)
	body_box.add_child(header_box)
	var insert_button = Button.new()
	insert_button.text = "Insert"
	insert_button.focus_mode = Control.FOCUS_NONE
	insert_button.pressed.connect(_on_insert_pressed.bind(row_panel))
	header_box.add_child(insert_button)
	var label_input = LineEdit.new()
	label_input.name = "VariableLabel"
	label_input.text = str(variable_spec.get("label", ""))
	label_input.placeholder_text = "Label"
	label_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_box.add_child(label_input)
	var kind_options = OptionButton.new()
	kind_options.name = "Kind"
	_add_kind_option(kind_options, "Number", KIND_NUMBER)
	_add_kind_option(kind_options, "Word", KIND_WORD)
	_add_kind_option(kind_options, "Gap", KIND_GAP)
	_select_kind(kind_options, str(variable_spec.get("kind", KIND_NUMBER)))
	kind_options.item_selected.connect(_on_kind_selected.bind(row_panel))
	header_box.add_child(kind_options)
	var delete_button = Button.new()
	delete_button.text = "X"
	delete_button.focus_mode = Control.FOCUS_NONE
	delete_button.pressed.connect(_on_delete_pressed.bind(row_panel))
	header_box.add_child(delete_button)
	body_box.add_child(_make_number_fields(variable_spec))
	body_box.add_child(_make_word_fields(variable_spec))
	body_box.add_child(_make_gap_fields(variable_spec))
	rows_box.add_child(row_panel)
	_apply_kind_visibility(row_panel)

func _make_number_fields(variable_spec: Dictionary) -> HBoxContainer:
	var fields_box = HBoxContainer.new()
	fields_box.name = "NumberFields"
	fields_box.add_theme_constant_override("separation", 4)
	fields_box.add_child(_make_inline_label("Min"))
	var minimum_spin = SpinBox.new()
	minimum_spin.name = "Minimum"
	minimum_spin.min_value = -999999
	minimum_spin.max_value = 999999
	minimum_spin.step = 1
	minimum_spin.value = int(variable_spec.get("minimum", variable_spec.get("min", 1)))
	fields_box.add_child(minimum_spin)
	fields_box.add_child(_make_inline_label("Max"))
	var maximum_spin = SpinBox.new()
	maximum_spin.name = "Maximum"
	maximum_spin.min_value = -999999
	maximum_spin.max_value = 999999
	maximum_spin.step = 1
	maximum_spin.value = int(variable_spec.get("maximum", variable_spec.get("max", 10)))
	fields_box.add_child(maximum_spin)
	return fields_box

func _make_word_fields(variable_spec: Dictionary) -> VBoxContainer:
	var fields_box = VBoxContainer.new()
	fields_box.name = "WordFields"
	fields_box.add_theme_constant_override("separation", 4)
	var options_box = HBoxContainer.new()
	options_box.name = "Options"
	options_box.add_theme_constant_override("separation", 6)
	var from_answers_toggle = CheckButton.new()
	from_answers_toggle.name = "FromAnswers"
	from_answers_toggle.text = "Use open answers"
	from_answers_toggle.button_pressed = bool(variable_spec.get("from_answers", false))
	options_box.add_child(from_answers_toggle)
	var consume_answer_toggle = CheckButton.new()
	consume_answer_toggle.name = "ConsumeAnswer"
	consume_answer_toggle.text = "Exclude picked answer"
	consume_answer_toggle.button_pressed = bool(variable_spec.get("consume_answer", false))
	options_box.add_child(consume_answer_toggle)
	fields_box.add_child(options_box)
	var words_input = TextEdit.new()
	words_input.name = "Words"
	words_input.custom_minimum_size = Vector2(0, 60)
	words_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words_input.placeholder_text = "Words, commas, or one per line"
	words_input.scroll_fit_content_height = true
	words_input.text = str(variable_spec.get("words", ""))
	fields_box.add_child(words_input)
	return fields_box

func _make_gap_fields(variable_spec: Dictionary) -> HBoxContainer:
	var fields_box = HBoxContainer.new()
	fields_box.name = "GapFields"
	fields_box.add_theme_constant_override("separation", 4)
	fields_box.add_child(_make_inline_label("Answer #"))
	var answer_index_spin = SpinBox.new()
	answer_index_spin.name = "AnswerIndex"
	answer_index_spin.min_value = 1
	answer_index_spin.max_value = 999
	answer_index_spin.step = 1
	answer_index_spin.value = int(variable_spec.get("answer_index", 0)) + 1
	fields_box.add_child(answer_index_spin)
	return fields_box

func _make_inline_label(label_text: String) -> Label:
	var inline_label = Label.new()
	inline_label.text = label_text
	inline_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return inline_label

func _add_kind_option(kind_options: OptionButton, label_text: String, variable_kind: String) -> void:
	kind_options.add_item(label_text)
	kind_options.set_item_metadata(kind_options.item_count - 1, variable_kind)

func _select_kind(kind_options: OptionButton, variable_kind: String) -> void:
	for item_index in range(kind_options.item_count):
		if str(kind_options.get_item_metadata(item_index)) == variable_kind:
			kind_options.select(item_index)
			return
	kind_options.select(0)

func _on_kind_selected(_item_index: int, row_panel: PanelContainer) -> void:
	_apply_kind_visibility(row_panel)

func _apply_kind_visibility(row_panel: PanelContainer) -> void:
	var kind_options: OptionButton = row_panel.get_node("Body/Header/Kind")
	var variable_kind = str(kind_options.get_item_metadata(kind_options.selected))
	row_panel.get_node("Body/NumberFields").visible = variable_kind == KIND_NUMBER
	row_panel.get_node("Body/WordFields").visible = variable_kind == KIND_WORD
	row_panel.get_node("Body/GapFields").visible = variable_kind == KIND_GAP

func _on_insert_pressed(row_panel: PanelContainer) -> void:
	insert_variable_requested.emit(int(row_panel.get_meta("variable_id")))

func _on_delete_pressed(row_panel: PanelContainer) -> void:
	row_panel.queue_free()
	_update_empty_state.call_deferred()

func _update_empty_state() -> void:
	if empty_label == null:
		return
	var has_rows := false
	for row_node in rows_box.get_children():
		if row_node.has_meta("variable_row") && !row_node.is_queued_for_deletion():
			has_rows = true
			break
	empty_label.visible = !has_rows

func _default_label(variable_kind: String, variable_key: int) -> String:
	match variable_kind:
		KIND_NUMBER:
			return "n" + str(variable_key)
		KIND_WORD:
			return "word" + str(variable_key)
		KIND_GAP:
			return "gap" + str(variable_key)
	return "v" + str(variable_key)
