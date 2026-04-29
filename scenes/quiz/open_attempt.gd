extends VBoxContainer

@export var attempt_row_scene: PackedScene
@export var id:= 0
@export var question_id:= 0
@export var question: Question
@export var edit_shortcut: PackedScene

signal add_to_might(value: int)

func _on_add_row_button_pressed() -> HBoxContainer:
	var new_child = attempt_row_scene.instantiate()
	new_child.text_focused.connect(_on_attempt_text_focused)
	new_child.text_unfocused.connect(_on_attempt_text_unfocused)
	$Elements/OpensRow.add_child(new_child)
	new_child.text_has_changed.connect(a_text_has_changed)
	new_child.call_deferred("get_focus")
	return new_child

func a_text_has_changed(difference: int) -> void:
	add_to_might.emit(difference)

func set_description(text: String) -> void:
	if question.is_rush:
		$ID/Number.text = "X. "
	else:
		$ID/Number.text = str(question.attempt_index + 1) + ". "
	$ID/Description.text = text

func prepare(with_question: Question):
	question = with_question
	question_id = with_question.id
	if question.has_media(): 
		$Image.texture = question.get_mediaset().images[0]
	set_description(question.get_display_question())

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
