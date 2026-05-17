extends HBoxContainer

signal text_has_changed(difference: int)
signal text_focused
signal text_unfocused
signal add_row_requested
signal erase_if_empty_requested
var text:= ""
var order_label: Label

func fetch() -> String:
	return $TextsMargin/Text.text

func _ready() -> void:
	_ensure_order_label()

func _on_delete_button_pressed() -> void:
	queue_free()

func _input(event: InputEvent) -> void:
	if !$TextsMargin/Text.has_focus() || !(event is InputEventKey) || !event.pressed || event.echo:
		return
	if event.keycode == KEY_ENTER || event.keycode == KEY_KP_ENTER:
		accept_event()
		add_row_requested.emit()
	elif event.keycode == KEY_BACKSPACE || event.keycode == KEY_DELETE:
		if _delete_formula_token_at_caret(event.keycode == KEY_DELETE):
			accept_event()
			return
		if $TextsMargin/Text.text.strip_edges() == "":
			accept_event()
			erase_if_empty_requested.emit()

func set_text(to: String) -> void:
	$TextsMargin/Text.text = to

func insert_token(token_text: String) -> void:
	$TextsMargin/Text.grab_focus()
	$TextsMargin/Text.insert_text_at_caret(token_text)

func enable_compact_gap_mode() -> void:
	custom_minimum_size = Vector2(140, 42)
	$TextsMargin.custom_minimum_size = Vector2(120, 42)
	$TextsMargin/Text.custom_minimum_size = Vector2(120, 42)
	$TextsMargin/Text.wrap_mode = TextEdit.LINE_WRAPPING_NONE

func get_focus() -> void:
	$TextsMargin/Text.grab_focus()

func _on_text_text_changed() -> void:
	var diff = $TextsMargin/Text.text.strip_edges().length() - text.strip_edges().length()
	text = $TextsMargin/Text.text
	if diff!= 0: text_has_changed.emit(diff)

func _on_text_focus_entered() -> void:
	text_focused.emit()
	$DeleteButton.show()

func _on_text_focus_exited() -> void:
	text_unfocused.emit()
	$DeleteButton.hide()

func make_text_red() -> void:
	$TextsMargin/Text.add_theme_color_override("font_color", Color.RED)

func tick() -> void:
	$TextsMargin/Text.hide()
	$Correction/Tick.show()
	$TextsMargin/RTL.clear()
	$TextsMargin/RTL.append_text(_display_text($TextsMargin/Text.text))

func cross(with_text: String, mark:= true) -> void:
	cross_precise(with_text, 0, mark)

func cross_precise(with_text: String, wrong_from:= 0, mark:= true) -> void:
	$TextsMargin/Text.hide()
	$DeleteButton.hide()
	$TextsMargin/RTL.clear()
	var attempt_text = _display_text($TextsMargin/Text.text)
	var safe_wrong_from = clampi(wrong_from, 0, attempt_text.length())
	if safe_wrong_from > 0:
		$TextsMargin/RTL.append_text(attempt_text.substr(0, safe_wrong_from))
	$TextsMargin/RTL.push_strikethrough(Color.RED)
	$TextsMargin/RTL.append_text(attempt_text.substr(safe_wrong_from))
	$TextsMargin/RTL.pop()
	if with_text.strip_edges() != "":
		$TextsMargin/RTL.push_color(Color.RED)
		$TextsMargin/RTL.append_text(_display_text(with_text))
		$TextsMargin/RTL.pop()
	if mark:
		$Correction/Cross.show()

func show_order(number: int) -> void:
	_ensure_order_label()
	order_label.text = str(number)
	order_label.show()

func hide_order() -> void:
	if order_label != null:
		order_label.hide()

func _ensure_order_label() -> void:
	if order_label != null:
		return
	order_label = Label.new()
	order_label.name = "Order"
	order_label.text = "1"
	order_label.custom_minimum_size = Vector2(28, 28)
	order_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	order_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	order_label.add_theme_color_override("font_color", Color(0.05, 0.06, 0.08))
	order_label.hide()
	add_child(order_label)

func _display_text(raw_value) -> String:
	var display_value = str(raw_value)
	display_value = display_value.replace(Question.make_formula_token("fraction"), "frac")
	display_value = display_value.replace(Question.make_formula_token("log"), "log")
	display_value = display_value.replace(Question.make_formula_token("sin"), "sin")
	display_value = display_value.replace(Question.make_formula_token("cos"), "cos")
	display_value = display_value.replace(Question.make_formula_token("tan"), "tan")
	return display_value

func _delete_formula_token_at_caret(delete_forward: bool) -> bool:
	var raw_value = $TextsMargin/Text.text
	var caret_index = _caret_absolute_index()
	var probe_index = caret_index if delete_forward else caret_index - 1
	if probe_index < 0 || probe_index >= raw_value.length():
		return false
	var token_bounds = _find_token_bounds(raw_value, probe_index)
	if token_bounds.is_empty():
		return false
	var start_index = int(token_bounds["start"])
	var end_index = int(token_bounds["end"])
	$TextsMargin/Text.text = raw_value.substr(0, start_index) + raw_value.substr(end_index)
	var caret_position = _line_column_for_absolute($TextsMargin/Text.text, start_index)
	$TextsMargin/Text.set_caret_line(int(caret_position["line"]))
	$TextsMargin/Text.set_caret_column(int(caret_position["column"]))
	return true

func _find_token_bounds(raw_value: String, probe_index: int) -> Dictionary:
	var start_index = raw_value.rfind(Question.FORMULA_TOKEN_OPEN, probe_index)
	if start_index < 0:
		return {}
	var end_marker_index = raw_value.find(Question.FORMULA_TOKEN_CLOSE, start_index + Question.FORMULA_TOKEN_OPEN.length())
	if end_marker_index < 0:
		return {}
	var end_index = end_marker_index + Question.FORMULA_TOKEN_CLOSE.length()
	if probe_index < start_index || probe_index >= end_index:
		return {}
	return {"start": start_index, "end": end_index}

func _caret_absolute_index() -> int:
	var caret_line = $TextsMargin/Text.get_caret_line()
	var caret_column = $TextsMargin/Text.get_caret_column()
	var absolute_index := 0
	for line_index in range(caret_line):
		absolute_index += $TextsMargin/Text.get_line(line_index).length() + 1
	return absolute_index + caret_column

func _line_column_for_absolute(raw_value: String, absolute_index: int) -> Dictionary:
	var safe_index = clampi(absolute_index, 0, raw_value.length())
	var line_index := 0
	var line_start := 0
	for character_index in range(safe_index):
		if raw_value.substr(character_index, 1) == "\n":
			line_index += 1
			line_start = character_index + 1
	return {"line": line_index, "column": safe_index - line_start}
