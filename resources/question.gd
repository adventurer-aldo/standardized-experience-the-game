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
@export var scheme_nodes: Array
@export var scheme_links: Array

@export var level: int = 1

@export_category('Question Types')
@export var is_open:= false
@export var is_choice:= false
@export var is_table:= false
@export var is_label:= false
@export var is_connect:= false
@export var is_scheme:= false

@export_category('Question Add-Ons')
@export var is_order: bool = false
@export var is_strict: bool = false
@export var is_gap: bool = false
@export var is_veracity: bool = false
@export var is_shuffle: bool = false
@export var shuffle_rows: bool = false
@export var shuffle_columns: bool = false

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
@export var quiz_id:= 0
@export var quiz_file_index:= -1
@export var source_question_id:= 0
@export var attempt_index:= 0
@export var formulated_variables := []
@export var formulated_question:= ""
@export var formulated_choices:= []
@export var attempt_type: String
@export var is_ambush:= false
@export var is_rush:= false
@export var was_checked:= false
@export var was_correct:= false
@export var wrong_attempts:= []
@export var missing_answers:= []
@export var score_ratio:= 0.0
@export var score_parts:= []

func get_types() -> Array:
	var types = []
	if is_open: types.push_back('open')
	if is_choice: types.push_back('choice')
	if is_veracity: types.push_back('veracity')
	if is_table: types.push_back('table')
	if is_label: types.push_back('label')
	if is_connect: types.push_back('connect')
	if is_scheme: types.push_back('scheme')
	return types

func get_parameters() -> Array:
	var parameters = []
	if is_strict: parameters.push_back('strict')
	if is_shuffle: parameters.push_back('shuffle')
	if shuffle_rows: parameters.push_back('shuffle_rows')
	if shuffle_columns: parameters.push_back('shuffle_columns')
	if is_order: parameters.push_back('order')
	if is_gap: parameters.push_back('gap')
	if is_veracity: parameters.push_back('veracity')
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

func get_quiz_file_path() -> String:
	if quiz_id <= 0 || quiz_file_index < 0:
		return ""
	return "user://quizzes/" + str(quiz_id).lpad(10, "0") + "/" + str(quiz_file_index).lpad(10, "0") + ".tres"

func create() -> void:
	id = get_subject().next_question_id(true)
	save()
	get_subject().register_question_added()

func erase() -> void:
	DirAccess.remove_absolute(get_file_path())
	get_subject().update_experience()

func save(update_edit_time:= true) -> void:
	if quiz_id > 0 && quiz_file_index >= 0:
		ResourceSaver.save(self, get_quiz_file_path(), ResourceSaver.FLAG_COMPRESS)
	else:
		if update_edit_time:
			last_time_edited = Time.get_unix_time_from_system()
		ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)
		if update_edit_time:
			var subject = get_subject()
			if subject != null:
				subject.last_time_saved = last_time_edited
				ResourceSaver.save(subject, subject.get_file_path(), ResourceSaver.FLAG_COMPRESS)

func save_to_quiz(quiz_id: int, attempt_id:= id):
	self.quiz_id = quiz_id
	attempt_index = attempt_id
	if source_question_id <= 0:
		source_question_id = id
	var quiz_id_dir = str(quiz_id).lpad(10, '0') + '/'
	if quiz_file_index < 0:
		quiz_file_index = DirAccess.get_files_at("user://quizzes/" + quiz_id_dir).size()
	save()

func make_quiz_attempt(attempt_id: int, allowed_types:= []) -> Question:
	appearances += 1
	save(false)
	var quiz_question = duplicate(true) as Question
	quiz_question.quiz_id = 0
	quiz_question.quiz_file_index = -1
	quiz_question.source_question_id = id
	quiz_question.generate_attempt(attempt_id, allowed_types)
	return quiz_question

func strip_for_quiz_attempt() -> void:
	parents = []
	experience = 0.0
	experience_level = 0
	is_level_up_queued = false
	appearances = 0
	hits = 0
	misses = 0
	hit_streak = 0
	miss_streak = 0
	last_time_leveled = 0.0
	match attempt_type:
		"choice", "veracity":
			columns = []
			match_a = {}
			match_b = {}
			labels = []
			variables = []
			scheme_nodes = []
			scheme_links = []
		"table":
			answer = []
			choices = []
			match_a = {}
			match_b = {}
			labels = []
			variables = []
			scheme_nodes = []
			scheme_links = []
		"connect":
			answer = []
			choices = []
			columns = []
			labels = []
			variables = []
			scheme_nodes = []
			scheme_links = []
		"label":
			answer = []
			choices = []
			columns = []
			match_a = {}
			match_b = {}
			variables = []
			scheme_nodes = []
			scheme_links = []
		"scheme":
			answer = []
			choices = []
			columns = []
			match_a = {}
			match_b = {}
			labels = []
			variables = []
		_:
			choices = []
			columns = []
			match_a = {}
			match_b = {}
			labels = []
			variables = []
			scheme_nodes = []
			scheme_links = []

func generate_attempt(attempt_id:= 0, allowed_types:= []) -> void:
	randomize()
	attempt_index = attempt_id
	attempt = []
	formulated_variables = []
	formulated_choices = []
	wrong_attempts = []
	missing_answers = []
	score_parts = []
	score_ratio = 0.0
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
		"table":
			_generate_table_attempt()
		"connect":
			_generate_match_attempt()
		"scheme":
			_generate_scheme_attempt()

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
	score_parts = []
	score_ratio = 0.0
	match attempt_type:
		"choice":
			score_ratio = _score_choice_attempt(submitted_attempt)
		"veracity":
			score_ratio = _score_veracity_attempt(submitted_attempt)
		"table":
			score_ratio = _score_table_attempt(submitted_attempt)
		"connect":
			score_ratio = _score_match_attempt(submitted_attempt)
		"label":
			score_ratio = _score_label_attempt(submitted_attempt)
		"scheme":
			score_ratio = _score_scheme_attempt(submitted_attempt)
		_:
			score_ratio = _score_open_attempt(submitted_attempt)
	was_correct = score_ratio >= 1.0
	save(false)
	var source_id = source_question_id if source_question_id > 0 else id
	var source_question = get_subject().get_question(source_id)
	if source_question != null:
		if was_correct:
			source_question.hit()
		else:
			source_question.miss()
	return {
		"correct": was_correct,
		"score_ratio": score_ratio,
		"wrong_attempts": wrong_attempts,
		"missing_answers": missing_answers,
	}

func get_grade_points(max_points: float, uses_negative_points:= false) -> float:
	var ratio = get_effective_score_ratio()
	if ratio > 0.0:
		return max_points * ratio
	if uses_negative_points:
		return -max_points
	return 0.0

func get_effective_score_ratio() -> float:
	if was_correct:
		return 1.0
	if _is_lenient():
		return clampf(score_ratio, 0.0, 1.0)
	return 0.0

func get_score_units() -> float:
	var unit_count = max(1, get_expected_answer_count())
	return max(1.0, get_difficulty_weight()) * unit_count

func get_expected_answer_count() -> int:
	match attempt_type if attempt_type != "" else _get_primary_type():
		"choice":
			return max(1, _get_correct_choice_count())
		"veracity":
			return max(1, _get_choice_entries().size())
		"table":
			return max(1, _get_table_gap_count())
		"connect":
			return max(1, match_a.size())
		"label":
			return max(1, labels.size())
		"scheme":
			return max(1, scheme_links.size())
	return max(1, answer.size())

func get_difficulty_weight() -> float:
	var weight := 1.0
	match attempt_type if attempt_type != "" else _get_primary_type():
		"choice":
			weight = 0.8
		"veracity":
			weight = 1.0
		"open":
			weight = 1.4
		"connect":
			weight = 1.5
		"label":
			weight = 1.7
		"table":
			weight = 2.0
		"scheme":
			weight = 2.1
	for answer_set in answer:
		for answer_text in answer_set.get("texts", []):
			if str(answer_text).length() > 32:
				weight += 0.15
			if str(answer_text).length() > 80:
				weight += 0.25
	if is_order:
		weight += 0.2
	if is_strict:
		weight += 0.15
	if is_gap:
		weight += 0.15
	return weight

func sync_choices_from_answers(include_decoys:= true) -> void:
	var existing_decoys = []
	if include_decoys:
		for choice in _get_choice_entries():
			if !bool(choice.get("veracity", false)):
				existing_decoys.push_back(choice)
	choices = []
	for answer_set in answer:
		choices.push_back({
			"texts": answer_set.get("texts", []).duplicate(),
			"veracity": true,
			"media": answer_set.get("media", []),
		})
	choices.append_array(existing_decoys)

func _generate_choice_attempt() -> void:
	if choices.is_empty():
		sync_choices_from_answers(false)
	for choice in _get_choice_entries():
		var shuffled_answers = Array(choice.get("texts", [])).duplicate()
		shuffled_answers.shuffle()
		if !shuffled_answers.is_empty():
			formulated_choices.push_back({
				"text": shuffled_answers[0],
				"veracity": bool(choice.get("veracity", false)),
				"media": choice.get("media", []),
			})
	formulated_choices.shuffle()

func _generate_veracity_attempt() -> void:
	_generate_choice_attempt()

func _generate_table_attempt() -> void:
	formulated_variables = columns.duplicate(true)
	if is_shuffle || shuffle_columns:
		formulated_variables.shuffle()
	if shuffle_rows && !formulated_variables.is_empty():
		var row_indexes = range(formulated_variables[0].size())
		row_indexes.shuffle()
		for column_index in range(formulated_variables.size()):
			var new_column = []
			for row_index in row_indexes:
				new_column.push_back(formulated_variables[column_index][row_index])
			formulated_variables[column_index] = new_column

func _generate_match_attempt() -> void:
	formulated_variables = [match_a.duplicate(true), match_b.duplicate(true)]

func _generate_scheme_attempt() -> void:
	formulated_variables = [scheme_nodes.duplicate(true), scheme_links.duplicate(true)]

func _score_choice_attempt(submitted_attempt: Array) -> float:
	var correct_answers = _get_correct_choice_texts()
	if submitted_attempt.is_empty():
		missing_answers = correct_answers
		return 0.0
	var submitted = submitted_attempt.map(func(item): return _normalize_string(str(item)))
	var score = 0.0
	for correct_answer in correct_answers:
		if submitted.has(_normalize_string(correct_answer)):
			score += 1.0
		else:
			missing_answers.push_back(correct_answer)
	for submitted_answer in submitted_attempt:
		if !_normalized_array_has(correct_answers, str(submitted_answer)):
			wrong_attempts.push_back(submitted_answer)
	return score / max(1.0, correct_answers.size())

func _score_veracity_attempt(submitted_attempt: Array) -> float:
	var expected = _get_choice_entries()
	if expected.is_empty():
		return _score_choice_attempt(submitted_attempt)
	var submitted_by_text := {}
	for item in submitted_attempt:
		if item is Dictionary:
			submitted_by_text[_normalize_string(str(item.get("text", "")))] = bool(item.get("veracity", false))
	var score = 0.0
	for choice in expected:
		var texts = Array(choice.get("texts", []))
		var primary_text = str(texts[0]) if !texts.is_empty() else ""
		var normalized = _normalize_string(primary_text)
		if submitted_by_text.has(normalized) && submitted_by_text[normalized] == bool(choice.get("veracity", false)):
			score += 1.0
		else:
			missing_answers.push_back({"text": primary_text, "veracity": bool(choice.get("veracity", false))})
	return score / max(1.0, expected.size())

func _score_open_attempt(submitted_attempt: Array) -> float:
	var raw_attempts = submitted_attempt.duplicate()
	var attempts = submitted_attempt.duplicate()
	var answers = answer.map(func(answers_dict: Dictionary): return answers_dict.get("texts", []))
	if !is_strict:
		attempts = attempts.map(func(attempt_text): return _normalize_string(str(attempt_text)))
		answers = answers.map(func(answers_array: Array):
			return answers_array.map(func(answer_text): return _normalize_string(str(answer_text)))
		)
	if is_order:
		var ordered_score = 0.0
		for answer_index in range(answers.size()):
			if answer_index < attempts.size() && answers[answer_index].has(attempts[answer_index]):
				ordered_score += 1.0
			else:
				if answer_index < raw_attempts.size():
					wrong_attempts.push_back(raw_attempts[answer_index])
				if !answers[answer_index].is_empty():
					missing_answers.push_back(answers[answer_index][0])
		for extra_attempt_index in range(answers.size(), raw_attempts.size()):
			wrong_attempts.push_back(raw_attempts[extra_attempt_index])
		return ordered_score / max(1.0, answers.size())
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
	var matched_count = max(0, answers.size() - missing_answers.size())
	return float(matched_count) / max(1.0, answers.size())

func _score_table_attempt(submitted_attempt: Array) -> float:
	var expected = _get_table_gaps()
	if expected.is_empty():
		return 1.0
	var score = 0.0
	for gap in expected:
		var submitted_text = _find_submitted_cell(submitted_attempt, int(gap["column"]), int(gap["row"]))
		if _normalized_array_has([gap["text"]], submitted_text):
			score += 1.0
		else:
			missing_answers.push_back(gap)
	return score / max(1.0, expected.size())

func _score_match_attempt(submitted_attempt: Array) -> float:
	if match_a.is_empty():
		return 1.0
	var submitted_pairs := {}
	for pair in submitted_attempt:
		if pair is Dictionary:
			submitted_pairs[str(pair.get("a", ""))] = str(pair.get("b", ""))
	var score = 0.0
	for key in match_a.keys():
		var expected_a = str(match_a[key])
		var expected_b = str(match_b.get(key, ""))
		if submitted_pairs.get(expected_a, "") == expected_b:
			score += 1.0
		else:
			missing_answers.push_back({"a": expected_a, "b": expected_b})
	return score / max(1.0, match_a.size())

func _score_label_attempt(submitted_attempt: Array) -> float:
	if labels.is_empty():
		return 1.0
	var score = 0.0
	for expected_label in labels:
		if _submitted_labels_has(submitted_attempt, expected_label):
			score += 1.0
		else:
			missing_answers.push_back(expected_label)
	return score / max(1.0, labels.size())

func _score_scheme_attempt(submitted_attempt: Array) -> float:
	if scheme_links.is_empty():
		return 1.0
	var score = 0.0
	for expected_link in scheme_links:
		if _submitted_scheme_has_link(submitted_attempt, expected_link):
			score += 1.0
		else:
			missing_answers.push_back(expected_link)
	return score / max(1.0, scheme_links.size())

func _get_all_answer_texts() -> Array:
	var texts = []
	for answer_set in answer:
		for answer_text in answer_set.get("texts", []):
			texts.push_back(str(answer_text))
	return texts

func _get_primary_answers() -> Array:
	var texts = []
	for answer_set in answer:
		var answer_texts = Array(answer_set.get("texts", []))
		if !answer_texts.is_empty():
			texts.push_back(str(answer_texts[0]))
	return texts

func _get_choice_entries() -> Array:
	if choices.is_empty():
		var entries = []
		for answer_set in answer:
			entries.push_back({
				"texts": answer_set.get("texts", []),
				"veracity": true,
				"media": answer_set.get("media", []),
			})
		return entries
	return choices

func _get_correct_choice_count() -> int:
	return _get_choice_entries().filter(func(choice): return bool(choice.get("veracity", false))).size()

func _get_correct_choice_texts() -> Array:
	var texts = []
	for choice in _get_choice_entries():
		if bool(choice.get("veracity", false)):
			var choice_texts = Array(choice.get("texts", []))
			if !choice_texts.is_empty():
				texts.push_back(str(choice_texts[0]))
	return texts

func _get_table_gap_count() -> int:
	return _get_table_gaps().size()

func _get_table_gaps() -> Array:
	var gaps = []
	for column_index in range(columns.size()):
		var column = Array(columns[column_index])
		for row_index in range(column.size()):
			var cell = column[row_index]
			if cell is Dictionary && bool(cell.get("is_open", false)):
				gaps.push_back({
					"column": column_index,
					"row": row_index,
					"text": str(cell.get("text", "")),
				})
	return gaps

func _find_submitted_cell(submitted_attempt: Array, column: int, row: int) -> String:
	for submitted_cell in submitted_attempt:
		if submitted_cell is Dictionary && int(submitted_cell.get("column", -1)) == column && int(submitted_cell.get("row", -1)) == row:
			return str(submitted_cell.get("text", ""))
	return ""

func _submitted_labels_has(submitted_attempt: Array, expected_label) -> bool:
	for submitted_label in submitted_attempt:
		if submitted_label is Dictionary && expected_label is Dictionary:
			var same_id = submitted_label.get("id", null) == expected_label.get("id", null)
			var same_text = _normalize_string(str(submitted_label.get("text", ""))) == _normalize_string(str(expected_label.get("text", "")))
			if same_id || same_text:
				return true
	return false

func _submitted_scheme_has_link(submitted_attempt: Array, expected_link) -> bool:
	for submitted_link in submitted_attempt:
		if submitted_link is Dictionary && expected_link is Dictionary:
			var same_from = str(submitted_link.get("from", "")) == str(expected_link.get("from", ""))
			var same_to = str(submitted_link.get("to", "")) == str(expected_link.get("to", ""))
			var same_label = str(submitted_link.get("label", "")) == str(expected_link.get("label", ""))
			if same_from && same_to && same_label:
				return true
	return false

func _normalized_array_has(values: Array, value: String) -> bool:
	var normalized_value = _normalize_string(value)
	for item in values:
		if _normalize_string(str(item)) == normalized_value:
			return true
	return false

func _get_primary_type() -> String:
	var types = get_types()
	return types[0] if !types.is_empty() else "open"

func _is_lenient() -> bool:
	if Engine.is_editor_hint():
		return true
	return Main.data.lenient

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
	save(false)
	var subj = get_subject()
	subj.update_experience()

func miss(is_in_journey:= false) -> void:
	misses += 1
	miss_streak += 1
	hit_streak = 0
	if ((!is_in_journey && miss_streak > 1) || is_in_journey) && !is_level_up_queued && experience_level > 1:
		miss_streak = 0
		experience_level = clampi(experience_level - 1, 1, 15)
	save(false)
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
