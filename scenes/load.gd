extends ColorRect

signal file_loaded
signal data_loaded

var current_file: String = ""
var data_type: = "questions"

func _process(_delta):
	if current_file != "":
		match ResourceLoader.load_threaded_get_status("user://{type}/{file}".format({"file": current_file, "type": data_type})):
			3:
				current_file = ""
				emit_signal("file_loaded")

func load_questions():
	data_type = "questions"
	for file in DirAccess.get_files_at("user://questions"):
		ResourceLoader.load_threaded_request("user://questions/{file}".format({"file": file}), "", true)
		current_file = file
		await file_loaded
		Global.questions[int(file.replace(".res", ""))] = ResourceLoader.load_threaded_get("user://questions/{file}".format({"file": file}))
	data_loaded.emit()

func load_subjects():
	data_type = "subjects"
	var files = DirAccess.get_files_at("user://subjects")
	files.reverse()
	for file in files:
		ResourceLoader.load_threaded_request("user://subjects/{file}".format({"file": file}), "", true)
		current_file = file
		await file_loaded
		Global.subjects[int(file.replace(".res", ""))] = ResourceLoader.load_threaded_get("user://subjects/{file}".format({"file": file}))
	data_loaded.emit()
	
func _ready():
	load_subjects()
	$CircleSpin/Spin.play("spin")
	await get_tree().create_timer(2.0).timeout
	get_tree().create_tween().tween_property($CircleSpin, "self_modulate", Color.WHITE, 1.0)

func _on_spin_animation_finished(_anim_name):
	$CircleSpin/Spin.play("spin")

func _on_data_loaded():
	Global.emit_signal("subjects_loaded")
	# await get_tree().create_timer(52.0).timeout
	# get_tree().change_scene_to_file("res://scenes/data/subjects.tscn")
	# get_tree().change_scene_to_file("res://scenes/data/questions.tscn")
	get_tree().change_scene_to_file("res://scenes/playground.tscn")
	
