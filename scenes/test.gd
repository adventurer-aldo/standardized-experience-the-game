extends Node

signal file_loaded

var current_file: String = ""

func _ready():
	pass # loading()

func _process(_delta):
	if current_file != "":
		match ResourceLoader.load_threaded_get_status("user://questions/{file}".format({"file": current_file})):
			3:
				current_file = ""
				print("One question has been fully loaded!")
				emit_signal("file_loaded")

func loading():
	var quests = DirAccess.get_files_at("user://questions")
	print("Finished scanning")
	var questions = {}
	for file in quests:
		ResourceLoader.load_threaded_request("user://questions/{file}".format({"file": file}))
		current_file = file
		await file_loaded
		questions[file] = ResourceLoader.load_threaded_get("user://questions/{file}".format({"file": file}))
	print("Finished making questions array")
	var a = questions[quests[-55]]
	print(a.question)

