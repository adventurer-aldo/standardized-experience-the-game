extends Node

signal finished
signal data_questions_edit_button_pressed(resource: Resource)
signal data_questions_parent_button_pressed(id: int)
signal data_questions_delete_button_pressed(resource: Resource)
signal data_questions_is_editing_question(id: int)

var subjects := {}
var questions := {}
var stats

func _ready():
	for dir in ["subjects", "quizzes", "journeys"]:
		if !DirAccess.dir_exists_absolute("user://{dir}".format({"dir": dir})):
			DirAccess.make_dir_absolute("user://{dir}".format({"dir": dir}))
	if ResourceLoader.exists("user://stats.res"):
		stats = ResourceLoader.load("user://stats.res")
	else:
		stats = load("res://resources/stats.tres").duplicate()
		ResourceSaver.save(stats, "user://stats.res", ResourceSaver.FLAG_COMPRESS)

func save_stats():
	ResourceSaver.save(stats, "user://stats.res", ResourceSaver.FLAG_COMPRESS)

func get_quiz(id: int):
	return ResourceLoader.load("user://quizzes/" + str(id) + '.res')

func get_last_quiz():
	return get_quiz(stats.last_quiz_id)

