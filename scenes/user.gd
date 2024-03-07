extends Node

signal finished
signal grade(value)

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
	print(stats.last_question_id)
	print(ResourceSaver.save(stats, "user://stats.res", ResourceSaver.FLAG_COMPRESS))
