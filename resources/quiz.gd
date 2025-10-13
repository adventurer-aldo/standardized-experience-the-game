@tool
extends Resource
class_name Quiz

@export var id:= 0
@export var subject_id:= 0
@export var level:= 0
@export var start_time:= 0
@export var end_time:= 0
@export var journey_id:= 0
@export var template:= 0

func subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(id).lpad(10, '0'))

func get_dir_path() -> String:
	return "user://quizzes/" + str(id).lpad(10, '0')

func get_file_path() -> String:
	return "user://quizzes/" + str(id).lpad(10, '0') + '.tres'

func save() -> void:
	return ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)

func generate() -> void:
	var questions = subject().get_questions()
