extends PanelContainer

const FORMULA_EDITOR_SCRIPT := preload("res://scenes/data/DataQuestion/formula_editor.gd")

signal formula_focused(editor: Node)
signal variable_pressed(variable_key)

var rows_box: VBoxContainer

func _ready() -> void:
	_ensure_layout()
	if rows_box.get_child_count() == 0:
		_add_answer_row()

func fetch() -> Array:
	_ensure_layout()
	var answer_sets := []
	for row in rows_box.get_children():
		if !row.has_meta("formula_answer_row"):
			continue
		var texts := []
		var main_editor: Node = row.get_node("Body/Main/Formula")
		texts.push_back(main_editor.fetch())
		var alts_box: VBoxContainer = row.get_node("Body/Alts")
		for alt_row in alts_box.get_children():
			if alt_row.has_node("Formula"):
				var alt_editor: Node = alt_row.get_node("Formula")
				texts.push_back(alt_editor.fetch())
		answer_sets.push_back({"texts": texts, "media": []})
	return answer_sets

func replicate(answer_sets: Array) -> void:
	_ensure_layout()
	reset(true)
	for answer_set_index in range(answer_sets.size()):
		if answer_set_index >= rows_box.get_child_count():
			_add_answer_row()
		var row = rows_box.get_child(answer_set_index)
		var texts = Array(answer_sets[answer_set_index].get("texts", [])) if answer_sets[answer_set_index] is Dictionary else Array(answer_sets[answer_set_index])
		if texts.is_empty():
			texts = [""]
		var main_editor: Node = row.get_node("Body/Main/Formula")
		main_editor.set_formula_string(texts[0])
		var alts_box: VBoxContainer = row.get_node("Body/Alts")
		for alt_index in range(1, texts.size()):
			var alt_row = _add_alt_row(alts_box)
			var alt_editor: Node = alt_row.get_node("Formula")
			alt_editor.set_formula_string(texts[alt_index])

func reset(full:= false) -> void:
	_ensure_layout()
	for row in rows_box.get_children():
		row.free()
	if full:
		_add_answer_row()

func insert_variable(variable_token: String, display_name: String, target_editor: Node, variable_key:= "") -> void:
	var editor = target_editor
	if editor == null || !is_instance_valid(editor):
		editor = _first_formula_editor()
	if editor != null:
		editor.insert_variable(variable_token, display_name, variable_key)

func _ensure_layout() -> void:
	if rows_box != null && is_instance_valid(rows_box):
		return
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)
	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	margin.add_child(root)
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	root.add_child(header)
	var title = Label.new()
	title.text = "Formula Answers"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var add_button = Button.new()
	add_button.text = "+ Answer"
	add_button.focus_mode = Control.FOCUS_NONE
	add_button.pressed.connect(_add_answer_row)
	header.add_child(add_button)
	rows_box = VBoxContainer.new()
	rows_box.name = "Rows"
	rows_box.add_theme_constant_override("separation", 6)
	root.add_child(rows_box)

func _add_answer_row() -> PanelContainer:
	var row = PanelContainer.new()
	row.name = "FormulaAnswerRow"
	row.set_meta("formula_answer_row", true)
	var body = VBoxContainer.new()
	body.name = "Body"
	body.add_theme_constant_override("separation", 4)
	row.add_child(body)
	var main = HBoxContainer.new()
	main.name = "Main"
	main.add_theme_constant_override("separation", 4)
	body.add_child(main)
	var add_alt = Button.new()
	add_alt.text = "+ Alt"
	add_alt.focus_mode = Control.FOCUS_NONE
	add_alt.pressed.connect(_on_add_alt_pressed.bind(row))
	main.add_child(add_alt)
	var formula = FORMULA_EDITOR_SCRIPT.new()
	formula.name = "Formula"
	formula.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	formula.focused.connect(_on_formula_focused)
	formula.variable_pressed.connect(_on_variable_pressed)
	main.add_child(formula)
	var delete_button = Button.new()
	delete_button.text = "-"
	delete_button.focus_mode = Control.FOCUS_NONE
	delete_button.pressed.connect(_on_delete_row_pressed.bind(row))
	main.add_child(delete_button)
	var alts = VBoxContainer.new()
	alts.name = "Alts"
	alts.add_theme_constant_override("separation", 4)
	body.add_child(alts)
	rows_box.add_child(row)
	return row

func _on_add_alt_pressed(row: PanelContainer) -> void:
	_add_alt_row(row.get_node("Body/Alts"))

func _add_alt_row(alts_box: VBoxContainer) -> HBoxContainer:
	var alt_row = HBoxContainer.new()
	alt_row.name = "Alt"
	alt_row.add_theme_constant_override("separation", 4)
	var delete_button = Button.new()
	delete_button.text = "-"
	delete_button.focus_mode = Control.FOCUS_NONE
	delete_button.pressed.connect(alt_row.queue_free)
	alt_row.add_child(delete_button)
	var formula = FORMULA_EDITOR_SCRIPT.new()
	formula.name = "Formula"
	formula.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	formula.focused.connect(_on_formula_focused)
	formula.variable_pressed.connect(_on_variable_pressed)
	alt_row.add_child(formula)
	alts_box.add_child(alt_row)
	return alt_row

func _on_delete_row_pressed(row: PanelContainer) -> void:
	if rows_box.get_child_count() <= 1:
		var editor: Node = row.get_node("Body/Main/Formula")
		editor.set_formula_string("")
		for child in row.get_node("Body/Alts").get_children():
			child.queue_free()
		return
	row.queue_free()

func _on_formula_focused(editor: Node) -> void:
	formula_focused.emit(editor)

func _on_variable_pressed(variable_key) -> void:
	variable_pressed.emit(variable_key)

func _first_formula_editor() -> Node:
	for row in rows_box.get_children():
		if row.has_node("Body/Main/Formula"):
			return row.get_node("Body/Main/Formula")
	return null
