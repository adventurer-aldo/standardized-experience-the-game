@tool
class_name Question
extends Resource

@export_category('Identifiers')
@export var id: int
@export var subject_id: int
@export var created_at: int
@export var last_time_edited: int
@export var tags: Array

@export_category('Sensory Add-Ons')
@export var mediaset_id: int

@export_category('Data')
@export var question: PackedStringArray
@export var answer = [{"texts": [""]}]
@export var choices:= []
@export var columns: Array
@export var match_a: Dictionary
@export var match_b: Dictionary
@export var labels: Array
@export var variables: Array

@export var level: int = 1

@export_category('Question Types')
@export var is_open:= false
@export var is_choice:= false
@export var is_table:= false
@export var is_label:= false
@export var is_connect:= false

@export_category('Question Add-Ons')
@export var is_order: bool = false
@export var is_strict: bool = false
@export var is_gap: bool = false
@export var is_veracity: bool = false
@export var is_shuffle: bool = false

@export_category('Experience')
@export var parents: Array
@export var experience_level:= 1
@export var experience: float
@export var is_level_up_queued: bool
@export_group("Streaks")
@export var appearances: int
@export var hits: int
@export var misses: int
@export var hit_streak: int
@export var miss_streak: int
@export var last_time_leveled: float

@export_category("Quiz Answer")
@export var attempt := []
@export var attempt_index:= 0
@export var formulated_variables := []
@export var formulated_question:= ""
@export var formulated_choices:= []
@export var attempt_type: String
@export var is_rush:= false
@export var was_checked:= false
@export var was_correct:= false
@export var wrong_attempts:= []
@export var missing_answers:= []

func get_types() -> Array:
	var types = []
	if is_open: types.push_back('open')
	if is_choice: types.push_back('choice')
	if is_veracity: types.push_back('veracity')
	if is_table: types.push_back('table')
	if is_label: types.push_back('label')
	if is_connect: types.push_back('connect')
	return types

func get_parameters() -> Array:
	var parameters = []
	if is_strict: parameters.push_back('strict')
	if is_shuffle: parameters.push_back('shuffle')
	if is_order: parameters.push_back('order')
	return parameters

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + ".tres")

func get_mediaset() -> Mediaset:
	return ResourceLoader.load("user://mediasets/" + str(mediaset_id).lpad(10, '0') + ".tres")

func get_or_create_mediaset() -> Mediaset:
	if has_media():
		return get_mediaset()
	else:
		var media = Mediaset.new()
		media.create()
		mediaset_id = media.id
		return media

func get_file_path() -> String:
	var subject_id_dir = str(subject_id).lpad(10, '0') + '/'
	var id_filename = str(id).lpad(10, '0') + '.tres'
	return "user://subjects/" + subject_id_dir + id_filename

func create() -> void:
	id = get_subject().next_question_id(true)
	save()
	get_subject().register_question_added()

func erase() -> void:
	DirAccess.remove_absolute(get_file_path())
	get_subject().update_experience()

func save() -> void:
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)

func save_to_quiz(quiz_id: int, attempt_id:= id):
	attempt_index = attempt_id
	var quiz_id_dir = str(quiz_id).lpad(10, '0') + '/'
	var id_filename = str(DirAccess.get_files_at("user://quizzes/" + quiz_id_dir).size()).lpad(10, '0') + '.tres'
	ResourceSaver.save(self, "user://quizzes/" + quiz_id_dir + id_filename, ResourceSaver.FLAG_COMPRESS)

func make_quiz_attempt(attempt_id: int, allowed_types:= []) -> Question:
	appearances += 1
	save()
	var quiz_question = duplicate(true) as Question
	quiz_question.generate_attempt(attempt_id, allowed_types)
	return quiz_question

func generate_attempt(attempt_id:= 0, allowed_types:= []) -> void:
	randomize()
	attempt_index = attempt_id
	attempt = []
	formulated_variables = []
	formulated_choices = []
	wrong_attempts = []
	missing_answers = []
	was_checked = false
	was_correct = false
	var possible_types = get_types()
	if !allowed_types.is_empty():
		possible_types = possible_types.filter(func(type): return allowed_types.has(type))
	if possible_types.is_empty():
		possible_types = ["open"]
	possible_types.shuffle()
	attempt_type = possible_types[0]
	var possible_questions = Array(question)
	possible_questions.shuffle()
	formulated_question = possible_questions[0] if !possible_questions.is_empty() else ""
	match attempt_type:
		"choice":
			_generate_choice_attempt()
		"veracity":
			_generate_veracity_attempt()

func get_display_question() -> String:
	if formulated_question.strip_edges() != "":
		return formulated_question
	var possible_questions = Array(question)
	return possible_questions[0] if !possible_questions.is_empty() else ""

func check_attempt(submitted_attempt: Array) -> Dictionary:
	attempt = submitted_attempt.duplicate(true)
	was_checked = true
	wrong_attempts = []
	missing_answers = []
	match attempt_type:
		"choice", "veracity":
			was_correct = _check_choice_attempt(submitted_attempt)
		_:
			was_correct = _check_open_attempt(submitted_attempt)
	save()
	var source_question = get_subject().get_question(id)
	if was_correct:
		source_question.hit()
	else:
		source_question.miss()
	return {
		"correct": was_correct,
		"wrong_attempts": wrong_attempts,
		"missing_answers": missing_answers,
	}

func get_grade_points(max_points: float, uses_negative_points:= false) -> float:
	if was_correct:
		return max_points
	if uses_negative_points:
		return -max_points
	return 0.0

func _generate_choice_attempt() -> void:
	for answer_set in answer:
		var shuffled_answers: Array = answer_set.get("texts", []).duplicate()
		shuffled_answers.shuffle()
		if !shuffled_answers.is_empty():
			formulated_choices.push_back(shuffled_answers[0])
	var shuffled_choices: Array = choices.duplicate()
	shuffled_choices.shuffle()
	for choice in shuffled_choices:
		if !formulated_choices.has(choice):
			formulated_choices.push_back(choice)
	formulated_choices.shuffle()

func _generate_veracity_attempt() -> void:
	formulated_choices = ["True", "False"]

func _check_choice_attempt(submitted_attempt: Array) -> bool:
	if submitted_attempt.is_empty():
		missing_answers = _get_primary_answers()
		return false
	var normalized_attempt = _normalize_string(str(submitted_attempt[0]))
	for answer_text in _get_all_answer_texts():
		if _normalize_string(answer_text) == normalized_attempt:
			return true
	wrong_attempts = submitted_attempt.duplicate(true)
	missing_answers = _get_primary_answers()
	return false

func _check_open_attempt(submitted_attempt: Array) -> bool:
	var raw_attempts = submitted_attempt.duplicate()
	var attempts = submitted_attempt.duplicate()
	var answers = answer.map(func(answers_dict: Dictionary): return answers_dict.get("texts", []))
	if !is_strict:
		attempts = attempts.map(func(attempt_text): return _normalize_string(str(attempt_text)))
		answers = answers.map(func(answers_array: Array):
			return answers_array.map(func(answer_text): return _normalize_string(str(answer_text)))
		)
	var unmatched_answers = answers.duplicate(true)
	var unmatched_attempt_indexes = range(attempts.size())
	for attempt_index in range(attempts.size()):
		var attempt_text = attempts[attempt_index]
		var matched_answer_index = -1
		for answer_index in range(unmatched_answers.size()):
			if unmatched_answers[answer_index].has(attempt_text):
				matched_answer_index = answer_index
				break
		if matched_answer_index >= 0:
			unmatched_answers.remove_at(matched_answer_index)
			unmatched_attempt_indexes.erase(attempt_index)
	for unmatched_attempt_index in unmatched_attempt_indexes:
		wrong_attempts.push_back(raw_attempts[unmatched_attempt_index])
	for answers_array in unmatched_answers:
		if !answers_array.is_empty():
			missing_answers.push_back(answers_array[0])
	return wrong_attempts.is_empty() && missing_answers.is_empty()

func _get_all_answer_texts() -> Array:
	var texts = []
	for answer_set in answer:
		for answer_text in answer_set.get("texts", []):
			texts.push_back(str(answer_text))
	return texts

func _get_primary_answers() -> Array:
	var texts = []
	for answer_set in answer:
		var answer_texts: Array = answer_set.get("texts", [])
		if !answer_texts.is_empty():
			texts.push_back(str(answer_texts[0]))
	return texts

func _normalize_string(value: String) -> String:
	var normalized = value.strip_edges()
	if !is_strict:
		normalized = normalized.to_lower()
	return normalized

# ==============================================================================
# LEVELING
# ==============================================================================
func hit(is_in_journey:= false) -> void:
	hits += 1
	hit_streak += 1
	if ((!is_in_journey && hit_streak > 1) || is_in_journey || experience_level > 4 && miss_streak < 1) && !is_level_up_queued:
		var next_level = experience_level + 1
		hit_streak = 0
		experience_level = clampi(next_level, 1, 15)
		queue_level_up(next_level)
	miss_streak = 0
	save()
	var subj = get_subject()
	subj.update_experience()

func miss(is_in_journey:= false) -> void:
	misses += 1
	miss_streak += 1
	hit_streak = 0
	if ((!is_in_journey && miss_streak > 1) || is_in_journey) && !is_level_up_queued && experience_level > 1:
		miss_streak = 0
		experience_level = clampi(experience_level - 1, 1, 15)
	save()
	var subj = get_subject()
	subj.update_experience()

func queue_level_up(to_level: int) -> void:
	is_level_up_queued = true
	var due_time:= 0.0
	match to_level:
		2: due_time = 15 * 60
		3: due_time = 1 * 60 * 60
		4: due_time = 8 * 60 * 60
		5: due_time = 24 * 60 * 60
		6: due_time = 3 * 24 * 60 * 60
		7: due_time = 6 * 24 * 60 * 60
		8: due_time = 12 * 24 * 60 * 60
		9: due_time = 19 * 24 * 60 * 60
		10: due_time = 31 * 24 * 60 * 60
		11: due_time = 62 * 24 * 60 * 60
		12: due_time = 124 * 24 * 60 * 60
		13: due_time = 248 * 24 * 60 * 60
		14: due_time = 365 * 24 * 60 * 60

	var level_queue = LevelingQueue.new()
	level_queue.id = Main.data.next_leveling_queue_id()
	level_queue.subject_id = subject_id
	level_queue.question_id = id
	level_queue.due_time = due_time + Time.get_unix_time_from_system()
	level_queue.save()

func finish_level_up() -> void:
	var leveling_queues: Array[LevelingQueue] = Main.data.get_leveling_queues()
	leveling_queues = leveling_queues.filter(func (queue: LevelingQueue):
		return queue.question_id == id
	)
	for leveling_queue in leveling_queues:
		leveling_queue.process_leveling(9999999999.9)
# ==============================================================================
# OTHERS
# ==============================================================================
func are_parents_decent() -> bool:
	var subject = get_subject()
	var verdicts:= parents.map(func (parent_id):
		var parent = subject.get_question(parent_id)
		return parent.experience_level > 3 || parent.is_level_up_queued
	)
	return !verdicts.has(false)

func has_media() -> bool:
	return ![0, null].has(mediaset_id)
