extends Control

var quiz: Quiz
var level := 1
var answerer_node: PackedScene = load("res://scenes/quiz/answerer.tscn")
var subject_key := 0

func generate_quiz(subject_id: int, length: int, lv: int = 0) -> void:
	quiz = load("res://resources/quiz.tres").duplicate()
	Global.stats.last_quiz_id += 1
	quiz.subject_id = subject_id
	quiz.level = lv
	Global.stats.last_practice_level = lv
	quiz.id = Global.stats.last_quiz_id
	quiz.start_time = Time.get_unix_time_from_system()
	quiz.end_time = quiz.start_time + length
	Global.save_stats()
	quiz.save()

func bgm_stuff() -> void:
	BGM.fade_out()
	await BGM.fade_in_finished
	if SFX.voice.playing:
		await SFX.speak_finished
	BGM.autoplay("houses_level2")

func _exit_tree() -> void:
	if BGM.playing: BGM.fade_out()

func _ready():
	bgm_stuff()
	SFX.speak(Text.quiz.pick_random())
	Global.finished.connect(finish)
	BGM.rush_time_started.connect(rush_started)
	match Global.stats.last_practice_level:
		1: $Discard/Levels/Level1.button_pressed = true
		2: $Discard/Levels/Level2.button_pressed = true
		4: $Discard/Levels/Level4.button_pressed = true
	if subject_key == 0:
		var keys = Global.subjects.values()
		keys.sort_custom(func i(key_a: Subject, key_b: Subject): return key_a.last_time_edited > key_b.last_time_edited)
		for subject in keys:
			var clone = $Discard/ScrollContainer/Subjects/SubjectSelector.duplicate()
			$Discard/ScrollContainer/Subjects.add_child(clone)
			clone.text = str(subject.id) + ": " + subject.title
			clone.key = subject.id
	else:
		$Discard.hide()
		prepare()

func prepare():
	generate_quiz(Global.subjects[subject_key].id, duration(), level)
	quiz.generate_answers(answers_size().min, answers_size().max)
	if quiz.get_answers().size() < 1:
		SFX.speak("this_is_empty")
		return
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
		if answer.hidden: 
			ques.hide()
			ques.add_to_group("hidden_question")
	$Time/Timer.start()
	$Time.process_mode = Node.PROCESS_MODE_INHERIT
	var should_might = quiz.get_answers()[0].get_question().hit_streak > 0
	BGM.autoplay(ost(), should_might)
	SFX.speak_stop()
	$Discard.hide()

func answers_size():
	match quiz.level:
		0: return {"min": 3, "max": 6}
		1: return {"min": 9, "max": 16}
		2: return {"min": 9, "max": 16}
		3: return {"min": 4, "max": 8}
		4: return {"min": 14, "max": 25}
		5: return {"min": 12, "max": 20}
		6: return {"min": 15, "max": 30}
		7: return {"min": 1000, "max": 1000}

func duration():
	match level:
		0: return 2.5 * 60
		1: return 9.5 * 60
		2: return 9.5 * 60
		3: return 12.5 * 60
		4: return 12.5 * 60
		5: return 15 * 60
		6: return 20 * 60
		7: return 9 * 60

func ost():
	match quiz.level:
		0: return "engage_practice"
		1: return ["engage_test1_1", "engage_test1_2",# "engage_test2_0",
		"engage_test1_4", "houses_test2_0"].pick_random()
		2: return ["houses_test2_0", "engage_test2_hope", "engage_challenge1"].pick_random()
		4: return ["houses_rec_0", "engage_extraordinary"].pick_random()

func finish():
	quiz.end_time = Time.get_unix_time_from_system()
	quiz.save()
	$RushParticles.emitting = false
	$TextureLoop/LoopAnim.stop()
	$Time/Blinking.play("RESET")
	$Time/Blinking.stop()
	var tween = create_tween()
	tween.tween_property($ScrollContainer, "scroll_vertical", 0, 1.0)
	for answerer in $ScrollContainer/Elements/Questions.get_children():
		answerer.respond()
	BGM.fade_out()
	$Blackscreen/Transition.play("black")
	await $Blackscreen/Transition.animation_finished
	Global.quiz = quiz
	get_tree().change_scene_to_file("res://scenes/quiz/results.tscn")

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
	$SubmitButton.disabled = true
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
	BGM.autoplay_rush("engage_rushexam_0")
	$TextureLoop/LoopAnim.speed_scale = 0.5
	$TextureLoop/RushFade.play("fade_in")
	$GradientPlayer.play("appear")
	for node: HBoxContainer in get_tree().get_nodes_in_group("hidden_question"):
		node.show()
		$ScrollContainer.ensure_control_visible(node)
		await get_tree().create_timer(0.5).timeout

func rush_started(_x) -> void:
	$TextureLoop/LoopAnim.speed_scale = 8
	$RushParticles.emitting = true
	$GradientPlayer.play("disappear")


func _on_level_1_toggled(toggled_on: bool) -> void:
	if toggled_on: level = 1

func _on_level_2_toggled(toggled_on: bool) -> void:
	if toggled_on: level = 2

func _on_level_4_toggled(toggled_on: bool) -> void:
	if toggled_on: level = 4
