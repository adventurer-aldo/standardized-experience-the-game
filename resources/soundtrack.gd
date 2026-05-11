@tool
extends Resource
class_name Soundtrack

const USER_DIR := "user://soundtracks"
const RESOURCE_DIR := "res://saved_resources/soundtracks"

enum Storage { USER, RESOURCE }
enum QuizLevel {
	FIRST_TEST = 1,
	SECOND_TEST = 2,
	DISSERTATION = 3,
	REPOSITION_TEST = 4,
	EXAM = 5,
	RECURRENCE_EXAM = 6,
	EXTRAORDINARY = 7,
}
enum JourneyDiagnosis { PERFECT, EXEMPTED, PASSING, DANGER, FAILING, UNKNOWN }

@export_category("Identification")
@export var id := 0
@export var name := "New Soundtrack"

@export_category("General")
@export var main_menu: Array[AudioStream] = []
@export var freestyle: Array[AudioStream] = []
@export var subjects_writing: Array[AudioStream] = []

@export_category("Quiz")
@export var first_test: Array[AudioStream] = []
@export var second_test: Array[AudioStream] = []
@export var dissertation: Array[AudioStream] = []
@export var reposition_test: Array[AudioStream] = []
@export var exam: Array[AudioStream] = []
@export var recurrence_exam: Array[AudioStream] = []
@export var extraordinary: Array[AudioStream] = []

@export_category("Journey Stage")
@export var journey_first_test: Array[AudioStream] = []
@export var journey_second_test: Array[AudioStream] = []
@export var journey_dissertation: Array[AudioStream] = []
@export var journey_reposition_test: Array[AudioStream] = []
@export var journey_exam: Array[AudioStream] = []
@export var journey_recurrence_exam: Array[AudioStream] = []
@export var journey_extraordinary: Array[AudioStream] = []
@export var journey_finished: Array[AudioStream] = []

@export_category("Journey Diagnosis")
@export var diagnosis_perfect: Array[AudioStream] = []
@export var diagnosis_exempted: Array[AudioStream] = []
@export var diagnosis_passing: Array[AudioStream] = []
@export var diagnosis_danger: Array[AudioStream] = []
@export var diagnosis_failing: Array[AudioStream] = []
@export var diagnosis_unknown: Array[AudioStream] = []

@export_category("Quiz Grade Fanfares")
@export var fanfare_s: Array[AudioStream] = []
@export var fanfare_a: Array[AudioStream] = []
@export var fanfare_b: Array[AudioStream] = []
@export var fanfare_c: Array[AudioStream] = []
@export var fanfare_d: Array[AudioStream] = []
@export var fanfare_e: Array[AudioStream] = []
@export var fanfare_f: Array[AudioStream] = []
@export var fanfare_g: Array[AudioStream] = []


func get_storage_dir(storage := Storage.USER) -> String:
	return RESOURCE_DIR if storage == Storage.RESOURCE else USER_DIR


func get_file_name() -> String:
	if id > 0:
		return str(id).lpad(10, "0") + ".tres"
	return _safe_name(name) + ".tres"


func get_file_path(storage := Storage.USER) -> String:
	return get_storage_dir(storage) + "/" + get_file_name()


func create(storage := Storage.USER) -> void:
	if id <= 0 && storage == Storage.USER && !Engine.is_editor_hint():
		id = Main.data.next_soundtrack_id()
	save(storage)


func save(storage := Storage.USER) -> void:
	var dir_path = get_storage_dir(storage)
	if !DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	ResourceSaver.save(self, get_file_path(storage), ResourceSaver.FLAG_COMPRESS)


func erase(storage := Storage.USER) -> void:
	if FileAccess.file_exists(get_file_path(storage)):
		DirAccess.remove_absolute(get_file_path(storage))


func get_main_menu_track(use_might := false) -> AudioStream:
	return _select_variant(main_menu, use_might)


func get_freestyle_track(use_might := false) -> AudioStream:
	return _select_variant(freestyle, use_might)


func get_subjects_writing_track(use_might := false) -> AudioStream:
	return _select_variant(subjects_writing, use_might)


func get_quiz_track(level: int, use_might := false) -> AudioStream:
	match level:
		QuizLevel.FIRST_TEST:
			return _select_variant(first_test, use_might)
		QuizLevel.SECOND_TEST:
			return _select_variant(second_test, use_might)
		QuizLevel.DISSERTATION:
			return _select_variant(dissertation, use_might)
		QuizLevel.REPOSITION_TEST:
			return _select_variant(reposition_test, use_might)
		QuizLevel.EXAM:
			return _select_variant(exam, use_might)
		QuizLevel.RECURRENCE_EXAM:
			return _select_variant(recurrence_exam, use_might)
		QuizLevel.EXTRAORDINARY:
			return _select_variant(extraordinary, use_might)
	return null


func get_journey_stage_track(stage: int, use_might := false) -> AudioStream:
	match stage:
		QuizLevel.FIRST_TEST:
			return _select_variant(journey_first_test, use_might)
		QuizLevel.SECOND_TEST:
			return _select_variant(journey_second_test, use_might)
		QuizLevel.DISSERTATION:
			return _select_variant(journey_second_test, use_might)
		QuizLevel.REPOSITION_TEST:
			return _select_variant(journey_reposition_test, use_might)
		QuizLevel.EXAM:
			return _select_variant(journey_exam, use_might)
		QuizLevel.RECURRENCE_EXAM:
			return _select_variant(journey_recurrence_exam, use_might)
		QuizLevel.EXTRAORDINARY:
			return _select_variant(journey_extraordinary, use_might)
		7, 8:
			return _select_variant(journey_finished, use_might)
	return null


func get_journey_diagnosis_track(diagnosis: int) -> AudioStream:
	match diagnosis:
		JourneyDiagnosis.PERFECT:
			return _select(diagnosis_perfect)
		JourneyDiagnosis.EXEMPTED:
			return _select(diagnosis_exempted)
		JourneyDiagnosis.PASSING:
			return _select(diagnosis_passing)
		JourneyDiagnosis.DANGER:
			return _select(diagnosis_danger)
		JourneyDiagnosis.FAILING:
			return _select(diagnosis_failing)
	return _select(diagnosis_unknown)


func get_journey_diagnosis_from_grade(grade: float) -> int:
	if grade >= 19.9:
		return JourneyDiagnosis.PERFECT
	if grade >= 14.5:
		return JourneyDiagnosis.EXEMPTED
	if grade >= 9.5:
		return JourneyDiagnosis.PASSING
	if grade >= 8.0:
		return JourneyDiagnosis.DANGER
	if grade >= 0.0:
		return JourneyDiagnosis.FAILING
	return JourneyDiagnosis.UNKNOWN


func get_grade_fanfare(grade: float) -> AudioStream:
	return get_rank_fanfare(Main.rank_grade(grade) if !Engine.is_editor_hint() else _rank_grade(grade))


func get_rank_fanfare(rank: String) -> AudioStream:
	match rank.to_lower():
		"s":
			return _select(fanfare_s)
		"a":
			return _select(fanfare_a)
		"b":
			return _select(fanfare_b)
		"c":
			return _select(fanfare_c)
		"d":
			return _select(fanfare_d)
		"e":
			return _select(fanfare_e)
		"f":
			return _select(fanfare_f)
	return _select(fanfare_g)


func get_track(context: String, options := {}) -> AudioStream:
	var use_might = bool(options.get("might", false))
	match context.to_lower():
		"main_menu", "menu":
			return get_main_menu_track(use_might)
		"freestyle":
			return get_freestyle_track(use_might)
		"subjects", "subjects_writing", "writing":
			return get_subjects_writing_track(use_might)
		"quiz":
			return get_quiz_track(int(options.get("level", 0)), use_might)
		"journey", "journey_stage":
			return get_journey_stage_track(int(options.get("stage", 0)), use_might)
		"journey_diagnosis", "diagnosis":
			return get_journey_diagnosis_track(int(options.get("diagnosis", JourneyDiagnosis.UNKNOWN)))
		"grade", "fanfare":
			return get_grade_fanfare(float(options.get("grade", -1.0)))
	return null


func has_might_variant(context: String, options := {}) -> bool:
	return _get_context_tracks(context, options).size() > 1


func _select_variant(tracks: Array[AudioStream], use_might: bool) -> AudioStream:
	var available_tracks: Array[AudioStream] = []
	for track in tracks:
		if track != null:
			available_tracks.push_back(track)
	if available_tracks.is_empty():
		return null
	if use_might:
		if available_tracks.size() <= 1:
			return null
		return available_tracks[1 + (randi() % (available_tracks.size() - 1))]
	return available_tracks[0]


func _get_context_tracks(context: String, options := {}) -> Array[AudioStream]:
	match context.to_lower():
		"main_menu", "menu":
			return main_menu
		"freestyle":
			return freestyle
		"subjects", "subjects_writing", "writing":
			return subjects_writing
		"quiz":
			return _get_quiz_track_array(int(options.get("level", 0)))
		"journey", "journey_stage":
			return _get_journey_track_array(int(options.get("stage", 0)))
	return []


func _get_quiz_track_array(level: int) -> Array[AudioStream]:
	match level:
		QuizLevel.FIRST_TEST:
			return first_test
		QuizLevel.SECOND_TEST:
			return second_test
		QuizLevel.DISSERTATION:
			return dissertation
		QuizLevel.REPOSITION_TEST:
			return reposition_test
		QuizLevel.EXAM:
			return exam
		QuizLevel.RECURRENCE_EXAM:
			return recurrence_exam
		QuizLevel.EXTRAORDINARY:
			return extraordinary
	return []


func _get_journey_track_array(stage: int) -> Array[AudioStream]:
	match stage:
		QuizLevel.FIRST_TEST:
			return journey_first_test
		QuizLevel.SECOND_TEST, QuizLevel.DISSERTATION:
			return journey_second_test
		QuizLevel.REPOSITION_TEST:
			return journey_reposition_test
		QuizLevel.EXAM:
			return journey_exam
		QuizLevel.RECURRENCE_EXAM:
			return journey_recurrence_exam
		QuizLevel.EXTRAORDINARY:
			return journey_extraordinary
		7, 8:
			return journey_finished
	return []


func _select(tracks: Array[AudioStream]) -> AudioStream:
	var available_tracks: Array[AudioStream] = []
	for track in tracks:
		if track != null:
			available_tracks.push_back(track)
	if available_tracks.is_empty():
		return null
	return available_tracks[randi() % available_tracks.size()]


func _safe_name(value: String) -> String:
	var safe = value.strip_edges().to_snake_case()
	var invalid_chars = [" ", "/", "\\", ":", "*", "?", "\"", "<", ">", "|"]
	for invalid_char in invalid_chars:
		safe = safe.replace(invalid_char, "_")
	if safe.is_empty():
		return "soundtrack"
	return safe


func _rank_grade(grade: float) -> String:
	if grade >= 19.9:
		return "s"
	if grade >= 14.5:
		return "a"
	if grade >= 12.0:
		return "b"
	if grade >= 9.5:
		return "c"
	if grade >= 8.0:
		return "d"
	if grade >= 5.0:
		return "e"
	if grade >= 0.1:
		return "f"
	return "g"
