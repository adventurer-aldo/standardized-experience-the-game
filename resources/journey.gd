@tool
extends Resource
class_name Journey

enum Diagnosis { NONE, TERRIBLE, MEH, ALRIGHT, GREAT, AWESOME }

@export var id: int
@export var start_time: float
@export var end_time: float
@export var stage:= 1
@export var diagnosis:= Diagnosis.NONE


func create() -> void:
	if id <= 0 && !Engine.is_editor_hint():
		id = Main.data.next_journey_id()
	DirAccess.make_dir_recursive_absolute(get_dir_path())
	start_time = Time.get_unix_time_from_system()
	for subject in Main.data.get_subjects():
		if subject.is_journey_eligible:
			var new_chair = Chair.new()
			new_chair.journey_id = id
			new_chair.subject_id = subject.id
			new_chair.id = subject.id
			new_chair.save()
	update_diagnosis()
	save()


func save() -> void:
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)


func finish() -> void:
	end_time = Time.get_unix_time_from_system()
	stage = 8
	update_diagnosis()
	save()


func get_dir_path() -> String:
	return "user://journeys/" + str(id).lpad(10, "0") + "/"


func get_file_path() -> String:
	return "user://journeys/" + str(id).lpad(10, "0") + ".tres"


func get_chairs() -> Array[Chair]:
	var ret: Array[Chair]
	if !DirAccess.dir_exists_absolute(get_dir_path()):
		return ret
	for chair_filename in DirAccess.get_files_at(get_dir_path()):
		var chair = ResourceLoader.load(get_dir_path() + chair_filename) as Chair
		if chair != null:
			ret.push_back(chair)
	return ret


func get_chair(subject_id: int) -> Chair:
	var file_path = get_dir_path() + str(subject_id).lpad(10, "0") + ".tres"
	if FileAccess.file_exists(file_path):
		return ResourceLoader.load(file_path) as Chair
	return null


func record_quiz_grade(quiz: Quiz, grade_slot: int) -> void:
	var chair = get_chair(quiz.subject_id)
	if chair == null:
		return
	chair.set_grade_from_quiz(grade_slot, quiz, quiz.has_negative_points)
	refresh()


func get_passed_chairs() -> Array[Chair]:
	return get_chairs().filter(func(chair: Chair): return chair.has_passed())


func get_failed_chairs() -> Array[Chair]:
	return get_chairs().filter(func(chair: Chair): return chair.has_failed())


func get_pass_ratio() -> float:
	var chairs = get_chairs()
	if chairs.is_empty():
		return 0.0
	return float(get_passed_chairs().size()) / float(chairs.size())


func update_stage() -> void:
	if get_chairs().is_empty():
		stage = 1
		return
	var all_chairs_passed = true
	for chair in get_chairs():
		if !chair.has_passed():
			all_chairs_passed = false
			break
	if all_chairs_passed:
		stage = 8
		return
	var highest_needed_stage = 1
	for chair in get_chairs():
		var status = chair.get_status()
		match status:
			Chair.Status.IN_PROGRESS:
				highest_needed_stage = max(highest_needed_stage, 1)
			Chair.Status.EXAM_ELIGIBLE, Chair.Status.FAILED_AVERAGE:
				highest_needed_stage = max(highest_needed_stage, 5)
			Chair.Status.RECURRENCE_ELIGIBLE:
				highest_needed_stage = max(highest_needed_stage, 6)
			Chair.Status.FAILED_RECURRENCE:
				highest_needed_stage = max(highest_needed_stage, 7)
	stage = highest_needed_stage


func update_diagnosis() -> void:
	var chairs = get_chairs()
	if chairs.is_empty():
		diagnosis = Diagnosis.NONE
		return
	var passed = get_passed_chairs().size()
	var failed = get_failed_chairs().size()
	var total = chairs.size()
	if passed == total:
		diagnosis = Diagnosis.AWESOME
	elif failed == total:
		diagnosis = Diagnosis.TERRIBLE
	elif passed > total / 2.0:
		diagnosis = Diagnosis.GREAT
	elif passed == total / 2.0:
		diagnosis = Diagnosis.ALRIGHT
	else:
		diagnosis = Diagnosis.MEH


func refresh() -> void:
	update_stage()
	update_diagnosis()
	save()
