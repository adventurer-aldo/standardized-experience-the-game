extends Node

func _ready():
	var voices = load("res://texts/level1_cheers.txt")
	print(FileAccess.open("res://texts/level1_cheers.txt", FileAccess.READ).get_as_text())
	
	print(User.questions[User.questions.keys().filter(func i(k):
		return int(User.questions[k].subject_id) == User.subjects.keys()[-1]
	)[0]])
