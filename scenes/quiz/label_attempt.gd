extends "res://scenes/quiz/attempt_base.gd"

var marker_layer: Control
var label_attempt_count:= 0

func _build_attempt_controls() -> void:
	image_rect.visible = true
	if image_rect.texture == null:
		image_rect.custom_minimum_size = Vector2(0, 260)
	image_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	if !image_rect.gui_input.is_connected(_on_image_gui_input):
		image_rect.gui_input.connect(_on_image_gui_input)
	_prepare_marker_layer()

	var prompt = Label.new()
	prompt.text = "Click the image to place a label."
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(prompt)

	var add = Button.new()
	add.text = "Add Label Without Image Point"
	add.pressed.connect(_add_label_attempt_at.bind(Vector2.ZERO))
	body.add_child(add)

func fetch() -> Array:
	var attempts := []
	for child in body.get_children():
		if child is HBoxContainer && child.name == "LabelAttemptRow":
			var input = child.get_node_or_null("LabelAttempt")
			if input != null:
				attempts.push_back({"text": input.text, "position": child.get_meta("position", Vector2.ZERO)})
	return attempts

func _show_checked_result(result: Dictionary) -> void:
	super._show_checked_result(result)
	var wrong_attempts = result.get("wrong_attempts", [])
	for child in body.get_children():
		if child is HBoxContainer && child.name == "LabelAttemptRow":
			var input = child.get_node_or_null("LabelAttempt")
			if input == null:
				continue
			input.editable = false
			var is_wrong = wrong_attempts.any(func(item):
				return item is Dictionary && str(item.get("text", "")) == input.text
			)
			input.add_theme_color_override("font_color", Color(0.72, 0.05, 0.07) if is_wrong else Color(0.05, 0.42, 0.12))

func _on_image_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		_add_label_attempt_at(image_rect.get_local_mouse_position())

func _add_label_attempt_at(label_position: Vector2) -> void:
	label_attempt_count += 1
	var row = HBoxContainer.new()
	row.name = "LabelAttemptRow"
	row.add_theme_constant_override("separation", 8)
	row.set_meta("position", label_position)
	body.add_child(row)

	var number = Label.new()
	number.name = "Number"
	number.text = str(label_attempt_count)
	number.custom_minimum_size = Vector2(28, 28)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(number)

	var input = LineEdit.new()
	input.name = "LabelAttempt"
	input.placeholder_text = "Label"
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(input)

	var delete = Button.new()
	delete.text = "-"
	delete.pressed.connect(_delete_label_attempt.bind(row))
	row.add_child(delete)

	_add_marker(label_position, label_attempt_count, row)
	input.grab_focus()

func _prepare_marker_layer() -> void:
	if marker_layer != null && is_instance_valid(marker_layer):
		for child in marker_layer.get_children():
			child.queue_free()
		return
	marker_layer = Control.new()
	marker_layer.name = "AttemptMarkers"
	marker_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	image_rect.add_child(marker_layer)

func _add_marker(label_position: Vector2, number: int, row: HBoxContainer) -> void:
	if label_position == Vector2.ZERO:
		return
	_prepare_marker_layer()
	var marker = Label.new()
	marker.text = str(number)
	marker.custom_minimum_size = Vector2(26, 26)
	marker.size = Vector2(26, 26)
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker.position = label_position - marker.size * 0.5
	marker.add_theme_color_override("font_color", Color(0.03, 0.06, 0.08))
	marker_layer.add_child(marker)
	row.set_meta("marker", marker)

func _delete_label_attempt(row: HBoxContainer) -> void:
	if row.has_meta("marker"):
		var marker = row.get_meta("marker")
		if is_instance_valid(marker):
			marker.queue_free()
	row.queue_free()
	_renumber_label_attempts.call_deferred()

func _renumber_label_attempts() -> void:
	var index := 1
	for child in body.get_children():
		if child is HBoxContainer && child.name == "LabelAttemptRow":
			child.get_node("Number").text = str(index)
			if child.has_meta("marker"):
				var marker = child.get_meta("marker")
				if is_instance_valid(marker):
					marker.text = str(index)
			index += 1
	label_attempt_count = index - 1
