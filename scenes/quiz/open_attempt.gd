extends VBoxContainer

@export var attempt_row_scene: PackedScene
@export var id:= 0
@export var question_id:= 0
@export var question: Question
@export var edit_shortcut: PackedScene

signal add_to_might(value: int)

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
	_populate_media()
	set_description(question.get_display_question())
	for child in $Elements/OpensRow.get_children():
		_wire_row(child)
	_update_order_numbers()

func fetch() -> Array:
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
	var wrong_attempts: Array = result["wrong_attempts"]
	var missing_answers: Array = result["missing_answers"]
	if !question.score_parts.is_empty():
		var used_corrections := []
		for part in question.score_parts:
			var attempt_i = int(part.get("attempt_index", -1))
			if attempt_i < 0:
				continue
			while attempt_i >= $Elements/OpensRow.get_child_count():
				_on_add_row_button_pressed()
			var row = $Elements/OpensRow.get_child(attempt_i)
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
	var available_width = min(720.0, max(220.0, get_viewport_rect().size.x * 0.72))
	var width = min(texture_size.x, available_width)
	var scale = width / max(1.0, texture_size.x)
	rect.custom_minimum_size = Vector2(width, texture_size.y * scale)
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func _make_sound_button(stream: AudioStream) -> Button:
	var button = Button.new()
	button.text = "Play Sound"
	button.custom_minimum_size = Vector2(160, 34)
	var player = AudioStreamPlayer.new()
	player.stream = stream
	button.add_child(player)
	button.pressed.connect(player.play)
	return button
