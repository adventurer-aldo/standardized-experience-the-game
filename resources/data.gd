@tool
class_name Data
extends Resource

@export_category("Player")
@export var first_name:= ""
@export var last_name:= ""
@export var timezone: Timezone.Zone = Timezone.Zone.UTC
@export var birthday:= 0.0
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
@export var focus:= 0
@export var theme:= NORMAL

enum {NORMAL = 0, RED = 1, GREEN = 2, BLUE = 3}

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

func get_leveling_queues() -> Array[LevelingQueue]:
	var leveling_queues: Array[LevelingQueue]
	for filename in DirAccess.get_files_at("user://leveling_queues"):
		leveling_queues.push_back(ResourceLoader.load("user://leveling_queues/" + filename))
	return leveling_queues

func get_leveling_queues_due_at(time: float) -> Array[LevelingQueue]:
	var leveling_queues: Array[LevelingQueue]
	for filename in DirAccess.get_files_at("user://leveling_queues"):
		var res: LevelingQueue = ResourceLoader.load("user://leveling_queues/" + filename)
		if res.check(time):
			leveling_queues.push_back(res)
	return leveling_queues

func get_questions_with_leveling_due_at(time: float) -> Array[Question]:
	var res: Array[Question]
	for leveling_queue in get_leveling_queues_due_at(time):
		res.push_back(leveling_queue.get_question())
	return res

func get_subjects() -> Array[Subject]:
	var subjects: Array[Subject]
	for filename in DirAccess.get_files_at("user://subjects"):
		subjects.push_back(ResourceLoader.load("user://subjects/" + filename))
	return subjects

func get_subject(subject_id: int) -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, "0") + ".tres")

func get_quizzes() -> Array[Quiz]:
	var quizzes: Array[Quiz]
	for filename in DirAccess.get_files_at("user://quizzes"):
		quizzes.push_back(ResourceLoader.load("user://quizzes/" + filename))
	return quizzes

func get_quiz(quiz_id: int) -> Quiz:
	return ResourceLoader.load("user://quizzes/" + str(quiz_id).lpad(10, "0") + ".tres")

func get_last_quiz() -> Quiz:
	return ResourceLoader.load("user://quizzes/" + str(last_quiz_id).lpad(10, "0") + ".tres")

func get_soundtracks() -> Array[Soundtrack]:
	var soundtracks: Array[Soundtrack]
	var seen_keys := {}
	for dir_path in ["res://soundtracks", "user://soundtracks"]:
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
	for storage_path in ["res://soundtracks", "user://soundtracks"]:
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

func get_timezone_offset_seconds() -> int:
	return Timezone.get_offset_seconds(timezone)

func save() -> void:
	ResourceSaver.save(self, "user://data.tres", ResourceSaver.FLAG_COMPRESS)

func _soundtrack_key(soundtrack: Soundtrack) -> String:
	if soundtrack.id > 0:
		return "id:" + str(soundtrack.id)
	return "name:" + soundtrack.name.strip_edges().to_lower()
