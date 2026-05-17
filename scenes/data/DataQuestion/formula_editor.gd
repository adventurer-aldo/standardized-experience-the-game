class_name FormulaEditor
extends VBoxContainer

signal changed
signal focused(editor: FormulaEditor)
signal variable_pressed(variable_key)

const SERIALIZED_PREFIX := "@formula:"

var elements: Array = []
var canvas: HFlowContainer
var toolbar: HFlowContainer
var selected_index:= -1
var read_only:= false
var focused_formula_input: LineEdit
var focused_input_index:= -1
var focused_input_key:= ""
var focused_matrix_cell_index:= -1

func _ready() -> void:
	_ensure_layout()
	if elements.is_empty():
		_insert_element({"type": "text", "value": ""}, -1)

func set_read_only(enabled: bool) -> void:
	read_only = enabled
	_ensure_layout()
	toolbar.visible = !read_only
	_rebuild_canvas()

func set_formula_string(value) -> void:
	_ensure_layout()
	elements = parse_formula_elements(value)
	if elements.is_empty():
		elements = [{"type": "text", "value": str(value)}]
	selected_index = -1
	_rebuild_canvas()

func fetch() -> String:
	return serialize_formula_elements(elements)

func fetch_canonical() -> String:
	return formula_elements_to_canonical(elements)

func insert_variable(variable_token: String, display_name: String, variable_key:= "") -> void:
	if focused_formula_input != null && is_instance_valid(focused_formula_input) && focused_input_index >= 0 && focused_input_index < elements.size():
		focused_formula_input.insert_text_at_caret(variable_token)
		if elements[focused_input_index] is Dictionary:
			if focused_input_key == "cells":
				var focused_cells = Array(elements[focused_input_index].get("cells", []))
				while focused_matrix_cell_index >= focused_cells.size():
					focused_cells.push_back("")
				focused_cells[focused_matrix_cell_index] = focused_formula_input.text
				elements[focused_input_index]["cells"] = focused_cells
			else:
				elements[focused_input_index][focused_input_key] = focused_formula_input.text
			changed.emit()
		return
	_insert_element({
		"type": "variable",
		"token": variable_token,
		"label": display_name,
		"variable_id": str(variable_key),
	}, selected_index)

func insert_text_fragment(fragment: String) -> void:
	_insert_element({"type": "text", "value": fragment}, selected_index)

static func serialize_formula_elements(source_elements: Array) -> String:
	return SERIALIZED_PREFIX + JSON.stringify(source_elements)

static func parse_formula_elements(value) -> Array:
	if value is Array:
		return value.duplicate(true)
	var raw_value = str(value)
	if raw_value.begins_with(SERIALIZED_PREFIX):
		var json = JSON.new()
		if json.parse(raw_value.substr(SERIALIZED_PREFIX.length())) == OK && json.data is Array:
			return Array(json.data).duplicate(true)
	if raw_value.strip_edges() == "":
		return []
	return [{"type": "text", "value": raw_value}]

static func formula_elements_to_canonical(source_elements: Array) -> String:
	var pieces := []
	for element in source_elements:
		if !(element is Dictionary):
			continue
		pieces.push_back(_element_to_canonical(element))
	return " ".join(pieces).strip_edges()

static func source_to_canonical(value) -> String:
	return formula_elements_to_canonical(parse_formula_elements(value))

static func is_formula_string(value) -> bool:
	return str(value).begins_with(SERIALIZED_PREFIX)

static func _element_to_canonical(element: Dictionary) -> String:
	match str(element.get("type", "text")):
		"text":
			return str(element.get("value", "")).strip_edges()
		"variable":
			return str(element.get("token", element.get("label", ""))).strip_edges()
		"operator":
			return str(element.get("value", "")).strip_edges()
		"fraction":
			return "(" + str(element.get("top", "")).strip_edges() + ")/(" + str(element.get("bottom", "")).strip_edges() + ")"
		"power":
			return "(" + str(element.get("base", "")).strip_edges() + ")^(" + str(element.get("exponent", "")).strip_edges() + ")"
		"subscript":
			return str(element.get("base", "")).strip_edges() + "_(" + str(element.get("subscript", "")).strip_edges() + ")"
		"root":
			var degree = str(element.get("degree", "")).strip_edges()
			var radicand = str(element.get("radicand", "")).strip_edges()
			return "sqrt(" + radicand + ")" if degree == "" else "root(" + degree + "," + radicand + ")"
		"function":
			return str(element.get("name", "")).strip_edges() + "(" + str(element.get("argument", "")).strip_edges() + ")"
		"group":
			return str(element.get("open", "(")) + str(element.get("value", "")).strip_edges() + str(element.get("close", ")"))
		"absolute":
			return "abs(" + str(element.get("value", "")).strip_edges() + ")"
		"limit":
			return "lim_(" + str(element.get("towards", "")).strip_edges() + ") " + str(element.get("body", "")).strip_edges()
		"sum":
			return "sum_(" + str(element.get("lower", "")).strip_edges() + ")^(" + str(element.get("upper", "")).strip_edges() + ") " + str(element.get("body", "")).strip_edges()
		"integral":
			return "int_(" + str(element.get("lower", "")).strip_edges() + ")^(" + str(element.get("upper", "")).strip_edges() + ") " + str(element.get("body", "")).strip_edges() + " d" + str(element.get("differential", "x")).strip_edges()
		"matrix":
			var cells = Array(element.get("cells", []))
			return "matrix(" + ", ".join(cells.map(func(cell): return str(cell).strip_edges())) + ")"
	return str(element.get("value", "")).strip_edges()

func _ensure_layout() -> void:
	if canvas != null && is_instance_valid(canvas):
		return
	add_theme_constant_override("separation", 6)
	canvas = HFlowContainer.new()
	canvas.name = "Canvas"
	canvas.custom_minimum_size = Vector2(0, 54)
	canvas.alignment = FlowContainer.ALIGNMENT_BEGIN
	add_child(canvas)
	toolbar = HFlowContainer.new()
	toolbar.name = "Toolbar"
	toolbar.alignment = FlowContainer.ALIGNMENT_BEGIN
	add_child(toolbar)
	for entry in _toolbar_entries():
		var button = Button.new()
		button.text = str(entry.get("text", ""))
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = str(entry.get("hint", ""))
		button.pressed.connect(_on_toolbar_entry_pressed.bind(entry))
		toolbar.add_child(button)
	toolbar.visible = !read_only

func _toolbar_entries() -> Array:
	return [
		{"text": "□", "kind": "text", "hint": "Text, number, or unit"},
		{"text": "+", "kind": "operator", "value": "+", "hint": "Addition operator"},
		{"text": "-", "kind": "operator", "value": "-", "hint": "Subtraction operator"},
		{"text": "×", "kind": "operator", "value": "*", "hint": "Multiplication operator"},
		{"text": "÷", "kind": "operator", "value": "/", "hint": "Division operator"},
		{"text": "=", "kind": "operator", "value": "=", "hint": "Equals"},
		{"text": "≠", "kind": "operator", "value": "!=", "hint": "Not equal"},
		{"text": "<", "kind": "operator", "value": "<", "hint": "Less than"},
		{"text": "≤", "kind": "operator", "value": "<=", "hint": "Less than or equal"},
		{"text": "≥", "kind": "operator", "value": ">=", "hint": "Greater than or equal"},
		{"text": "π", "kind": "operator", "value": "pi", "hint": "Pi"},
		{"text": "e", "kind": "operator", "value": "e", "hint": "Euler's number"},
		{"text": "a/b", "kind": "fraction", "hint": "Fraction"},
		{"text": "x^n", "kind": "power", "hint": "Exponent"},
		{"text": "x_i", "kind": "subscript", "hint": "Subscript"},
		{"text": "√", "kind": "root", "hint": "Root"},
		{"text": "|x|", "kind": "absolute", "hint": "Absolute value"},
		{"text": "( )", "kind": "group", "open": "(", "close": ")", "hint": "Parentheses"},
		{"text": "[ ]", "kind": "group", "open": "[", "close": "]", "hint": "Brackets"},
		{"text": "sin", "kind": "function", "name": "sin", "hint": "Sine"},
		{"text": "cos", "kind": "function", "name": "cos", "hint": "Cosine"},
		{"text": "tan", "kind": "function", "name": "tan", "hint": "Tangent"},
		{"text": "log", "kind": "function", "name": "log", "hint": "Logarithm"},
		{"text": "ln", "kind": "function", "name": "ln", "hint": "Natural logarithm"},
		{"text": "lim", "kind": "limit", "hint": "Limit"},
		{"text": "Σ", "kind": "sum", "hint": "Summation"},
		{"text": "∫", "kind": "integral", "hint": "Integral"},
		{"text": "2×2", "kind": "matrix", "hint": "2 by 2 matrix"},
		{"text": "⌫", "kind": "delete", "hint": "Delete selected element"},
	]

func _on_toolbar_entry_pressed(entry: Dictionary) -> void:
	match str(entry.get("kind", "")):
		"text":
			_insert_element({"type": "text", "value": ""}, selected_index)
		"operator":
			_insert_element({"type": "operator", "value": str(entry.get("value", ""))}, selected_index)
		"fraction":
			_insert_element({"type": "fraction", "top": "", "bottom": ""}, selected_index)
		"power":
			_insert_element({"type": "power", "base": "", "exponent": ""}, selected_index)
		"subscript":
			_insert_element({"type": "subscript", "base": "", "subscript": ""}, selected_index)
		"root":
			_insert_element({"type": "root", "degree": "", "radicand": ""}, selected_index)
		"absolute":
			_insert_element({"type": "absolute", "value": ""}, selected_index)
		"group":
			_insert_element({"type": "group", "open": str(entry.get("open", "(")), "close": str(entry.get("close", ")")), "value": ""}, selected_index)
		"function":
			_insert_element({"type": "function", "name": str(entry.get("name", "")), "argument": ""}, selected_index)
		"limit":
			_insert_element({"type": "limit", "towards": "", "body": ""}, selected_index)
		"sum":
			_insert_element({"type": "sum", "lower": "", "upper": "", "body": ""}, selected_index)
		"integral":
			_insert_element({"type": "integral", "lower": "", "upper": "", "body": "", "differential": "x"}, selected_index)
		"matrix":
			_insert_element({"type": "matrix", "rows": 2, "columns": 2, "cells": ["", "", "", ""]}, selected_index)
		"delete":
			_delete_selected()

func _insert_element(element: Dictionary, after_index: int) -> void:
	var insert_index = clampi(after_index + 1, 0, elements.size())
	elements.insert(insert_index, element)
	selected_index = insert_index
	_rebuild_canvas()
	changed.emit()

func _delete_selected() -> void:
	if selected_index < 0 || selected_index >= elements.size():
		return
	elements.remove_at(selected_index)
	selected_index = mini(selected_index, elements.size() - 1)
	if elements.is_empty():
		elements.push_back({"type": "text", "value": ""})
		selected_index = 0
	_rebuild_canvas()
	changed.emit()

func _rebuild_canvas() -> void:
	_ensure_layout()
	for child in canvas.get_children():
		child.free()
	for index in range(elements.size()):
		canvas.add_child(_make_element_control(index))

func _make_element_control(index: int) -> Control:
	var element = elements[index]
	if !(element is Dictionary):
		element = {"type": "text", "value": str(element)}
		elements[index] = element
	var panel = PanelContainer.new()
	panel.name = "Element"
	panel.set_meta("formula_element_index", index)
	panel.focus_mode = Control.FOCUS_CLICK
	panel.gui_input.connect(_on_element_gui_input.bind(index))
	_apply_element_style(panel, index == selected_index)
	panel.add_child(_make_inner_control(index, element))
	return panel

func _apply_element_style(panel: PanelContainer, selected: bool) -> void:
	var element_style = StyleBoxFlat.new()
	element_style.bg_color = Color(0.92, 0.96, 1.0, 1.0) if !selected else Color(1.0, 0.88, 0.55, 1.0)
	element_style.border_width_left = 1
	element_style.border_width_top = 1
	element_style.border_width_right = 1
	element_style.border_width_bottom = 1
	element_style.border_color = Color(0.18, 0.34, 0.52, 0.85)
	element_style.corner_radius_top_left = 4
	element_style.corner_radius_top_right = 4
	element_style.corner_radius_bottom_right = 4
	element_style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", element_style)

func _refresh_selected_element_style() -> void:
	if canvas == null || !is_instance_valid(canvas):
		return
	for child_node in canvas.get_children():
		if !(child_node is PanelContainer) || !child_node.has_meta("formula_element_index"):
			continue
		_apply_element_style(child_node, int(child_node.get_meta("formula_element_index")) == selected_index)

func _make_inner_control(index: int, element: Dictionary) -> Control:
	match str(element.get("type", "text")):
		"text":
			return _make_line_edit(index, "value", str(element.get("value", "")), Vector2(84, 32))
		"variable":
			var button = Button.new()
			button.text = str(element.get("label", "var"))
			button.focus_mode = Control.FOCUS_NONE
			button.disabled = read_only
			button.pressed.connect(_on_variable_pressed.bind(element))
			return button
		"operator":
			var label = Label.new()
			label.text = _operator_display(str(element.get("value", "")))
			label.custom_minimum_size = Vector2(32, 32)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			return label
		"fraction":
			var box = VBoxContainer.new()
			box.add_child(_make_line_edit(index, "top", str(element.get("top", "")), Vector2(90, 28)))
			var line = ColorRect.new()
			line.color = Color(0.05, 0.06, 0.08, 1.0)
			line.custom_minimum_size = Vector2(90, 2)
			box.add_child(line)
			box.add_child(_make_line_edit(index, "bottom", str(element.get("bottom", "")), Vector2(90, 28)))
			return box
		"power":
			var box = HBoxContainer.new()
			box.add_child(_make_line_edit(index, "base", str(element.get("base", "")), Vector2(70, 34)))
			var exponent = _make_line_edit(index, "exponent", str(element.get("exponent", "")), Vector2(50, 24))
			exponent.add_theme_font_size_override("font_size", 14)
			box.add_child(exponent)
			return box
		"subscript":
			var box = HBoxContainer.new()
			box.add_child(_make_line_edit(index, "base", str(element.get("base", "")), Vector2(70, 34)))
			var subscript = _make_line_edit(index, "subscript", str(element.get("subscript", "")), Vector2(50, 24))
			subscript.add_theme_font_size_override("font_size", 14)
			box.add_child(subscript)
			return box
		"root":
			var box = HBoxContainer.new()
			var degree = _make_line_edit(index, "degree", str(element.get("degree", "")), Vector2(34, 24))
			degree.add_theme_font_size_override("font_size", 13)
			box.add_child(degree)
			var radical = Label.new()
			radical.text = "√"
			radical.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			box.add_child(radical)
			box.add_child(_make_line_edit(index, "radicand", str(element.get("radicand", "")), Vector2(90, 34)))
			return box
		"function":
			var box = HBoxContainer.new()
			var name_label = Label.new()
			name_label.text = str(element.get("name", "f")) + "("
			name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			box.add_child(name_label)
			box.add_child(_make_line_edit(index, "argument", str(element.get("argument", "")), Vector2(90, 34)))
			var close_label = Label.new()
			close_label.text = ")"
			close_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			box.add_child(close_label)
			return box
		"group":
			var box = HBoxContainer.new()
			box.add_child(_make_label(str(element.get("open", "("))))
			box.add_child(_make_line_edit(index, "value", str(element.get("value", "")), Vector2(90, 34)))
			box.add_child(_make_label(str(element.get("close", ")"))))
			return box
		"absolute":
			var box = HBoxContainer.new()
			box.add_child(_make_label("|"))
			box.add_child(_make_line_edit(index, "value", str(element.get("value", "")), Vector2(90, 34)))
			box.add_child(_make_label("|"))
			return box
		"limit":
			var box = VBoxContainer.new()
			box.add_child(_make_line_edit(index, "towards", str(element.get("towards", "")), Vector2(90, 24)))
			var row = HBoxContainer.new()
			row.add_child(_make_label("lim"))
			row.add_child(_make_line_edit(index, "body", str(element.get("body", "")), Vector2(100, 34)))
			box.add_child(row)
			return box
		"sum":
			return _make_big_operator(index, "Σ", element, "lower", "upper", "body")
		"integral":
			var box = _make_big_operator(index, "∫", element, "lower", "upper", "body")
			box.add_child(_make_line_edit(index, "differential", str(element.get("differential", "x")), Vector2(44, 24)))
			return box
		"matrix":
			return _make_matrix(index, element)
	return _make_line_edit(index, "value", str(element.get("value", "")), Vector2(84, 32))

func _make_big_operator(index: int, symbol: String, element: Dictionary, lower_key: String, upper_key: String, body_key: String) -> VBoxContainer:
	var box = VBoxContainer.new()
	box.add_child(_make_line_edit(index, upper_key, str(element.get(upper_key, "")), Vector2(70, 22)))
	var row = HBoxContainer.new()
	row.add_child(_make_label(symbol, 24))
	row.add_child(_make_line_edit(index, body_key, str(element.get(body_key, "")), Vector2(100, 34)))
	box.add_child(row)
	box.add_child(_make_line_edit(index, lower_key, str(element.get(lower_key, "")), Vector2(70, 22)))
	return box

func _make_matrix(index: int, element: Dictionary) -> GridContainer:
	var grid = GridContainer.new()
	grid.columns = int(element.get("columns", 2))
	var cells = Array(element.get("cells", ["", "", "", ""]))
	for cell_index in range(cells.size()):
		var input = LineEdit.new()
		input.custom_minimum_size = Vector2(48, 28)
		input.text = str(cells[cell_index])
		input.editable = !read_only
		input.focus_entered.connect(_on_matrix_focus_entered.bind(index, cell_index, input))
		input.text_changed.connect(_on_matrix_cell_changed.bind(index, cell_index))
		grid.add_child(input)
	return grid

func _make_line_edit(index: int, key: String, value: String, minimum_size: Vector2) -> LineEdit:
	var input = LineEdit.new()
	input.text = value
	input.editable = !read_only
	input.custom_minimum_size = minimum_size
	input.focus_entered.connect(_on_line_edit_focus_entered.bind(index, key, input))
	input.text_changed.connect(_on_element_text_changed.bind(index, key))
	return input

func _make_label(value: String, font_size:= 18) -> Label:
	var label = Label.new()
	label.text = value
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _on_element_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		_on_element_focus_entered(index)

func _on_element_focus_entered(index: int) -> void:
	selected_index = index
	focused_formula_input = null
	focused_input_index = -1
	focused_input_key = ""
	focused_matrix_cell_index = -1
	_refresh_selected_element_style()
	focused.emit(self)

func _on_line_edit_focus_entered(index: int, key: String, input: LineEdit) -> void:
	focused_formula_input = input
	focused_input_index = index
	focused_input_key = key
	focused_matrix_cell_index = -1
	selected_index = index
	_refresh_selected_element_style()
	focused.emit(self)

func _on_matrix_focus_entered(index: int, cell_index: int, input: LineEdit) -> void:
	focused_formula_input = input
	focused_input_index = index
	focused_input_key = "cells"
	focused_matrix_cell_index = cell_index
	selected_index = index
	_refresh_selected_element_style()
	focused.emit(self)

func _on_element_text_changed(new_text: String, index: int, key: String) -> void:
	if index < 0 || index >= elements.size() || !(elements[index] is Dictionary):
		return
	elements[index][key] = new_text
	changed.emit()

func _on_matrix_cell_changed(new_text: String, index: int, cell_index: int) -> void:
	if index < 0 || index >= elements.size() || !(elements[index] is Dictionary):
		return
	var cells = Array(elements[index].get("cells", []))
	while cell_index >= cells.size():
		cells.push_back("")
	cells[cell_index] = new_text
	elements[index]["cells"] = cells
	changed.emit()

func _operator_display(value: String) -> String:
	match value:
		"*":
			return "×"
		"/":
			return "÷"
		"!=":
			return "≠"
		"<=":
			return "≤"
		">=":
			return "≥"
		"pi":
			return "π"
	return value

func _on_variable_pressed(element: Dictionary) -> void:
	variable_pressed.emit(str(element.get("variable_id", "")))
