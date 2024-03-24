extends TextureRect

func _ready():
	# BGM.autoplay("title")
	$ScrollContainer/ActionsContainer/Subjects.grab_focus()
	$Node3D/AnimationPlayer.play("zooms")

func _on_subjects_pressed():
	add_child(load("res://scenes/data/subjects.tscn").instantiate())

func _on_quiz_pressed():
	get_tree().change_scene_to_file("res://scenes/quiz/quiz.tscn")

func _on_download_pressed():
	get_tree().change_scene_to_file("res://scenes/download.tscn")

func _on_exit_pressed():
	get_tree().quit()
