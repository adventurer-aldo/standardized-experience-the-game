@tool
class_name Data
extends Resource

@export_category("Player")
@export var first_name:= ""
@export var last_name:= ""
@export var timezone: Timezone.Zone = Timezone.Zone.UTC
@export var birthday:= 0.0
@export var pfp_mediaset_id:= 0
@export_category("IDs")
@export var last_journey_id:= 0
@export var last_subject_id := 0
@export var last_question_id := 0
@export var last_quiz_id := 0
@export var last_leveling_queue_id:= 0
@export var last_mediaset_id:= 0
@export var last_soundtrack_id:= 0

@export var eligible_subject_ids:= []
@export_category("Settings")
@export var lenient:= true
@export var skip_dissertation:= true
@export var negative_points:= true
@export var use_24_hour_time:= true
@export var soundtrack_id:= 0
@export var prune_saved_quizzes:= true
@export var max_saved_quizzes:= 100
@export var focus:= 0
@export var theme:= NORMAL
@export var open_correction_whole_word:= false
@export var synonym_groups:= []

enum {NORMAL = 0, RED = 1, GREEN = 2, BLUE = 3}

func apply_first_run_defaults() -> void:
	timezone = Timezone.guess_zone_from_system()

func increment_last_journey_id() -> void:
	last_journey_id += 1
	save()

func increment_last_subject_id() -> void:
	last_subject_id += 1
	save()

func increment_last_question_id() -> void:
	last_question_id += 1
	save()
	
func increment_last_quiz_id() -> void:
	last_quiz_id += 1
	save()

func increment_last_leveling_queue_id() -> void:
	last_leveling_queue_id += 1
	save()

func increment_last_mediaset_id() -> void:
	last_mediaset_id += 1
	save()

func increment_last_soundtrack_id() -> void:
	last_soundtrack_id += 1
	save()

func next_mediaset_id(should_save:= true) -> int:
	var value_to_return = 0
	if should_save:
		last_mediaset_id += 1
		value_to_return = last_mediaset_id
		save()
	else:
		value_to_return = last_mediaset_id + 1
	return value_to_return

func next_soundtrack_id(should_save:= true) -> int:
	var value_to_return = 0
	if should_save:
		last_soundtrack_id += 1
		value_to_return = last_soundtrack_id
		save()
	else:
		value_to_return = last_soundtrack_id + 1
	return value_to_return

func next_journey_id(should_save:= true) -> int:
	var value_to_return = 0
	if should_save:
		last_journey_id += 1
		value_to_return = last_journey_id
		save()
	else:
		value_to_return = last_journey_id + 1
	return value_to_return

func next_subject_id(should_save:= true) -> int:
	var value_to_return = 0
	if should_save:
		last_subject_id += 1
		value_to_return = last_subject_id
		save()
	else:
		value_to_return = last_subject_id + 1
	return value_to_return

func next_question_id(should_save:= true) -> int:
	var value_to_return = 0
	if should_save:
		last_question_id += 1
		value_to_return = last_question_id
		save()
	else:
		value_to_return = last_question_id + 1
	return value_to_return

func next_quiz_id(should_save:= true) -> int:
	var value_to_return = 0
	if should_save:
		last_quiz_id += 1
		value_to_return = last_quiz_id
		save()
	else:
		value_to_return = last_quiz_id + 1
	return value_to_return

func next_leveling_queue_id(should_save:= true) -> int:
	var value_to_return = 0
	if should_save:
		last_leveling_queue_id += 1
		value_to_return = last_leveling_queue_id
		save()
	else:
		value_to_return = last_leveling_queue_id + 1
	return value_to_return

func get_journey(journey_id: int) -> Journey:
	return ResourceLoader.load("user://journeys/" + str(journey_id).lpad(10, "0") + ".tres")

func get_last_journey() -> Journey:
	return ResourceLoader.load("user://journeys/" + str(last_journey_id).lpad(10, "0") + ".tres")

func get_leveling_queues() -> Array:
	var leveling_queues: Array = []
	for filename in DirAccess.get_files_at("user://leveling_queues"):
		var loaded = ResourceLoader.load("user://leveling_queues/" + filename)
		if loaded != null:
			leveling_queues.push_back(loaded)
	return leveling_queues

func get_leveling_queues_due_at(time: float) -> Array:
	var leveling_queues: Array = []
	for filename in DirAccess.get_files_at("user://leveling_queues"):
		var res = ResourceLoader.load("user://leveling_queues/" + filename)
		if res != null && res.check(time):
			leveling_queues.push_back(res)
	return leveling_queues

func get_questions_with_leveling_due_at(time: float) -> Array:
	var res: Array = []
	for leveling_queue in get_leveling_queues_due_at(time):
		var question = leveling_queue.get_question()
		if question != null:
			res.push_back(question)
	return res

func get_subjects() -> Array:
	var subjects: Array = []
	for filename in DirAccess.get_files_at("user://subjects"):
		if !filename.ends_with(".tres"):
			continue
		var loaded = ResourceLoader.load("user://subjects/" + filename)
		if loaded != null:
			subjects.push_back(loaded)
	return subjects

func get_subject(subject_id: int) -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, "0") + ".tres")

func get_quizzes() -> Array:
	var quizzes: Array = []
	for filename in DirAccess.get_files_at("user://quizzes"):
		if !filename.ends_with(".tres"):
			continue
		var loaded = ResourceLoader.load("user://quizzes/" + filename)
		if loaded != null:
			quizzes.push_back(loaded)
	return quizzes

func get_quiz(quiz_id: int) -> Quiz:
	return ResourceLoader.load("user://quizzes/" + str(quiz_id).lpad(10, "0") + ".tres")

func get_last_quiz() -> Quiz:
	return ResourceLoader.load("user://quizzes/" + str(last_quiz_id).lpad(10, "0") + ".tres")

func prune_old_quizzes() -> void:
	if !prune_saved_quizzes || max_saved_quizzes <= 0:
		return
	var quizzes = get_quizzes()
	if quizzes.size() <= max_saved_quizzes:
		return
	quizzes.sort_custom(func(quiz_a: Quiz, quiz_b: Quiz):
		return quiz_a.start_time < quiz_b.start_time
	)
	while quizzes.size() > max_saved_quizzes:
		var quiz_to_delete = quizzes.pop_front()
		if quiz_to_delete != null:
			quiz_to_delete.delete()

func get_soundtracks() -> Array[Soundtrack]:
	var soundtracks: Array[Soundtrack]
	var seen_keys := {}
	for dir_path in ["res://saved_resources/soundtracks", "res://soundtracks", "user://soundtracks"]:
		if !DirAccess.dir_exists_absolute(dir_path):
			continue
		for filename in DirAccess.get_files_at(dir_path):
			if !filename.ends_with(".tres"):
				continue
			var soundtrack = ResourceLoader.load(dir_path + "/" + filename) as Soundtrack
			if soundtrack == null:
				continue
			var key = _soundtrack_key(soundtrack)
			if seen_keys.has(key):
				continue
			seen_keys[key] = true
			soundtracks.push_back(soundtrack)
	return soundtracks

func get_soundtrack(soundtrack_id: int) -> Soundtrack:
	for storage_path in ["res://saved_resources/soundtracks", "res://soundtracks", "user://soundtracks"]:
		var file_path = storage_path + "/" + str(soundtrack_id).lpad(10, "0") + ".tres"
		if FileAccess.file_exists(file_path):
			return ResourceLoader.load(file_path) as Soundtrack
	for soundtrack in get_soundtracks():
		if soundtrack.id == soundtrack_id:
			return soundtrack
	return null

func get_soundtrack_by_name(soundtrack_name: String) -> Soundtrack:
	var normalized_name = soundtrack_name.strip_edges().to_lower()
	for soundtrack in get_soundtracks():
		if soundtrack.name.strip_edges().to_lower() == normalized_name:
			return soundtrack
	return null

func get_current_soundtrack() -> Soundtrack:
	if soundtrack_id > 0:
		return get_soundtrack(soundtrack_id)
	var soundtracks = get_soundtracks()
	if soundtracks.is_empty():
		return null
	return soundtracks[0]

func get_default_soundtrack() -> Soundtrack:
	var soundtrack = get_soundtrack(1)
	if soundtrack != null:
		return soundtrack
	return get_soundtrack_by_name("Standardized Experience OST")

func get_timezone_offset_seconds() -> int:
	return Timezone.get_offset_seconds(timezone)

func get_pfp_mediaset() -> Mediaset:
	if pfp_mediaset_id <= 0:
		return null
	return ResourceLoader.load("user://mediasets/" + str(pfp_mediaset_id).lpad(10, "0") + ".tres")

func get_or_create_pfp_mediaset() -> Mediaset:
	var mediaset = get_pfp_mediaset()
	if mediaset != null:
		return mediaset
	mediaset = Mediaset.new()
	mediaset.create()
	pfp_mediaset_id = mediaset.id
	save()
	return mediaset

func get_text(key: String, fallback:= "") -> String:
	return fallback if fallback != "" else key

func translate(source_text: String) -> String:
	return source_text

func localize_tree(root: Node) -> void:
	return

func normalize_answer_text(value: String, subject_id:= 0, strict:= false) -> String:
	var normalized = value.strip_edges()
	var lookup = normalized.to_lower()
	var groups = get_effective_synonym_groups(subject_id)
	for group in groups:
		var canonical = ""
		for term in group:
			var clean_term = str(term).strip_edges()
			if clean_term == "":
				continue
			if canonical == "":
				canonical = clean_term
			if clean_term.to_lower() == lookup:
				return canonical if strict else canonical.to_lower()
	if strict:
		return normalized
	return lookup

func get_effective_synonym_groups(subject_id:= 0) -> Array:
	var subject_groups := []
	var subject = get_subject(subject_id) if subject_id > 0 else null
	if subject != null:
		subject_groups = _clean_synonym_groups(subject.synonym_groups)
	var global_groups = _clean_synonym_groups(synonym_groups)
	var subject_terms := {}
	for group in subject_groups:
		for term in group:
			subject_terms[str(term).to_lower()] = true
	var effective = subject_groups.duplicate(true)
	for group in global_groups:
		var overlaps_subject = false
		for term in group:
			if subject_terms.has(str(term).to_lower()):
				overlaps_subject = true
				break
		if !overlaps_subject:
			effective.push_back(group)
	return effective

func question_has_synonyms(question: Question) -> bool:
	if question == null:
		return false
	var lookup_terms := {}
	for group in get_effective_synonym_groups(question.subject_id):
		if group.size() <= 1:
			continue
		for term in group:
			lookup_terms[str(term).strip_edges().to_lower()] = true
	for answer_set in question.answer:
		if !(answer_set is Dictionary):
			continue
		for answer_text in answer_set.get("texts", []):
			var words = str(answer_text).split(" ", false)
			for word in words:
				if lookup_terms.has(_clean_synonym_lookup_word(word)):
					return true
			if lookup_terms.has(str(answer_text).strip_edges().to_lower()):
				return true
	for label in question.labels:
		if !(label is Dictionary):
			continue
		for label_text in label.get("texts", []):
			if lookup_terms.has(str(label_text).strip_edges().to_lower()):
				return true
	for column in question.columns:
		for cell in Array(column):
			if cell is Dictionary && lookup_terms.has(str(cell.get("text", "")).strip_edges().to_lower()):
				return true
	for node in question.scheme_nodes:
		if node is Dictionary:
			for node_text in node.get("texts", [node.get("text", "")]):
				if lookup_terms.has(str(node_text).strip_edges().to_lower()):
					return true
	return false

func save() -> void:
	ResourceSaver.save(self, "user://data.tres", ResourceSaver.FLAG_COMPRESS)

func _soundtrack_key(soundtrack: Soundtrack) -> String:
	if soundtrack.id > 0:
		return "id:" + str(soundtrack.id)
	return "name:" + soundtrack.name.strip_edges().to_lower()

func _clean_synonym_groups(groups: Array) -> Array:
	var cleaned := []
	for group in groups:
		var clean_group := []
		var terms = group.split(",", false) if group is String else Array(group)
		for term in terms:
			var clean_term = str(term).strip_edges()
			if clean_term != "" && !clean_group.has(clean_term):
				clean_group.push_back(clean_term)
		if clean_group.size() > 1:
			cleaned.push_back(clean_group)
	return cleaned

func _clean_synonym_lookup_word(value: String) -> String:
	var cleaned = value.strip_edges().to_lower()
	for character in [".", ",", ";", ":", "!", "?", "(", ")", "[", "]", "{", "}", "\"", "'"]:
		cleaned = cleaned.replace(character, "")
	return cleaned
