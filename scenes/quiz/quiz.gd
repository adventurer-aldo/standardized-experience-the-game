extends Control

var quiz
var subject_key := 0

func generate_quiz(subject_id: int, duration: int, level: int = 1):
	quiz = load("res://resources/quiz.tres").duplicate()
	Global.stats.last_quiz_id += 1
	quiz.subject_id = subject_id
	quiz.level = level
	quiz.id = Global.stats.last_quiz_id
	var time = Time.get_unix_time_from_system()
	Global.save_stats()
	quiz.save()
	return quiz

func _ready():
	BGM.fade_out()
	Global.finished.connect(finish)
	if subject_key == 0:
		for i in Global.subjects.keys():
			var clone = $Discard/ScrollContainer/Subjects/SubjectSelector.duplicate()
			$Discard/ScrollContainer/Subjects.add_child(clone)
			clone.text = str(i) + ": " + Global.subjects[i].title
			clone.key = Global.subjects.keys().find(i)
	else:
		$Discard.hide()
		prepare()

func prepare():
	var quiz = generate_quiz(Global.subjects.keys()[subject_key], 160)
	quiz.generate_answers()
	$ScrollContainer/Elements/Margin/BasicInformation/Subject.text = Global.subjects[quiz.subject_id].title
	$Time/Timer.wait_time = quiz.end_time - quiz.start_time
	var loaded_ques = preload("res://scenes/quiz/answerer.tscn") as PackedScene
	var answers_size = quiz.get_answers().size()
	for answer in quiz.get_answers():
		var ques = loaded_ques.instantiate()
		ques.answer = answer
		ques.setup()
		$ScrollContainer/Elements/Questions.add_child(ques)
	$Time/Timer.start()
	BGM.autoplay("engage_practice", "engage_practice_rush")
	$Discard.hide()

func finish():
	var tween = create_tween()
	tween.tween_property($ScrollContainer, "scroll_vertical", 0, 1.0)
	for answerer in $ScrollContainer/Elements/Questions.get_children():
		answerer.respond()
	$ScrollContainer/Elements/Margin/BasicInformation/Control/Label.text = String.num(quiz.get_grade(), 2).replace(".", ",")
	BGM.autoplay(result(quiz.get_grade()))

func result(grade):
	if grade >= 20.0:
		return "results_victory_best"
	elif grade >= 18.5:
		return "results_victory_greatest"
	elif grade >= 14.5:
		return "results_victory_great"
	elif grade >= 9.5:
		return "results_victory_good"
	elif grade >= 6.5:
		return "results_defeat_nice"
	elif grade >= 3.5:
		return "results_defeat_tried"
	else:
		return "results_defeat_terrible"

func _on_timer_timeout():
	Global.emit_signal("finished")

func _on_submit_button_pressed():
	$Time/Timer.paused = true
	Global.emit_signal("finished")

func _on_button_pressed():
	get_tree().reload_current_scene()

func _on_subject_selector_subject_selected(id):
	if id == -1:
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	else:
		subject_key = id
		prepare()
