extends Node

signal finished

var subjects := {}
var questions := {}

func _ready():
	if FileAccess.file_exists("user://subjects.dat"):
		var subjects_file = FileAccess.open("user://subjects.dat", FileAccess.READ)
		subjects = subjects_file.get_var(true)
		subjects_file.close()
	if FileAccess.file_exists("user://questions.dat"):
		var questions_file = FileAccess.open("user://questions.dat", FileAccess.READ)
		questions = questions_file.get_var(true)
		questions_file.close()
