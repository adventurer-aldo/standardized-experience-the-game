@tool
class_name Queue
extends Resource

@export var id: int
@export var scheduled_time: float
@export var subject_id: int
@export var question_id: int
@export var to_spaced_level: int
@export_enum("Spaced Level Up") var action: int = 0 

func check() -> void:
	print("Checking queue #" + str(id))
	if Time.get_unix_time_from_system() > scheduled_time:
		match action:
			0:
				var question = Global.subjects[subject_id].get_question(question_id)
				question.hit_streak = 0
				question.miss_streak = 3
				question.spaced_level = to_spaced_level
				question.is_level_up_queued = false
				question.save()
				erase()

func erase() -> void:
	print("I'm deleting the queue. Bye.")
	DirAccess.remove_absolute(resource_path)

func save() -> void:
	ResourceSaver.save(self, "user://queues/" + str(id) + '.res', ResourceSaver.FLAG_COMPRESS)
