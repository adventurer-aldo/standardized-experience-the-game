extends Control

var quiz
var answerer_node: PackedScene = load("res://scenes/quiz/answerer.tscn")
var subject_key := 0

func generate_quiz(subject_id: int, duration: int, level: int = 0) -> void:
	quiz = load("res://resources/quiz.tres").duplicate()
	Global.stats.last_quiz_id += 1
	quiz.subject_id = subject_id
	quiz.level = level
	quiz.id = Global.stats.last_quiz_id
	quiz.start_time = Time.get_unix_time_from_system()
	quiz.end_time = quiz.start_time + duration
	Global.save_stats()
	quiz.save()

func _ready():
	BGM.fade_out()
	SFX.speak(Text.quiz.pick_random())
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
	generate_quiz(Global.subjects.keys()[subject_key], 155, 1)
	quiz.generate_answers(answers_size().min, answers_size().max)
	$ScrollContainer/Elements/Margin/BasicInformation/Subject.text = Global.subjects[quiz.subject_id].title
	$ScrollContainer/Elements/Margin/BasicInformation/Level.text = ["Exercícios", "1º Teste",
	"2º Teste", "Reposição", "Dissertação", "Exame Normal", "Exame de Recorrência",
	"Exame Extraordinário"][quiz.level]
	$Time/Timer.wait_time = quiz.end_time - quiz.start_time
	var loaded_ques = answerer_node
	for answer in quiz.get_answers():
		var ques = loaded_ques.instantiate()
		ques.answer = answer
		ques.setup()
		$ScrollContainer/Elements/Questions.add_child(ques)
	$Time/Timer.start()
	$Time.process_mode = Node.PROCESS_MODE_INHERIT
	BGM.autoplay(ost().normal, ost().might, true)
	SFX.speak_stop()
	$Discard.hide()

func answers_size():
	match quiz.level:
		0: return {"min": 3, "max": 6}
		1: return {"min": 9, "max": 16}
		2: return {"min": 9, "max": 16}
		3: return {"min": 14, "max": 25}
		4: return {"min": 4, "max": 8}
		5: return {"min": 12, "max": 20}
		6: return {"min": 15, "max": 30}
		7: return {"min": 1000, "max": 1000}

func duration():
	match quiz.level:
		0: 2.5 * 60 * 60
		1: 9.5 * 60 * 60
		2: 9.5 * 60 * 60
		3: 12.5 * 60 * 60
		4: 5.5 * 60 * 60
		5: 15 * 60 * 60
		6: 20 * 60 * 60
		7: 9 * 60 * 60

func ost():
	match quiz.level:
		0: return {"normal": "engage_practice", "might": "engage_practice_might"}
		1: return {"normal": "engage_test1_0", "might": "engage_test1_0_might"}

func finish():
	var tween = create_tween()
	tween.tween_property($ScrollContainer, "scroll_vertical", 0, 1.0)
	for answerer in $ScrollContainer/Elements/Questions.get_children():
		answerer.respond()
	$ScrollContainer/Elements/Margin/BasicInformation/Control/Label.text = String.num(quiz.get_grade(), 2).replace(".", ",")
	BGM.fade_out()
	SFX.speak(result_speak(quiz.get_grade()))
	await SFX.speak_finished
	BGM.autoplay(result(quiz.get_grade()))

func result_speak(grade):
	if grade >= 20.0:
		return Text.quiz_results.victory.best_voice.pick_random()
	elif grade >= 18.5:
		return Text.quiz_results.victory.greatest_voice.pick_random()
	elif grade >= 14.5:
		return Text.quiz_results.victory.great_voice.pick_random()
	elif grade >= 9.5:
		return Text.quiz_results.victory.good_voice.pick_random()
	elif grade >= 6.5:
		return Text.quiz_results.defeat.nice_voice.pick_random()
	elif grade >= 3.5:
		return Text.quiz_results.defeat.tried_voice.pick_random()
	else:
		return Text.quiz_results.defeat.terrible_voice.pick_random()

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

func _on_time_rush_time_started() -> void:
	BGM.autoplay("engage_rush1_0_pre", "", false, "engage_rush1_0")
