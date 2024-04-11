extends TextureRect

func _ready():
	SFX.speak(Text.start.pick_random())
	$ScrollContainer/ActionsContainer/Subjects.grab_focus()
	if Global.subjects.size() < 1: return
	$Top/Middle/Label.text = "Your last test was of {subject_title}, with the grade {grade}.".format({
		"subject_title": Global.subjects[Global.get_last_quiz().subject_id].title,
		"grade": Global.get_formatted_grade(Global.get_last_quiz().completed_grade)
	})

func _on_subjects_pressed():
	blacken()
	add_child(load("res://scenes/data/subjects.tscn").instantiate())

func _on_quiz_pressed():
	get_tree().change_scene_to_file("res://scenes/quiz/quiz.tscn")

func _on_download_pressed():
	get_tree().change_scene_to_file("res://scenes/download.tscn")

func _on_exit_pressed():
	$Blackscreen/Transition.play("blacken")
	SFX.speak(Text.exit.pick_random())
	await SFX.speak_finished
	get_tree().quit()

func blacken():
	$Blackscreen/Transition.play("mid_blacken")

func unblacken():
	$Blackscreen/Transition.play("unmid_blacken")
