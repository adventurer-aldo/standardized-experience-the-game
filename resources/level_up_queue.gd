@tool
class_name LevelingQueue
extends Resource

@export var id:= 0
@export var question_id:= 0
@export var subject_id:= 0
@export var due_time:= 0.0

func check() -> bool:
	return Time.get_unix_time_from_system() > due_time

func erase() -> void:
	DirAccess.remove_absolute("user://leveling_queues/" + str(id).lpad(10, "0") + ".tres")

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, "0") + ".tres")

func get_question() -> Question:
	return get_subject().get_question(question_id)

func process_leveling() -> bool:
	if check():
		var question = get_question()
		question.is_level_up_queued = false
		question.last_time_leveled = Time.get_unix_time_from_system()
		question.save()
		erase()
		return true
	else: return false

func save() -> void:
	ResourceSaver.save(self, "user://leveling_queues/" + str(id).lpad(10, '0') + ".tres")
