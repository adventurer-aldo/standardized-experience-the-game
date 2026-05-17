extends PanelContainer

signal groups_changed(groups: Array)

var title_text:= "Synonyms"
var empty_text:= "No synonym groups yet."
var groups: Array = []
var selected_group_index:= -1
@onready var list: VBoxContainer = $Margin/Root/Columns/WordScroll/WordButtons
@onready var detail: VBoxContainer = $Margin/Root/Columns/Detail
@onready var title_label: Label = $Margin/Root/Header/Title
@onready var new_word_input: LineEdit = $Margin/Root/NewGroup/Inputs/Word
@onready var new_synonyms_input: LineEdit = $Margin/Root/NewGroup/Inputs/Synonyms
@onready var warning_label: Label = $Margin/Root/NewGroup/Warning
var warning_clear_timer: SceneTreeTimer
var warning_generation:= 0

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

func can_save() -> bool:
	var validation_message = _validate_groups()
	if validation_message != "":
		_show_warning(validation_message)
		return false
	return true

func submit_pending_group_if_any() -> bool:
	var word = new_word_input.text.strip_edges() if new_word_input != null else ""
	var synonyms_text = new_synonyms_input.text.strip_edges() if new_synonyms_input != null else ""
	if word == "" && synonyms_text == "":
		return true
	return _submit_group_from_inputs()

func _bind_scene_nodes() -> void:
	if !is_inside_tree():
		return
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	if title_label != null:
		title_label.text = title_text
	if warning_label != null && warning_label.text.strip_edges() == "":
		warning_label.visible = false

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
		var word = str(terms[0]).strip_edges() if !terms.is_empty() else ""
		if word == "":
			continue
		var word_button = Button.new()
		word_button.text = word
		word_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		word_button.toggle_mode = true
		word_button.button_pressed = group_index == selected_group_index
		word_button.tooltip_text = "Show this word's synonyms"
		word_button.pressed.connect(_select_group.bind(group_index))
		list.add_child(word_button)

func _refresh_detail() -> void:
	for child in detail.get_children():
		child.queue_free()
	if selected_group_index < 0 || selected_group_index >= groups.size():
		var empty = Label.new()
		empty.text = "Select a word to edit its synonyms."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.add_child(empty)
		return
	var group = Array(groups[selected_group_index])
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	detail.add_child(header)

	var title = Label.new()
	title.text = "Synonyms For " + str(group[0])
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
	add_word.text = "+ Synonym"
	add_word.custom_minimum_size = Vector2(120, 32)
	add_word.pressed.connect(_on_add_word_pressed)
	detail.add_child(add_word)

func _add_word_row(word_index: int, word: String) -> void:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	detail.add_child(row)

	var input = LineEdit.new()
	input.text = word
	input.placeholder_text = "Word" if word_index == 0 else "Synonym or exact phrase"
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
	_clear_warning()
	if new_word_input != null:
		new_word_input.grab_focus()

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
	if word_index == 0:
		_refresh_list()
	_emit_changed()

func _emit_changed() -> void:
	var validation_message = _validate_groups()
	if validation_message != "":
		_show_warning(validation_message)
		return
	groups_changed.emit(get_synonym_groups())

func _on_submit_group_pressed() -> void:
	_submit_group_from_inputs()

func _submit_group_from_inputs() -> bool:
	var word = new_word_input.text.strip_edges() if new_word_input != null else ""
	var synonym_terms = _split_terms(new_synonyms_input.text if new_synonyms_input != null else "")
	if word == "":
		_show_warning("Write a word first.")
		return false
	if synonym_terms.is_empty():
		_show_warning("Add at least one synonym.")
		return false
	var clean_group = _clean_group([word] + synonym_terms)
	if clean_group.size() <= 1:
		_show_warning("Add at least one synonym.")
		return false
	var validation_message = _validate_candidate(clean_group)
	if validation_message != "":
		_show_warning(validation_message)
		return false
	groups.push_back(clean_group)
	selected_group_index = groups.size() - 1
	if new_word_input != null:
		new_word_input.text = ""
	if new_synonyms_input != null:
		new_synonyms_input.text = ""
	_clear_warning()
	_refresh()
	_emit_changed()
	return true

func _on_synonyms_submitted(_submitted_text: String) -> void:
	_on_submit_group_pressed()

func _clean_groups(source_groups: Array) -> Array:
	var cleaned := []
	for group in source_groups:
		var source_terms = _split_terms(group) if group is String else Array(group)
		var clean_group = _clean_group(source_terms)
		if clean_group.size() > 1:
			cleaned.push_back(clean_group)
	return cleaned

func _clean_group(source_terms: Array) -> Array:
	var clean_group := []
	var seen := {}
	for term in source_terms:
		var clean = str(term).strip_edges()
		var key = clean.to_lower()
		if clean != "" && !seen.has(key):
			clean_group.push_back(clean)
			seen[key] = true
	return clean_group

func _split_terms(text: String) -> Array:
	return Array(text.split(",", false)).map(func(term): return str(term).strip_edges())

func _validate_candidate(candidate_group: Array, ignored_group_index:= -1) -> String:
	var candidate_word = str(candidate_group[0]).strip_edges()
	var candidate_key = candidate_word.to_lower()
	for group_index in range(groups.size()):
		if group_index == ignored_group_index:
			continue
		var group = Array(groups[group_index])
		if group.is_empty():
			continue
		if str(group[0]).strip_edges().to_lower() == candidate_key:
			return "'" + candidate_word + "' already has synonyms."
		for synonym_index in range(1, group.size()):
			if str(group[synonym_index]).strip_edges().to_lower() == candidate_key:
				return "'" + candidate_word + "' is already a synonym for '" + str(group[0]) + "'."
	for candidate_term in candidate_group:
		var candidate_term_key = str(candidate_term).strip_edges().to_lower()
		for group_index in range(groups.size()):
			if group_index == ignored_group_index:
				continue
			for existing_term in Array(groups[group_index]):
				if str(existing_term).strip_edges().to_lower() == candidate_term_key:
					return "'" + str(candidate_term) + "' already belongs to another synonym group."
	return ""

func _validate_groups() -> String:
	for group_index in range(groups.size()):
		var clean_group = _clean_group(Array(groups[group_index]))
		if clean_group.size() <= 1:
			continue
		var validation_message = _validate_candidate(clean_group, group_index)
		if validation_message != "":
			return validation_message
	return ""

func _show_warning(message: String) -> void:
	if warning_label == null:
		return
	warning_generation += 1
	var current_warning_generation = warning_generation
	warning_label.text = message
	warning_label.visible = true
	warning_clear_timer = get_tree().create_timer(4.0)
	warning_clear_timer.timeout.connect(_clear_warning_if_current.bind(current_warning_generation))

func _clear_warning() -> void:
	warning_generation += 1
	if warning_label == null:
		return
	warning_label.text = ""
	warning_label.visible = false

func _clear_warning_if_current(clear_generation: int) -> void:
	if clear_generation == warning_generation:
		_clear_warning()
