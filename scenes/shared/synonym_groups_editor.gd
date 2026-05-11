extends PanelContainer

signal groups_changed(groups: Array)

var title_text:= "Synonyms"
var empty_text:= "No synonym groups yet."
var groups: Array = []
var selected_group_index:= -1
@onready var list: VBoxContainer = $Margin/Root/Columns/WordScroll/WordButtons
@onready var detail: VBoxContainer = $Margin/Root/Columns/Detail
@onready var title_label: Label = $Margin/Root/Header/Title

func _ready() -> void:
	_bind_scene_nodes()
	_refresh()

func setup(new_title: String, new_empty_text:= "") -> void:
	title_text = new_title
	if new_empty_text != "":
		empty_text = new_empty_text
	_bind_scene_nodes()
	_refresh()

func set_groups(new_groups: Array) -> void:
	groups = _clean_groups(new_groups)
	selected_group_index = 0 if !groups.is_empty() else -1
	_bind_scene_nodes()
	_refresh()

func get_synonym_groups() -> Array:
	return _clean_groups(groups)

func _bind_scene_nodes() -> void:
	if !is_inside_tree():
		return
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	if title_label != null:
		title_label.text = title_text

func _refresh() -> void:
	if list == null || detail == null:
		return
	_refresh_list()
	_refresh_detail()

func _refresh_list() -> void:
	for child in list.get_children():
		child.queue_free()
	if groups.is_empty():
		var empty = Label.new()
		empty.text = empty_text
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list.add_child(empty)
		return
	for group_index in range(groups.size()):
		var terms = Array(groups[group_index])
		for term_index in range(terms.size()):
			var word = str(terms[term_index]).strip_edges()
			if word == "":
				continue
			var word_button = Button.new()
			word_button.text = word
			word_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			word_button.toggle_mode = true
			word_button.button_pressed = group_index == selected_group_index
			word_button.tooltip_text = "Show this synonym group"
			word_button.pressed.connect(_select_group.bind(group_index))
			list.add_child(word_button)

func _refresh_detail() -> void:
	for child in detail.get_children():
		child.queue_free()
	if selected_group_index < 0 || selected_group_index >= groups.size():
		var empty = Label.new()
		empty.text = "Select a word to edit its equivalents."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.add_child(empty)
		return
	var group = Array(groups[selected_group_index])
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	detail.add_child(header)

	var title = Label.new()
	title.text = "Treat These As The Same"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 18)
	header.add_child(title)

	var delete_group = Button.new()
	delete_group.text = "Delete Group"
	delete_group.custom_minimum_size = Vector2(120, 32)
	delete_group.pressed.connect(_on_delete_group_pressed)
	header.add_child(delete_group)

	for word_index in range(group.size()):
		_add_word_row(word_index, str(group[word_index]))

	var add_word = Button.new()
	add_word.text = "+ Word"
	add_word.custom_minimum_size = Vector2(120, 32)
	add_word.pressed.connect(_on_add_word_pressed)
	detail.add_child(add_word)

func _add_word_row(word_index: int, word: String) -> void:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	detail.add_child(row)

	var input = LineEdit.new()
	input.text = word
	input.placeholder_text = "Word or exact phrase"
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.text_changed.connect(_on_word_text_changed.bind(selected_group_index, word_index))
	input.focus_exited.connect(_refresh_list)
	row.add_child(input)

	var delete_word = Button.new()
	delete_word.text = "-"
	delete_word.custom_minimum_size = Vector2(34, 32)
	delete_word.tooltip_text = "Remove word"
	delete_word.pressed.connect(_on_delete_word_pressed.bind(word_index))
	row.add_child(delete_word)

func _select_group(group_index: int) -> void:
	selected_group_index = group_index
	_refresh()

func _on_add_group_pressed() -> void:
	groups.push_back(["New word", "Equivalent word"])
	selected_group_index = groups.size() - 1
	_refresh()
	_emit_changed()

func _on_add_word_pressed() -> void:
	if selected_group_index < 0 || selected_group_index >= groups.size():
		return
	groups[selected_group_index].push_back("")
	_refresh_detail()
	_emit_changed()

func _on_delete_group_pressed() -> void:
	if selected_group_index < 0 || selected_group_index >= groups.size():
		return
	groups.remove_at(selected_group_index)
	selected_group_index = min(selected_group_index, groups.size() - 1)
	_refresh()
	_emit_changed()

func _on_delete_word_pressed(word_index: int) -> void:
	if selected_group_index < 0 || selected_group_index >= groups.size():
		return
	var group = Array(groups[selected_group_index])
	if word_index >= 0 && word_index < group.size():
		group.remove_at(word_index)
	groups[selected_group_index] = group
	if group.is_empty():
		groups.remove_at(selected_group_index)
		selected_group_index = min(selected_group_index, groups.size() - 1)
	_refresh()
	_emit_changed()

func _on_word_text_changed(new_text: String, group_index: int, word_index: int) -> void:
	if group_index < 0 || group_index >= groups.size():
		return
	var group = Array(groups[group_index])
	if word_index < 0 || word_index >= group.size():
		return
	group[word_index] = new_text
	groups[group_index] = group
	_emit_changed()

func _emit_changed() -> void:
	groups_changed.emit(get_synonym_groups())

func _clean_groups(source_groups: Array) -> Array:
	var cleaned := []
	for group in source_groups:
		var source_terms = group.split(",", false) if group is String else Array(group)
		var clean_group := []
		var seen := {}
		for term in source_terms:
			var clean = str(term).strip_edges()
			var key = clean.to_lower()
			if clean != "" && !seen.has(key):
				clean_group.push_back(clean)
				seen[key] = true
		if clean_group.size() > 1:
			cleaned.push_back(clean_group)
	return cleaned
