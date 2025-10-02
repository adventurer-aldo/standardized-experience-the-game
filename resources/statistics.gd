@tool
class_name Statistics
extends Resource

@export var last_subject_id := 0
@export var last_question_id := 0

func next_subject_id() -> int:
	last_subject_id += 1
	save()
	return last_subject_id

func next_question_id() -> int:
	last_question_id += 1
	save()
	return last_question_id
	
func save() -> void:
	ResourceSaver.save(self, "user://stats.tres", ResourceSaver.FLAG_COMPRESS)
