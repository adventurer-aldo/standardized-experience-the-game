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
	new_child.get_focus()
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
	randomize()
	var questions = Array(with_question.question)
	questions.shuffle()
	set_description(questions[0])

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
	var res = false
	
	# New attempt
	res = true
	var is_strict = question.is_strict
	var is_order = question.is_order
	
	var attempts = fetch()
	var answers = question.answer.map(func (answers_dict: Dictionary): return answers_dict["texts"])
	# Do not care about case if not strict
	if !is_strict:
		attempts = attempts.map(func (attempt: String):
			return attempt.to_lower()
		)
		answers = answers.map(func (answers_array: Array):
			return answers_array.map(func (answer: String):
				return answer.to_lower()
			)
		)
	var attempts_copy = attempts.duplicate()
	var answers_copy = answers.duplicate()
	
	for answer_i in range(answers.size()):
		var matching_attempts = attempts_copy.map(func (attempt: String): return answers_copy[0].has(attempt))
		var ma = matching_attempts.has(true)
		if ma:
			answers_copy.remove_at(0)
			attempts_copy.remove_at(matching_attempts.find(true))
	# The remaining answers don't have a match. Ergo, they were not written
	# The remaining attempts are not correct.
	
	for attempt_i in range(attempts.size()):
		var matches = answers.map(func (answer: Array):
			return answer.has(attempts[attempt_i])
		)
		if !matches.has(true):
			res = false
			var wrong:= ""
			if answers_copy.size() > 0:
				# answers_copy_similarity_map = answers_copy
				answers_copy = answers_copy.map(func (answers_array: Array):
					answers_array.sort_custom(func (answer_a: String, answer_b: String):
						return answer_a.similarity(attempts[attempt_i]) > answer_b.similarity(attempts[attempt_i])
					)
					return answers_array
				)
				answers_copy.sort_custom(func (answers_array_a: Array, answers_array_b: Array):
					return answers_array_a[0].similarity(attempts[attempt_i]) > answers_array_b[0].similarity(attempts[attempt_i])
				)
				wrong = answers_copy[0][0]
				answers_copy.remove_at(0)
			$Elements/OpensRow.get_child(attempt_i).cross(wrong)
		else:
			var index = matches.find(true)
			answers.remove_at(index)
			$Elements/OpensRow.get_child(attempt_i).tick()
		if answers_copy.size() > 0:
			for ans in answers_copy:
				var new_correction = _on_add_row_button_pressed()
				new_correction.cross(ans[0], false)
			
	# New attempt finished
	$Edit.show()
	if res:
		# $Right.show()
		# $Wrong.hide()
		question.get_subject().get_question(question.id).hit()
	else:
		# replicate()
		# $Right.hide()
		# $Wrong.show()
		question.get_subject().get_question(question.id).miss()
	return res

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
