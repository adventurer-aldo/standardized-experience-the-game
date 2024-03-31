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
	loaded_question.id = object.id
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
	var line = question_milestone_voice()
	if line != null: SFX.speak(question_milestone_voice())

func question_milestone_voice():
	match questions.size():
		1: return "1_question"
		5: return "5_questions"
		25: return "25_questions"
		50: return "50_questions"
		75: return "75_questions"
		100: return "100_questions"
		125: return "125_questions"
		150: return "150_questions"
		175: return "175_questions"
		200: return "200_questions"
		225: return "225_questions"
		250: return "250_questions"
		275: return "275_questions"
		300: return "300_questions"
		325: return "325_questions"
		350: return "350_questions"
		375: return "375_questions"
		400: return "400_questions"
		425: return "425_questions"
		450: return "450_questions"
		475: return "475_questions"
		500: return "500_questions"
		525: return "525_questions"
		550: return "550_questions"
		575: return "575_questions"
		600: return "600_questions"
		625: return "625_questions"
		650: return "650_questions"
		675: return "675_questions"
		700: return "700_questions"
		725: return "725_questions"
		750: return "750_questions"
		775: return "775_questions"
		800: return "800_questions"
		825: return "825_questions"
		850: return "850_questions"
		875: return "875_questions"
		900: return "900_questions"
		925: return "925_questions"
		950: return "950_questions"
		975: return "975_questions"
		1000: return "1000_questions"
