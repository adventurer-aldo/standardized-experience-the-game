extends VBoxContainer

const FORMULA_ATTEMPT_ROW_SCRIPT := preload("res://scenes/quiz/formula_attempt_row.gd")

@export var attempt_row_scene: PackedScene
@export var id:= 0
@export var question_id:= 0
@export var question: Question
@export var edit_shortcut: PackedScene

signal add_to_might(value: int)

var gap_rows: Array = []
var active_formula_row: Node

func _on_add_row_button_pressed() -> HBoxContainer:
	var new_child = _make_attempt_row()
	_wire_row(new_child)
	$Elements/OpensRow.add_child(new_child)
	_configure_row_for_formula(new_child)
	new_child.call_deferred("get_focus")
	return new_child

func a_text_has_changed(difference: int) -> void:
	add_to_might.emit(difference)

func set_description(text: String) -> void:
	_set_number_label()
	_clear_gap_description()
	$ID/Description.show()
	$ID/Description.text = text

func _set_number_label() -> void:
	if question.is_ambush || question.is_rush:
		$ID/Number.text = "X. "
	else:
		$ID/Number.text = str(question.attempt_index + 1) + ". "

func prepare(with_question: Question):
	question = with_question
	question_id = with_question.id
	if !resized.is_connected(_resize_question_image):
		resized.connect(_resize_question_image)
	_populate_media()
	_resize_question_image.call_deferred()
	_prepare_description()
	if _is_formula_question():
		for child in $Elements/OpensRow.get_children():
			child.queue_free()
		for index in range(max(1, question.answer.size() - gap_rows.size())):
			var formula_row = _make_attempt_row()
			$Elements/OpensRow.add_child(formula_row)
	for child in $Elements/OpensRow.get_children():
		_wire_row(child)
		_configure_row_for_formula(child)
	_sync_open_rows_with_gaps()
	_update_order_numbers()

func fetch() -> Array:
	var result = []
	for child in _get_answer_input_rows():
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
	var wrong_attempts: Array = result["wrong_attempts"]
	var missing_answers: Array = result["missing_answers"]
	if !question.score_parts.is_empty():
		var used_corrections := []
		for part in question.score_parts:
			var attempt_i = int(part.get("attempt_index", -1))
			if attempt_i < 0:
				continue
			while attempt_i >= _get_answer_input_rows().size():
				_on_add_row_button_pressed()
			var row = _get_answer_input_rows()[attempt_i]
			if bool(part.get("correct", false)):
				row.tick()
			else:
				var correction = str(part.get("correction", ""))
				if correction != "":
					used_corrections.push_back(correction)
				row.cross_precise(correction, int(part.get("wrong_from", 0)))
		for answer_text in missing_answers:
			if used_corrections.has(str(answer_text)):
				used_corrections.erase(str(answer_text))
				continue
			var new_correction = _on_add_row_button_pressed()
			new_correction.cross(str(answer_text), false)
		$Edit.show()
		return result["correct"]
	var input_rows = _get_answer_input_rows()
	for attempt_i in range(attempts.size()):
		if wrong_attempts.has(attempts[attempt_i]):
			var correction = missing_answers.pop_front() if !missing_answers.is_empty() else ""
			input_rows[attempt_i].cross(correction)
		else:
			input_rows[attempt_i].tick()
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
	if gap_rows.size() > 0 && !$Elements.visible:
		return
	$Elements/AddRowButton.show()

func _on_attempt_text_unfocused() -> void:
	$Elements/AddRowButton.hide()

func _on_attempt_row_erase_if_empty_requested(row: Node) -> void:
	if row == null || row.fetch().strip_edges() != "":
		return
	if bool(row.get_meta("is_gap_row", false)):
		row.set_text("")
		return
	if $Elements/OpensRow.get_child_count() <= 1:
		row.set_text("")
		return
	row.queue_free()
	_update_order_numbers.call_deferred()

func _wire_row(row: Node) -> void:
	if row == null:
		return
	if !row.has_meta("open_attempt_focus_bound"):
		row.text_focused.connect(_on_attempt_text_focused_for_row.bind(row))
		row.set_meta("open_attempt_focus_bound", true)
	if row.has_meta("open_attempt_wired"):
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

func _on_attempt_text_focused_for_row(row: Node) -> void:
	active_formula_row = row
	_on_attempt_text_focused()

func _update_order_numbers() -> void:
	var input_rows = _get_answer_input_rows()
	for index in range(input_rows.size()):
		var row = input_rows[index]
		if question != null && question.is_order && row.has_method("show_order"):
			row.show_order(index + 1)
		elif row.has_method("hide_order"):
			row.hide_order()

func _prepare_description() -> void:
	var source_text = question.get_display_question_source()
	if question.has_gap_variables_in_text(source_text):
		_build_gap_description(source_text)
	else:
		set_description(question.get_display_question())

func _build_gap_description(source_text: String) -> void:
	_set_number_label()
	_clear_gap_description()
	$ID/Description.hide()
	gap_rows = []
	var flow = HFlowContainer.new()
	flow.name = "GapDescription"
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.alignment = FlowContainer.ALIGNMENT_BEGIN
	$ID.add_child(flow)
	var scan_index := 0
	while scan_index < source_text.length():
		var open_index = source_text.find(Question.VARIABLE_TOKEN_OPEN, scan_index)
		if open_index < 0:
			_add_gap_text_label(flow, question.resolve_variable_tokens(source_text.substr(scan_index), false))
			break
		_add_gap_text_label(flow, question.resolve_variable_tokens(source_text.substr(scan_index, open_index - scan_index), false))
		var close_index = source_text.find(Question.VARIABLE_TOKEN_CLOSE, open_index + Question.VARIABLE_TOKEN_OPEN.length())
		if close_index < 0:
			_add_gap_text_label(flow, question.resolve_variable_tokens(source_text.substr(open_index), false))
			break
		var token_payload = source_text.substr(open_index + Question.VARIABLE_TOKEN_OPEN.length(), close_index - open_index - Question.VARIABLE_TOKEN_OPEN.length())
		var variable_key = Question.variable_key_from_token_payload(token_payload)
		if question.get_variable_kind(variable_key) == Question.VARIABLE_KIND_GAP:
			var variable_spec = question.get_variable_spec(variable_key)
			var gap_row = _make_attempt_row()
			gap_row.set_meta("is_gap_row", true)
			gap_row.set_meta("answer_index", int(variable_spec.get("answer_index", gap_rows.size())))
			if gap_row.has_method("enable_compact_gap_mode"):
				gap_row.enable_compact_gap_mode()
			_wire_row(gap_row)
			_configure_row_for_formula(gap_row)
			flow.add_child(gap_row)
			gap_rows.push_back(gap_row)
		else:
			var token_text = source_text.substr(open_index, close_index - open_index + Question.VARIABLE_TOKEN_CLOSE.length())
			_add_gap_text_label(flow, question.resolve_variable_tokens(token_text, false))
		scan_index = close_index + Question.VARIABLE_TOKEN_CLOSE.length()

func _add_gap_text_label(flow: HFlowContainer, display_text: String) -> void:
	if display_text == "":
		return
	var text_label = Label.new()
	text_label.text = display_text
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	flow.add_child(text_label)

func _clear_gap_description() -> void:
	if has_node("ID/GapDescription"):
		$ID/GapDescription.free()
	gap_rows = []

func _sync_open_rows_with_gaps() -> void:
	var gap_count = gap_rows.size()
	if gap_count <= 0:
		$Elements.show()
		return
	var remaining_answer_count = max(0, question.answer.size() - gap_count)
	$Elements.visible = remaining_answer_count > 0
	if remaining_answer_count <= 0:
		return
	while $Elements/OpensRow.get_child_count() < remaining_answer_count:
		_on_add_row_button_pressed()
	while $Elements/OpensRow.get_child_count() > remaining_answer_count && $Elements/OpensRow.get_child_count() > 1:
		$Elements/OpensRow.get_child($Elements/OpensRow.get_child_count() - 1).queue_free()

func _get_answer_input_rows() -> Array:
	if gap_rows.is_empty():
		return $Elements/OpensRow.get_children() if $Elements.visible else []
	var normal_rows = $Elements/OpensRow.get_children() if $Elements.visible else []
	var ordered_rows := []
	var expected_count = max(question.answer.size(), gap_rows.size() + normal_rows.size())
	ordered_rows.resize(expected_count)
	var overflow_rows := []
	for gap_row in gap_rows:
		if !is_instance_valid(gap_row):
			continue
		var answer_index = int(gap_row.get_meta("answer_index", gap_rows.find(gap_row)))
		if answer_index >= 0 && answer_index < ordered_rows.size() && ordered_rows[answer_index] == null:
			ordered_rows[answer_index] = gap_row
		else:
			overflow_rows.push_back(gap_row)
	var normal_index := 0
	for ordered_index in range(ordered_rows.size()):
		if ordered_rows[ordered_index] != null:
			continue
		if normal_index < normal_rows.size():
			ordered_rows[ordered_index] = normal_rows[normal_index]
			normal_index += 1
	while normal_index < normal_rows.size():
		overflow_rows.push_back(normal_rows[normal_index])
		normal_index += 1
	var input_rows := []
	for ordered_row in ordered_rows:
		if ordered_row != null:
			input_rows.push_back(ordered_row)
	input_rows.append_array(overflow_rows)
	return input_rows

func _configure_row_for_formula(row: Node) -> void:
	if row == null || !_is_formula_question():
		return
	if !row.has_meta("formula_enabled"):
		row.set_meta("formula_enabled", true)

func _is_formula_question() -> bool:
	return question != null && (question.is_formula || question.attempt_type == "formula")

func _make_attempt_row() -> HBoxContainer:
	return FORMULA_ATTEMPT_ROW_SCRIPT.new() if _is_formula_question() else attempt_row_scene.instantiate()

func _populate_media() -> void:
	$Image.texture = null
	$Image.visible = false
	for child in $MediaExtras.get_children():
		child.queue_free()
	if question == null || !question.has_media():
		return
	var mediaset = question.get_mediaset()
	if mediaset == null:
		return
	if !mediaset.images.is_empty():
		$Image.texture = mediaset.images[0]
		_configure_image($Image, mediaset.images[0])
		$Image.visible = true
		_resize_question_image.call_deferred()
	for sound in mediaset.sounds:
		$MediaExtras.add_child(_make_sound_button(sound))
	for video in mediaset.videos:
		var player = VideoStreamPlayer.new()
		player.stream = video
		player.custom_minimum_size = Vector2(480, 270)
		player.expand = true
		$MediaExtras.add_child(player)
	$MediaExtras.visible = $MediaExtras.get_child_count() > 0

func _configure_image(rect: TextureRect, texture: Texture2D) -> void:
	var texture_size = texture.get_size()
	if texture_size.x <= 0.0:
		return
	var available_width = _available_image_width(rect, 720.0)
	var width = min(texture_size.x, available_width)
	var image_scale = width / texture_size.x
	rect.custom_minimum_size = Vector2(width, texture_size.y * image_scale)
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func _available_image_width(rect: TextureRect, maximum_width: float) -> float:
	var available_width = maximum_width
	var parent_node = rect.get_parent()
	while parent_node != null:
		if parent_node is Control && parent_node.size.x > 1.0:
			available_width = min(available_width, parent_node.size.x)
			break
		parent_node = parent_node.get_parent()
	if available_width <= 1.0:
		available_width = min(maximum_width, max(1.0, get_viewport_rect().size.x))
	return available_width

func _resize_question_image() -> void:
	if $Image.texture != null:
		_configure_image($Image, $Image.texture)

func _make_sound_button(stream: AudioStream) -> Button:
	var button = Button.new()
	button.text = "Play Sound"
	button.custom_minimum_size = Vector2(160, 34)
	var player = AudioStreamPlayer.new()
	player.stream = stream
	button.add_child(player)
	button.pressed.connect(player.play)
	return button
