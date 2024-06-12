@tool
class_name Stats
extends Resource

@export var last_question_id := 6800
@export var last_subject_id := 100
@export var last_journey_id := 1
@export var last_quiz_id := 1
@export var last_queue_id := 0

@export_range(1, 4) var last_practice_level := 1

@export var level := 1
@export var experience := 0.0
@export var username := ""

func save() -> void:
	ResourceSaver.save(self, "user://stats.res", ResourceSaver.FLAG_COMPRESS)
