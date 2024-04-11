extends Node

signal finished
signal subjects_loaded
signal data_questions_edit_button_pressed(resource: Resource)
signal data_questions_parent_button_pressed(id: int)
signal data_questions_delete_button_pressed(resource: Resource)
signal data_questions_is_editing_question(id: int)
signal data_questions_parent_was_deleted(id: String)
signal data_questions_question_was_submitted(resource: Resource)

var subjects := {}
var questions := {}
var quiz
var stats

func _ready():
	for dir in ["subjects", "quizzes", "journeys", "queues"]:
		if !DirAccess.dir_exists_absolute("user://{dir}".format({"dir": dir})):
			DirAccess.make_dir_absolute("user://{dir}".format({"dir": dir}))
	if ResourceLoader.exists("user://stats.res"):
		stats = ResourceLoader.load("user://stats.res")
	else:
		stats = load("res://resources/stats.tres").duplicate()
		ResourceSaver.save(stats, "user://stats.res", ResourceSaver.FLAG_COMPRESS)


func save_stats():
	ResourceSaver.save(stats, "user://stats.res", ResourceSaver.FLAG_COMPRESS)

func get_subject(id: int):
	return subjects[id]

func get_question(_subject_id: int, _question_id: int):
	return

func get_quiz(id: int):
	return ResourceLoader.load("user://quizzes/" + str(id) + '.res')

func get_last_quiz():
	return get_quiz(stats.last_quiz_id)

func get_formatted_grade(grade: float):
	return String.num(grade, 2).replace(".", ",")

