extends "res://scenes/quiz/attempt_base.gd"

var veracity_mode:= false

func _build_attempt_controls() -> void:
	veracity_mode = question != null && question.attempt_type == "veracity"
	for choice in question.formulated_choices:
		var text = str(choice.get("text", ""))
		var option = VBoxContainer.new()
		option.name = "ChoiceOption"
		option.add_theme_constant_override("separation", 4)
		body.add_child(option)
		option.add_child(_make_media_strip(Array(choice.get("media", []))))
		if veracity_mode:
			var row = HBoxContainer.new()
			row.name = "VeracityRow"
			row.add_theme_constant_override("separation", 10)
			option.add_child(row)
			row.add_child(_make_option_label(text))
			var toggle = CheckButton.new()
			toggle.name = "VeracityChoice"
			toggle.text = "True"
			toggle.set_meta("choice_text", text)
			row.add_child(toggle)
		else:
			var check = CheckBox.new()
			check.name = "Choice"
			check.text = text
			check.set_meta("choice_text", text)
			check.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			option.add_child(check)

func fetch() -> Array:
	if veracity_mode:
		var veracity = []
		for row in body.find_children("VeracityRow", "HBoxContainer", true, false):
			var toggle = row.get_node_or_null("VeracityChoice")
			if toggle != null:
				veracity.push_back({"text": str(toggle.get_meta("choice_text")), "veracity": toggle.button_pressed})
		return veracity
	var selected = []
	for child in body.find_children("Choice", "CheckBox", true, false):
		if child is CheckBox && child.button_pressed:
			selected.push_back(str(child.get_meta("choice_text", child.text)))
	return selected

func _show_checked_result(result: Dictionary) -> void:
	super._show_checked_result(result)
	var wrong_attempts = result.get("wrong_attempts", [])
	var missing_answers = result.get("missing_answers", [])
	for child in body.find_children("*", "Control", true, false):
		if child is CheckBox:
			child.disabled = true
			var choice_text = str(child.get_meta("choice_text", child.text))
			if wrong_attempts.has(choice_text):
				child.add_theme_color_override("font_color", Color(0.72, 0.05, 0.07))
			elif child.button_pressed:
				child.add_theme_color_override("font_color", Color(0.05, 0.42, 0.12))
		elif child is HBoxContainer:
			var toggle = child.get_node_or_null("VeracityChoice")
			if toggle != null:
				toggle.disabled = true
	if !missing_answers.is_empty():
		var missing = Label.new()
		missing.text = "Missing: " + ", ".join(missing_answers.map(func(item): return str(item)))
		missing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		missing.add_theme_color_override("font_color", Color(0.72, 0.05, 0.07))
		body.add_child(missing)
