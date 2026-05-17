@tool
class_name Question
extends Resource

const FORMULA_EDITOR_SCRIPT := preload("res://scenes/data/DataQuestion/formula_editor.gd")
const VARIABLE_TOKEN_OPEN := "\u2063"
const VARIABLE_TOKEN_CLOSE := "\u2064"
const VARIABLE_ID_MARKER := "\u2060"
const VARIABLE_ID_ZERO := "\u200B"
const VARIABLE_ID_ONE := "\u200C"
const FORMULA_TOKEN_OPEN := "\u2062"
const FORMULA_TOKEN_CLOSE := "\u2061"
const VARIABLE_KIND_NUMBER := "number"
const VARIABLE_KIND_WORD := "word"
const VARIABLE_KIND_GAP := "gap"

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
@export var is_formula:= false

@export_category('Question Add-Ons')
@export var is_order: bool = false
@export var is_strict: bool = false
@export var is_veracity: bool = false
@export var is_shuffle: bool = false
@export var shuffle_rows: bool = false
@export var shuffle_columns: bool = false
@export var uses_variables: bool = false

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
@export var formulated_variable_values := {}
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
	if is_table: types.push_back('table')
	if is_label: types.push_back('label')
	if is_connect: types.push_back('connect')
	if is_scheme: types.push_back('scheme')
	if is_formula: types.push_back('formula')
	return types

func get_attempt_types() -> Array:
	var types = get_types()
	if is_choice && is_veracity:
		types.erase("choice")
		types.push_back("veracity")
	return types

func get_parameters() -> Array:
	var parameters = []
	for parameter in get_allowed_parameters():
		match parameter:
			"strict":
				if is_strict: parameters.push_back(parameter)
			"shuffle":
				if is_shuffle: parameters.push_back(parameter)
			"shuffle_rows":
				if shuffle_rows: parameters.push_back(parameter)
			"shuffle_columns":
				if shuffle_columns: parameters.push_back(parameter)
			"variables":
				if uses_variables: parameters.push_back(parameter)
			"order":
				if is_order: parameters.push_back(parameter)
			"veracity":
				if is_veracity: parameters.push_back(parameter)
	return parameters

func get_allowed_parameters() -> Array:
	var parameters := []
	if is_open || is_label || is_choice || is_formula:
		parameters.push_back("order")
	if is_open || is_table || is_scheme || is_formula:
		parameters.push_back("strict")
	if is_choice:
		parameters.push_back("veracity")
	if is_connect || is_table:
		parameters.push_back("shuffle")
	if is_table:
		parameters.push_back("shuffle_rows")
		parameters.push_back("shuffle_columns")
	if !get_types().is_empty():
		parameters.push_back("variables")
	return parameters

func enforce_type_rules() -> void:
	var isolated_types = ["connect", "table", "scheme", "label", "formula"]
	var selected_isolated := ""
	for type_key in isolated_types:
		if _has_type(type_key):
			selected_isolated = type_key
	if selected_isolated != "":
		is_open = false
		is_choice = false
		is_connect = selected_isolated == "connect"
		is_table = selected_isolated == "table"
		is_scheme = selected_isolated == "scheme"
		is_label = selected_isolated == "label"
		is_formula = selected_isolated == "formula"
	elif !is_open && !is_choice:
		is_open = true
		is_formula = false
	else:
		is_formula = false
	if !get_allowed_parameters().has("order"):
		is_order = false
	if !get_allowed_parameters().has("strict"):
		is_strict = false
	if !get_allowed_parameters().has("veracity"):
		is_veracity = false
	if !get_allowed_parameters().has("shuffle"):
		is_shuffle = false
	if !get_allowed_parameters().has("shuffle_rows"):
		shuffle_rows = false
	if !get_allowed_parameters().has("shuffle_columns"):
		shuffle_columns = false
	if !get_allowed_parameters().has("variables"):
		uses_variables = false

func _has_type(type_key: String) -> bool:
	match type_key:
		"open":
			return is_open
		"choice":
			return is_choice
		"table":
			return is_table
		"label":
			return is_label
		"connect":
			return is_connect
		"scheme":
			return is_scheme
		"formula":
			return is_formula
	return false

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + ".tres")

func get_mediaset() -> Mediaset:
	if mediaset_id <= 0:
		return null
	return ResourceLoader.load("user://mediasets/" + str(mediaset_id).lpad(10, '0') + ".tres")

func gather_mediaset() -> Mediaset:
	return get_mediaset()

func get_or_create_mediaset() -> Mediaset:
	var existing = get_mediaset()
	if existing != null:
		return existing
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

func save_to_quiz(target_quiz_id: int, attempt_id:= id):
	self.quiz_id = target_quiz_id
	attempt_index = attempt_id
	if source_question_id <= 0:
		source_question_id = id
	var quiz_id_dir = str(target_quiz_id).lpad(10, '0') + '/'
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
			scheme_nodes = []
			scheme_links = []
		"table":
			answer = []
			choices = []
			match_a = {}
			match_b = {}
			labels = []
			scheme_nodes = []
			scheme_links = []
		"connect":
			answer = []
			choices = []
			columns = []
			labels = []
			scheme_nodes = []
			scheme_links = []
		"label":
			answer = []
			choices = []
			columns = []
			match_a = {}
			match_b = {}
			scheme_nodes = []
			scheme_links = []
		"scheme":
			answer = []
			choices = []
			columns = []
			match_a = {}
			match_b = {}
			labels = []
		"formula":
			choices = []
			columns = []
			match_a = {}
			match_b = {}
			labels = []
			scheme_nodes = []
			scheme_links = []
		_:
			choices = []
			columns = []
			match_a = {}
			match_b = {}
			labels = []
			scheme_nodes = []
			scheme_links = []

func generate_attempt(attempt_id:= 0, allowed_types:= []) -> void:
	randomize()
	attempt_index = attempt_id
	attempt = []
	formulated_variables = []
	formulated_variable_values = {}
	formulated_choices = []
	wrong_attempts = []
	missing_answers = []
	score_parts = []
	score_ratio = 0.0
	was_checked = false
	was_correct = false
	enforce_type_rules()
	var possible_types = get_attempt_types()
	if !allowed_types.is_empty():
		possible_types = possible_types.filter(func(type): return allowed_types.has(type))
	if possible_types.is_empty():
		possible_types = ["open"]
	possible_types.shuffle()
	attempt_type = possible_types[0]
	var possible_questions = Array(question).filter(func(question_text):
		return str(question_text).strip_edges() != ""
	)
	possible_questions.shuffle()
	formulated_question = possible_questions[0] if !possible_questions.is_empty() else ""
	_generate_variable_attempt()
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
	return resolve_variable_tokens(get_display_question_source(), false)

func get_display_question_source() -> String:
	if formulated_question.strip_edges() != "":
		return formulated_question
	return get_primary_question_text()

func get_primary_question_text() -> String:
	for question_text in question:
		var text = str(question_text).strip_edges()
		if text != "":
			return text
	var possible_questions = Array(question)
	return str(possible_questions[0]) if !possible_questions.is_empty() else ""

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
		"formula":
			weight = 1.6
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
	if uses_variables && !variables.is_empty():
		weight += 0.2
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

static func make_variable_token(variable_key, token_label:= "") -> String:
	var clean_label = str(token_label).strip_edges()
	if clean_label != "":
		clean_label = clean_label.replace(VARIABLE_TOKEN_OPEN, "").replace(VARIABLE_TOKEN_CLOSE, "")
		clean_label = clean_label.replace(VARIABLE_ID_MARKER, "").replace(VARIABLE_ID_ZERO, "").replace(VARIABLE_ID_ONE, "")
	else:
		clean_label = "v" + str(variable_key)
	var hidden_key = VARIABLE_ID_MARKER + _encode_hidden_variable_key(str(variable_key)) + VARIABLE_ID_MARKER
	var payload = hidden_key + clean_label
	return VARIABLE_TOKEN_OPEN + payload + VARIABLE_TOKEN_CLOSE

static func make_formula_token(element_key: String) -> String:
	return FORMULA_TOKEN_OPEN + element_key + FORMULA_TOKEN_CLOSE

func get_variable_spec(variable_key) -> Dictionary:
	var lookup_key = variable_key_from_token_payload(variable_key)
	for variable_entry in variables:
		if !(variable_entry is Dictionary):
			continue
		if str(variable_entry.get("id", "")) == lookup_key:
			return variable_entry
	return {}

static func variable_key_from_token_payload(token_payload) -> String:
	var payload_text = str(token_payload)
	if payload_text.begins_with(VARIABLE_ID_MARKER):
		var key_end = payload_text.find(VARIABLE_ID_MARKER, VARIABLE_ID_MARKER.length())
		if key_end >= 0:
			var encoded_key = payload_text.substr(VARIABLE_ID_MARKER.length(), key_end - VARIABLE_ID_MARKER.length())
			var decoded_key = _decode_hidden_variable_key(encoded_key)
			if decoded_key != "":
				return decoded_key
	var separator_index = payload_text.find(":")
	if separator_index >= 0:
		return payload_text.substr(0, separator_index)
	return payload_text

static func _encode_hidden_variable_key(variable_key: String) -> String:
	var encoded_key := ""
	for character_index in range(variable_key.length()):
		var codepoint = variable_key.unicode_at(character_index)
		for bit_index in range(15, -1, -1):
			encoded_key += VARIABLE_ID_ONE if ((codepoint >> bit_index) & 1) == 1 else VARIABLE_ID_ZERO
	return encoded_key

static func _decode_hidden_variable_key(encoded_key: String) -> String:
	var decoded_key := ""
	var character_width := 16
	for character_index in range(0, encoded_key.length(), character_width):
		if character_index + character_width > encoded_key.length():
			break
		var codepoint := 0
		for bit_index in range(character_width):
			var bit_value = encoded_key.substr(character_index + bit_index, 1)
			codepoint = (codepoint << 1) | (1 if bit_value == VARIABLE_ID_ONE else 0)
		if codepoint > 0:
			decoded_key += String.chr(codepoint)
	return decoded_key

func get_variable_display_name(variable_key) -> String:
	var variable_spec = get_variable_spec(variable_key)
	var label_text = str(variable_spec.get("label", "")).strip_edges()
	if label_text != "":
		return label_text
	return "v" + str(variable_key)

func get_variable_kind(variable_key) -> String:
	return str(get_variable_spec(variable_key).get("kind", VARIABLE_KIND_NUMBER))

func has_gap_variables_in_text(source_value: String) -> bool:
	return !get_gap_variable_tokens(source_value).is_empty()

func get_gap_variable_tokens(source_value: String) -> Array:
	var token_results := []
	for token_info in _get_variable_tokens(source_value):
		if get_variable_kind(token_info.get("variable_id", "")) == VARIABLE_KIND_GAP:
			token_results.push_back(token_info)
	return token_results

func resolve_variable_tokens(source_value, keep_gap_tokens:= false) -> String:
	var resolved_value := ""
	var raw_value = str(source_value)
	var scan_index := 0
	while scan_index < raw_value.length():
		var open_index = raw_value.find(VARIABLE_TOKEN_OPEN, scan_index)
		if open_index < 0:
			resolved_value += raw_value.substr(scan_index)
			break
		var close_index = raw_value.find(VARIABLE_TOKEN_CLOSE, open_index + VARIABLE_TOKEN_OPEN.length())
		if close_index < 0:
			resolved_value += raw_value.substr(scan_index)
			break
		resolved_value += raw_value.substr(scan_index, open_index - scan_index)
		var token_payload = raw_value.substr(open_index + VARIABLE_TOKEN_OPEN.length(), close_index - open_index - VARIABLE_TOKEN_OPEN.length())
		var variable_key = variable_key_from_token_payload(token_payload)
		var full_token = raw_value.substr(open_index, close_index - open_index + VARIABLE_TOKEN_CLOSE.length())
		if get_variable_kind(variable_key) == VARIABLE_KIND_GAP:
			resolved_value += full_token if keep_gap_tokens else "____"
		else:
			resolved_value += str(formulated_variable_values.get(str(variable_key), get_variable_display_name(variable_key)))
		scan_index = close_index + VARIABLE_TOKEN_CLOSE.length()
	return resolve_formula_tokens(resolved_value)

func resolve_formula_tokens(source_value) -> String:
	var resolved_value := ""
	var raw_value = str(source_value)
	var scan_index := 0
	while scan_index < raw_value.length():
		var open_index = raw_value.find(FORMULA_TOKEN_OPEN, scan_index)
		if open_index < 0:
			resolved_value += raw_value.substr(scan_index)
			break
		var close_index = raw_value.find(FORMULA_TOKEN_CLOSE, open_index + FORMULA_TOKEN_OPEN.length())
		if close_index < 0:
			resolved_value += raw_value.substr(scan_index)
			break
		resolved_value += raw_value.substr(scan_index, open_index - scan_index)
		var element_key = raw_value.substr(open_index + FORMULA_TOKEN_OPEN.length(), close_index - open_index - FORMULA_TOKEN_OPEN.length())
		resolved_value += _formula_display_text(element_key)
		scan_index = close_index + FORMULA_TOKEN_CLOSE.length()
	return resolved_value

func canonicalize_formula_tokens(source_value) -> String:
	if FORMULA_EDITOR_SCRIPT.is_formula_string(source_value):
		return FORMULA_EDITOR_SCRIPT.source_to_canonical(source_value)
	var canonical_value = str(source_value)
	for element_key in ["fraction", "log", "sin", "cos", "tan"]:
		canonical_value = canonical_value.replace(make_formula_token(element_key), _formula_display_text(element_key))
	return canonical_value

func _generate_variable_attempt() -> void:
	if variables.is_empty():
		_apply_variable_values_to_quiz_payload()
		return
	var consumed_answer_indexes := []
	for variable_entry in variables:
		if !(variable_entry is Dictionary):
			continue
		var variable_key = str(variable_entry.get("id", "")).strip_edges()
		if variable_key == "":
			continue
		var variable_kind = str(variable_entry.get("kind", VARIABLE_KIND_NUMBER))
		match variable_kind:
			VARIABLE_KIND_NUMBER:
				formulated_variable_values[variable_key] = str(_roll_number_variable(variable_entry))
			VARIABLE_KIND_WORD:
				var word_pick = _pick_word_variable_value(variable_entry, consumed_answer_indexes)
				formulated_variable_values[variable_key] = str(word_pick.get("value", ""))
				if word_pick.has("answer_index"):
					consumed_answer_indexes.push_back(int(word_pick["answer_index"]))
			VARIABLE_KIND_GAP:
				formulated_variable_values[variable_key] = ""
	consumed_answer_indexes.sort()
	consumed_answer_indexes.reverse()
	for answer_index in consumed_answer_indexes:
		if answer_index >= 0 && answer_index < answer.size():
			answer.remove_at(answer_index)
	_apply_variable_values_to_quiz_payload()

func _roll_number_variable(variable_spec: Dictionary) -> int:
	var minimum_value = int(variable_spec.get("minimum", variable_spec.get("min", 0)))
	var maximum_value = int(variable_spec.get("maximum", variable_spec.get("max", minimum_value)))
	if maximum_value < minimum_value:
		var swapped_value = minimum_value
		minimum_value = maximum_value
		maximum_value = swapped_value
	return randi_range(minimum_value, maximum_value)

func _pick_word_variable_value(variable_spec: Dictionary, consumed_answer_indexes: Array) -> Dictionary:
	var candidate_entries := []
	if bool(variable_spec.get("from_answers", false)):
		for answer_index in range(answer.size()):
			if consumed_answer_indexes.has(answer_index):
				continue
			var answer_entry = answer[answer_index]
			if !(answer_entry is Dictionary):
				continue
			var answer_texts = Array(answer_entry.get("texts", []))
			if answer_texts.is_empty():
				continue
			answer_texts.shuffle()
			candidate_entries.push_back({
				"value": str(answer_texts[0]),
				"answer_index": answer_index,
			})
	else:
		for word_text in _word_variable_candidates(variable_spec.get("words", [])):
			candidate_entries.push_back({"value": word_text})
	if candidate_entries.is_empty():
		return {"value": ""}
	candidate_entries.shuffle()
	var picked_entry = candidate_entries[0]
	if bool(variable_spec.get("consume_answer", false)) && picked_entry.has("answer_index"):
		return picked_entry
	return {"value": str(picked_entry.get("value", ""))}

func _word_variable_candidates(source_value) -> Array:
	var candidate_words := []
	var raw_candidates = Array(source_value) if source_value is Array else str(source_value).split("\n", false)
	for raw_candidate in raw_candidates:
		var comma_parts = str(raw_candidate).split(",", false)
		for comma_part in comma_parts:
			var word_text = str(comma_part).strip_edges()
			if word_text != "":
				candidate_words.push_back(word_text)
	return candidate_words

func _apply_variable_values_to_quiz_payload() -> void:
	answer = _resolve_tokens_in_value(answer)
	choices = _resolve_tokens_in_value(choices)
	columns = _resolve_tokens_in_value(columns)
	match_a = _resolve_tokens_in_value(match_a)
	match_b = _resolve_tokens_in_value(match_b)
	labels = _resolve_tokens_in_value(labels)
	scheme_nodes = _resolve_tokens_in_value(scheme_nodes)
	scheme_links = _resolve_tokens_in_value(scheme_links)

func _resolve_tokens_in_value(payload_value):
	if payload_value is String:
		if FORMULA_EDITOR_SCRIPT.is_formula_string(payload_value):
			return FORMULA_EDITOR_SCRIPT.serialize_formula_elements(_resolve_tokens_in_value(FORMULA_EDITOR_SCRIPT.parse_formula_elements(payload_value)))
		return resolve_variable_tokens(payload_value, false)
	if payload_value is PackedStringArray:
		var resolved_strings := PackedStringArray()
		for packed_value in payload_value:
			resolved_strings.push_back(resolve_variable_tokens(str(packed_value), false))
		return resolved_strings
	if payload_value is Array:
		var resolved_array := []
		for array_value in payload_value:
			resolved_array.push_back(_resolve_tokens_in_value(array_value))
		return resolved_array
	if payload_value is Dictionary:
		var resolved_dictionary := {}
		for dictionary_key in payload_value.keys():
			resolved_dictionary[dictionary_key] = _resolve_tokens_in_value(payload_value[dictionary_key])
		return resolved_dictionary
	return payload_value

func _get_variable_tokens(source_value: String) -> Array:
	var token_results := []
	var scan_index := 0
	while scan_index < source_value.length():
		var open_index = source_value.find(VARIABLE_TOKEN_OPEN, scan_index)
		if open_index < 0:
			break
		var close_index = source_value.find(VARIABLE_TOKEN_CLOSE, open_index + VARIABLE_TOKEN_OPEN.length())
		if close_index < 0:
			break
		var token_payload = source_value.substr(open_index + VARIABLE_TOKEN_OPEN.length(), close_index - open_index - VARIABLE_TOKEN_OPEN.length())
		var variable_key = variable_key_from_token_payload(token_payload)
		token_results.push_back({
			"variable_id": variable_key,
			"start": open_index,
			"end": close_index + VARIABLE_TOKEN_CLOSE.length(),
			"token": source_value.substr(open_index, close_index - open_index + VARIABLE_TOKEN_CLOSE.length()),
		})
		scan_index = close_index + VARIABLE_TOKEN_CLOSE.length()
	return token_results

func _formula_display_text(element_key: String) -> String:
	match element_key:
		"fraction":
			return "frac"
		"log":
			return "log"
		"sin":
			return "sin"
		"cos":
			return "cos"
		"tan":
			return "tan"
	return element_key

func _generate_choice_attempt() -> void:
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
	var a = match_a.duplicate(true)
	var b = match_b.duplicate(true)
	if is_shuffle:
		var keys = b.keys()
		var values = []
		for key in keys:
			values.push_back(b[key])
		values.shuffle()
		for index in range(keys.size()):
			b[keys[index]] = values[index]
	formulated_variables = [a, b]

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
	return score / max(1.0, correct_answers.size() + wrong_attempts.size())

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
	score_parts = []
	if is_order:
		var ordered_score = 0.0
		for answer_index in range(answers.size()):
			if answer_index < attempts.size() && answers[answer_index].has(attempts[answer_index]):
				ordered_score += 1.0
				score_parts.push_back({
					"attempt_index": answer_index,
					"attempt": raw_attempts[answer_index],
					"correct": true,
					"correction": _primary_answer_text(answer_index),
					"wrong_from": -1,
				})
			else:
				var correction = _primary_answer_text(answer_index)
				if answer_index < raw_attempts.size():
					wrong_attempts.push_back(raw_attempts[answer_index])
					score_parts.push_back(_make_open_score_part(answer_index, raw_attempts[answer_index], correction, false))
				if !answers[answer_index].is_empty():
					missing_answers.push_back(correction)
		for extra_attempt_index in range(answers.size(), raw_attempts.size()):
			wrong_attempts.push_back(raw_attempts[extra_attempt_index])
			score_parts.push_back(_make_open_score_part(extra_attempt_index, raw_attempts[extra_attempt_index], "", false))
		return ordered_score / max(1.0, answers.size())
	var unmatched_answers = answers.duplicate(true)
	var unmatched_answer_indexes = range(answers.size())
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
			var original_answer_index = unmatched_answer_indexes[matched_answer_index]
			unmatched_answer_indexes.remove_at(matched_answer_index)
			unmatched_attempt_indexes.erase(attempt_index)
			score_parts.push_back({
				"attempt_index": attempt_index,
				"answer_index": original_answer_index,
				"attempt": raw_attempts[attempt_index],
				"correct": true,
				"correction": _primary_answer_text(original_answer_index),
				"wrong_from": -1,
			})
	for unmatched_attempt_index in unmatched_attempt_indexes:
		wrong_attempts.push_back(raw_attempts[unmatched_attempt_index])
		var closest = _closest_answer_for_attempt(raw_attempts[unmatched_attempt_index], unmatched_answer_indexes)
		var correction = str(closest.get("text", ""))
		score_parts.push_back(_make_open_score_part(unmatched_attempt_index, raw_attempts[unmatched_attempt_index], correction, false))
	for answer_index in unmatched_answer_indexes:
		var correction = _primary_answer_text(answer_index)
		if correction != "":
			missing_answers.push_back(correction)
	var matched_count = max(0, answers.size() - missing_answers.size())
	return float(matched_count) / max(1.0, answers.size())

func _score_table_attempt(submitted_attempt: Array) -> float:
	var expected = _get_table_gaps()
	if expected.is_empty():
		return 1.0
	var expected_keys := {}
	for gap in expected:
		expected_keys[str(int(gap["column"])) + ":" + str(int(gap["row"]))] = true
	var score = 0.0
	for gap in expected:
		var submitted_text = _find_submitted_cell(submitted_attempt, int(gap["column"]), int(gap["row"]))
		if _normalized_array_has([gap["text"]], submitted_text):
			score += 1.0
		else:
			missing_answers.push_back(gap)
	for submitted_cell in submitted_attempt:
		if submitted_cell is Dictionary:
			var key = str(int(submitted_cell.get("column", -1))) + ":" + str(int(submitted_cell.get("row", -1)))
			if !expected_keys.has(key) && str(submitted_cell.get("text", "")).strip_edges() != "":
				wrong_attempts.push_back(submitted_cell)
	return score / max(1.0, expected.size() + wrong_attempts.size())

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
	var matched_label_indexes := []
	var score = 0.0
	for submitted_label in submitted_attempt:
		var matched_index = _find_label_match(submitted_label, matched_label_indexes)
		if matched_index >= 0:
			matched_label_indexes.push_back(matched_index)
			score += 1.0
		else:
			wrong_attempts.push_back(submitted_label)
	for label_index in range(labels.size()):
		if !matched_label_indexes.has(label_index):
			missing_answers.push_back(labels[label_index])
	return score / max(1.0, labels.size() + wrong_attempts.size())

func _score_scheme_attempt(submitted_attempt: Array) -> float:
	if scheme_links.is_empty():
		return 1.0
	var score = 0.0
	for expected_link in scheme_links:
		if _submitted_scheme_has_link(submitted_attempt, expected_link):
			score += 1.0
		else:
			missing_answers.push_back(expected_link)
	for submitted_link in submitted_attempt:
		if submitted_link is Dictionary && !_scheme_has_expected_link(submitted_link):
			wrong_attempts.push_back(submitted_link)
	return score / max(1.0, scheme_links.size() + wrong_attempts.size())

func _make_open_score_part(open_attempt_index: int, attempt_text, correction_text: String, correct: bool) -> Dictionary:
	var wrong_from = -1 if correct else _wrong_start_index(str(attempt_text), correction_text)
	return {
		"attempt_index": open_attempt_index,
		"attempt": attempt_text,
		"correct": correct,
		"correction": correction_text,
		"wrong_from": wrong_from,
	}

func _primary_answer_text(answer_index: int) -> String:
	if answer_index < 0 || answer_index >= answer.size():
		return ""
	var texts = Array(answer[answer_index].get("texts", []))
	return str(texts[0]) if !texts.is_empty() else ""

func _closest_answer_for_attempt(attempt_text, answer_indexes: Array) -> Dictionary:
	var best := {"text": "", "distance": 999999}
	for answer_index in answer_indexes:
		if answer_index < 0 || answer_index >= answer.size():
			continue
		for answer_text in answer[answer_index].get("texts", []):
			var distance = _levenshtein_distance(_normalize_string(str(attempt_text)), _normalize_string(str(answer_text)))
			if distance < int(best["distance"]):
				best = {"text": str(answer_text), "distance": distance}
	return best

func _wrong_start_index(attempt_text: String, correction_text: String) -> int:
	if correction_text == "":
		return 0
	var submitted_attempt = attempt_text.strip_edges()
	var correction = correction_text.strip_edges()
	var attempt_compare = submitted_attempt if is_strict else submitted_attempt.to_lower()
	var correction_compare = correction if is_strict else correction.to_lower()
	var limit = min(attempt_compare.length(), correction_compare.length())
	var wrong_index = limit
	for index in range(limit):
		if attempt_compare[index] != correction_compare[index]:
			wrong_index = index
			break
	if attempt_compare.length() != correction_compare.length() && wrong_index == limit:
		wrong_index = limit
	if !Engine.is_editor_hint() && Main.data.open_correction_whole_word:
		wrong_index = _word_start_for_index(submitted_attempt, wrong_index)
	return clampi(wrong_index, 0, submitted_attempt.length())

func _word_start_for_index(text: String, index: int) -> int:
	var start = clampi(index, 0, text.length())
	while start > 0:
		var character = text.substr(start - 1, 1)
		if character == " " || character == "\n" || character == "\t":
			break
		start -= 1
	return start

func _levenshtein_distance(left: String, right: String) -> int:
	var previous := []
	for right_index in range(right.length() + 1):
		previous.push_back(right_index)
	for left_index in range(left.length()):
		var current := [left_index + 1]
		for right_index in range(right.length()):
			var cost = 0 if left[left_index] == right[right_index] else 1
			current.push_back(min(min(previous[right_index + 1] + 1, current[right_index] + 1), previous[right_index] + cost))
		previous = current
	return previous[right.length()]

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
	var entries = []
	var answer_entries = Array(answer) if answer != null else []
	for answer_set in answer_entries:
		if answer_set is Dictionary:
			entries.push_back({
				"texts": Array(answer_set.get("texts", [])).duplicate(),
				"veracity": true,
				"media": answer_set.get("media", []),
			})
	var choice_entries = Array(choices) if choices != null else []
	for choice in choice_entries:
		if choice is Dictionary && !bool(choice.get("veracity", false)):
			entries.push_back(choice)
	return entries

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
	var table_columns = formulated_variables if !formulated_variables.is_empty() else columns
	for column_index in range(table_columns.size()):
		var column = Array(table_columns[column_index])
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

func _find_label_match(submitted_label, used_indexes: Array) -> int:
	if !(submitted_label is Dictionary):
		return -1
	for label_index in range(labels.size()):
		if used_indexes.has(label_index):
			continue
		var expected_label = labels[label_index]
		if !(expected_label is Dictionary):
			continue
		if !_label_text_matches(str(submitted_label.get("text", "")), expected_label):
			continue
		if submitted_label.has("position") && expected_label.has("area"):
			if !_label_area_contains_point(expected_label.get("area"), submitted_label.get("position")):
				continue
		return label_index
	return -1

func _label_text_matches(submitted_text: String, expected_label: Dictionary) -> bool:
	for expected_text in expected_label.get("texts", [expected_label.get("text", "")]):
		if _normalize_string(submitted_text) == _normalize_string(str(expected_text)):
			return true
	return false

func _label_area_contains_point(area, point_value) -> bool:
	if area == null || !(point_value is Vector2):
		return true
	if !is_instance_valid(area):
		return true
	var point: Vector2 = point_value
	for child in area.get_children():
		if child is CollisionShape2D && child.shape is ConvexPolygonShape2D:
			var polygon = child.shape.points
			if Geometry2D.is_point_in_polygon(point, polygon):
				return true
		elif child is Polygon2D:
			if Geometry2D.is_point_in_polygon(point, child.polygon):
				return true
	return false

func _submitted_scheme_has_link(submitted_attempt: Array, expected_link) -> bool:
	for submitted_link in submitted_attempt:
		if _scheme_links_match(submitted_link, expected_link):
			return true
	return false

func _scheme_has_expected_link(submitted_link) -> bool:
	for expected_link in scheme_links:
		if _scheme_links_match(submitted_link, expected_link):
			return true
	return false

func _scheme_links_match(submitted_link, expected_link) -> bool:
	if !(submitted_link is Dictionary) || !(expected_link is Dictionary):
		return false
	var same_from = str(submitted_link.get("from", "")) == str(expected_link.get("from", ""))
	var same_to = str(submitted_link.get("to", "")) == str(expected_link.get("to", ""))
	var same_label = _normalize_string(str(submitted_link.get("label", ""))) == _normalize_string(str(expected_link.get("label", "")))
	return same_from && same_to && same_label

func _normalized_array_has(values: Array, value: String) -> bool:
	var normalized_value = _normalize_string(value)
	for item in values:
		if _normalize_string(str(item)) == normalized_value:
			return true
	return false

func _get_primary_type() -> String:
	var types = get_attempt_types()
	return types[0] if !types.is_empty() else "open"

func _is_lenient() -> bool:
	if Engine.is_editor_hint():
		return true
	return Main.data.lenient

func _normalize_string(value: String) -> String:
	var prepared_value = FORMULA_EDITOR_SCRIPT.source_to_canonical(_resolve_tokens_in_value(value)) if FORMULA_EDITOR_SCRIPT.is_formula_string(value) else canonicalize_formula_tokens(resolve_variable_tokens(value, false))
	if Engine.is_editor_hint():
		var normalized = prepared_value.strip_edges()
		return normalized if is_strict else normalized.to_lower()
	return Main.data.normalize_answer_text(prepared_value, subject_id, is_strict)

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

func resolve_media_ref(ref: Dictionary):
	var mediaset = get_mediaset()
	if mediaset == null:
		return null
	return mediaset.get_media(ref)
