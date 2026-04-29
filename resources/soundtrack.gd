@tool
extends Resource
class_name Soundtrack

const USER_DIR := "user://soundtracks"
const RESOURCE_DIR := "res://soundtracks"

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
@export var main_menu_might: Array[AudioStream] = []
@export var freestyle: Array[AudioStream] = []
@export var freestyle_might: Array[AudioStream] = []
@export var subjects_writing: Array[AudioStream] = []
@export var subjects_writing_might: Array[AudioStream] = []

@export_category("Quiz")
@export var first_test: Array[AudioStream] = []
@export var first_test_might: Array[AudioStream] = []
@export var second_test: Array[AudioStream] = []
@export var second_test_might: Array[AudioStream] = []
@export var dissertation: Array[AudioStream] = []
@export var dissertation_might: Array[AudioStream] = []
@export var reposition_test: Array[AudioStream] = []
@export var reposition_test_might: Array[AudioStream] = []
@export var exam: Array[AudioStream] = []
@export var exam_might: Array[AudioStream] = []
@export var recurrence_exam: Array[AudioStream] = []
@export var recurrence_exam_might: Array[AudioStream] = []
@export var extraordinary: Array[AudioStream] = []
@export var extraordinary_might: Array[AudioStream] = []

@export_category("Journey Stage")
@export var journey_first_test: Array[AudioStream] = []
@export var journey_first_test_might: Array[AudioStream] = []
@export var journey_second_test: Array[AudioStream] = []
@export var journey_second_test_might: Array[AudioStream] = []
@export var journey_dissertation: Array[AudioStream] = []
@export var journey_dissertation_might: Array[AudioStream] = []
@export var journey_reposition_test: Array[AudioStream] = []
@export var journey_reposition_test_might: Array[AudioStream] = []
@export var journey_exam: Array[AudioStream] = []
@export var journey_exam_might: Array[AudioStream] = []
@export var journey_recurrence_exam: Array[AudioStream] = []
@export var journey_recurrence_exam_might: Array[AudioStream] = []
@export var journey_extraordinary: Array[AudioStream] = []
@export var journey_extraordinary_might: Array[AudioStream] = []
@export var journey_finished: Array[AudioStream] = []
@export var journey_finished_might: Array[AudioStream] = []

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
	return _select_from_pair(main_menu, main_menu_might, use_might)


func get_freestyle_track(use_might := false) -> AudioStream:
	return _select_from_pair(freestyle, freestyle_might, use_might)


func get_subjects_writing_track(use_might := false) -> AudioStream:
	return _select_from_pair(subjects_writing, subjects_writing_might, use_might)


func get_quiz_track(level: int, use_might := false) -> AudioStream:
	match level:
		QuizLevel.FIRST_TEST:
			return _select_from_pair(first_test, first_test_might, use_might)
		QuizLevel.SECOND_TEST:
			return _select_from_pair(second_test, second_test_might, use_might)
		QuizLevel.DISSERTATION:
			return _select_from_pair(dissertation, dissertation_might, use_might)
		QuizLevel.REPOSITION_TEST:
			return _select_from_pair(reposition_test, reposition_test_might, use_might)
		QuizLevel.EXAM:
			return _select_from_pair(exam, exam_might, use_might)
		QuizLevel.RECURRENCE_EXAM:
			return _select_from_pair(recurrence_exam, recurrence_exam_might, use_might)
		QuizLevel.EXTRAORDINARY:
			return _select_from_pair(extraordinary, extraordinary_might, use_might)
	return null


func get_journey_stage_track(stage: int, use_might := false) -> AudioStream:
	match stage:
		QuizLevel.FIRST_TEST:
			return _select_from_pair(journey_first_test, journey_first_test_might, use_might)
		QuizLevel.SECOND_TEST:
			return _select_from_pair(journey_second_test, journey_second_test_might, use_might)
		QuizLevel.DISSERTATION:
			return _select_from_pair(journey_dissertation, journey_dissertation_might, use_might)
		QuizLevel.REPOSITION_TEST:
			return _select_from_pair(journey_reposition_test, journey_reposition_test_might, use_might)
		QuizLevel.EXAM:
			return _select_from_pair(journey_exam, journey_exam_might, use_might)
		QuizLevel.RECURRENCE_EXAM:
			return _select_from_pair(journey_recurrence_exam, journey_recurrence_exam_might, use_might)
		QuizLevel.EXTRAORDINARY:
			return _select_from_pair(journey_extraordinary, journey_extraordinary_might, use_might)
		8:
			return _select_from_pair(journey_finished, journey_finished_might, use_might)
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


func _select_from_pair(base_tracks: Array[AudioStream], might_tracks: Array[AudioStream], use_might: bool) -> AudioStream:
	if base_tracks.is_empty():
		return _select(might_tracks) if use_might else null
	var index = randi() % base_tracks.size()
	if use_might && index < might_tracks.size() && might_tracks[index] != null:
		return might_tracks[index]
	return base_tracks[index]


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
