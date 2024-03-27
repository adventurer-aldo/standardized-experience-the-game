extends VBoxContainer

signal parent_pressed(id)
signal delete_pressed(id)
signal edit_pressed(id)
signal file_loaded
signal single_file_loaded

var current_file: String = ""
var subject_id := 0
var questions = {}
var current_single_file := ""

func _process(_delta):
	if current_file != "":
		match ResourceLoader.load_threaded_get_status("user://subjects/{subj}/{file}".format({"file": current_file, "subj": subject_id})):
			3:
				current_file = ""
				emit_signal("file_loaded")
	if current_single_file != "":
		match ResourceLoader.load_threaded_get_status("user://subjects/{subj}/{file}".format({"file": current_single_file, "subj": subject_id})):
			3:
				current_single_file = ""
				emit_signal("single_file_loaded")

func load_questions():
	var don: PackedScene = load("res://scenes/question_column.tscn")
	var files = DirAccess.get_files_at("user://subjects/" + str(subject_id))
	files.reverse()
	for file in files:
		ResourceLoader.load_threaded_request("user://subjects/{subj}/{file}".format({"file": file, "subj": subject_id}), "", true)
		current_file = file
		await file_loaded
		var question = ResourceLoader.load_threaded_get("user://subjects/{subj}/{file}".format({"file": file, "subj": subject_id}))
		add_child(prepare_question(don, question))
		questions[int(file)] = question

func prepare_question(template, object):
	var loaded_question = template.instantiate()
	loaded_question.questions = object.question
	loaded_question.resource = object
	Global.data_questions_question_was_submitted.connect(loaded_question.check_if_was_edited_question)
	return loaded_question

func _on_questions_submitted(id):
	ResourceLoader.load_threaded_request("user://subjects/{subj}/{file}".format({"file": str(id) + ".res", "subj": subject_id}), "", true)
	current_single_file = str(id) + ".res"
	await single_file_loaded
	var don: PackedScene = load("res://scenes/question_column.tscn")
	var question = ResourceLoader.load_threaded_get("user://subjects/{subj}/{file}".format({"file": str(id) + ".res", "subj": subject_id}))
	$Node.add_sibling(prepare_question(don, question))
	questions[id] = question
