extends VBoxContainer

@export var id:= 0
@export var question_id:= 0
@export var question: Question
@export var edit_shortcut: PackedScene

signal add_to_might(value: int)

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
	
	var attempts = Array($Attempt.fetch())
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
		var matching_attempts = attempts_copy.map(func (attempt: String): 
			return answers_copy.map(func (answer: Array):
				return answer.has(attempt)
			).has(true)
		)
		var erasing_answer_index = -1
		
		var ma = matching_attempts.has(true)
		if ma:
			erasing_answer_index = answers_copy.map(func (answer: Array):
				return answer.has(attempts_copy[matching_attempts.find(true)])
			).find(true)
			answers_copy.remove_at(erasing_answer_index)
			attempts_copy.remove_at(matching_attempts.find(true))
	# The remaining answers don't have a match. Ergo, they were not written
	# The remaining attempts are not correct.
	
	# Posting solving debugging
	# print("#%s: %s" % [question_id, question.question[0]])
	# print(answers_copy)
	# print(attempts_copy)
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
				var debug = answers_copy.pop_at(0)
				wrong = debug[0]
			$Attempt.cross(attempts[attempt_i], wrong)
		else:
			var index = matches.find(true)
			answers.remove_at(index)
			$Attempt.tick(attempts[attempt_i])
			
	if answers_copy.size() > 0:
		res = false
		for ans in answers_copy:
			$Attempt.cross("", ans[0])
			# new_correction.cross(ans[0])
			
	# New attempt finished
	$Attempt/Text.hide()
	$Edit.show()
	if res:
		question.get_subject().get_question(question.id).hit()
		$Correction/Tick.show()
	else:
		question.get_subject().get_question(question.id).miss()
		$Correction/Cross.show()
	return res

func edit() -> void:
	var edit_scene = edit_shortcut.instantiate()
	edit_scene.subject_id = question.subject_id
	edit_scene.silence = true
	add_child(edit_scene)
	edit_scene.on_edit_pressed(question.id)
