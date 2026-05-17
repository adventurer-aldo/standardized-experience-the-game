class_name FormulaAttemptRow
extends HBoxContainer

const FORMULA_EDITOR_SCRIPT := preload("res://scenes/data/DataQuestion/formula_editor.gd")

signal text_has_changed(difference: int)
signal text_focused
signal text_unfocused
signal add_row_requested
signal erase_if_empty_requested

var editor: Node
var result_label: RichTextLabel
var mark_label: Label
var delete_button: Button
var order_label: Label
var previous_length:= 0

func _ready() -> void:
	_ensure_layout()

func fetch() -> String:
	_ensure_layout()
	return editor.fetch()

func set_text(value: String) -> void:
	_ensure_layout()
	editor.set_formula_string(value)
	previous_length = editor.fetch_canonical().length()

func insert_variable(variable_token: String, display_name: String) -> void:
	_ensure_layout()
	editor.insert_variable(variable_token, display_name)

func get_focus() -> void:
	_ensure_layout()
	text_focused.emit()

func make_text_red() -> void:
	add_theme_color_override("font_color", Color.RED)

func tick() -> void:
	_ensure_layout()
	editor.hide()
	result_label.clear()
	result_label.append_text(editor.fetch_canonical())
	result_label.show()
	mark_label.text = "✓"
	mark_label.add_theme_color_override("font_color", Color(0.05, 0.42, 0.12))
	mark_label.show()

func cross(with_text: String, mark:= true) -> void:
	cross_precise(with_text, 0, mark)

func cross_precise(with_text: String, wrong_from:= 0, mark:= true) -> void:
	_ensure_layout()
	editor.hide()
	result_label.clear()
	var attempt_text = editor.fetch_canonical()
	var safe_wrong_from = clampi(wrong_from, 0, attempt_text.length())
	if safe_wrong_from > 0:
		result_label.append_text(attempt_text.substr(0, safe_wrong_from))
	result_label.push_strikethrough(Color.RED)
	result_label.append_text(attempt_text.substr(safe_wrong_from))
	result_label.pop()
	if with_text.strip_edges() != "":
		result_label.push_color(Color.RED)
		result_label.append_text("  " + FORMULA_EDITOR_SCRIPT.source_to_canonical(with_text))
		result_label.pop()
	result_label.show()
	if mark:
		mark_label.text = "✗"
		mark_label.add_theme_color_override("font_color", Color(0.72, 0.05, 0.07))
		mark_label.show()

func show_order(number: int) -> void:
	_ensure_layout()
	order_label.text = str(number)
	order_label.show()

func hide_order() -> void:
	if order_label != null:
		order_label.hide()

func enable_compact_gap_mode() -> void:
	custom_minimum_size = Vector2(220, 60)

func _ensure_layout() -> void:
	if editor != null && is_instance_valid(editor):
		return
	add_theme_constant_override("separation", 4)
	order_label = Label.new()
	order_label.custom_minimum_size = Vector2(28, 28)
	order_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	order_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	order_label.hide()
	add_child(order_label)
	editor = FORMULA_EDITOR_SCRIPT.new()
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.focused.connect(_on_editor_focused)
	editor.changed.connect(_on_editor_changed)
	add_child(editor)
	result_label = RichTextLabel.new()
	result_label.bbcode_enabled = true
	result_label.fit_content = true
	result_label.scroll_active = false
	result_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_label.hide()
	add_child(result_label)
	delete_button = Button.new()
	delete_button.text = "-"
	delete_button.focus_mode = Control.FOCUS_NONE
	delete_button.pressed.connect(_on_delete_pressed)
	add_child(delete_button)
	mark_label = Label.new()
	mark_label.custom_minimum_size = Vector2(32, 32)
	mark_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark_label.hide()
	add_child(mark_label)

func _on_editor_focused(_editor: Node) -> void:
	text_focused.emit()

func _on_editor_changed() -> void:
	var length = editor.fetch_canonical().length()
	var difference = length - previous_length
	previous_length = length
	if difference != 0:
		text_has_changed.emit(difference)

func _on_delete_pressed() -> void:
	queue_free()
