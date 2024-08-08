extends Control

var id
var quiz = Global.quiz as Quiz
var answerer_node: PackedScene = load("res://scenes/quiz/answerer.tscn")

func _ready():
	if quiz == null: quiz = Global.get_last_quiz()
	$ScrollContainer/Elements/Margin/BasicInformation/Subject.text = quiz.get_subject().title
	$ScrollContainer/Elements/Margin/BasicInformation/Level.text = ["Exercícios", "1º Teste",
	"2º Teste", "Reposição", "Dissertação", "Exame Normal", "Exame de Recorrência",
	"Exame Extraordinário"][quiz.level]
	var duration = quiz.end_time - quiz.start_time
	var minutes = int(duration / 60)
	var seconds = int(duration % 60)
	var grade = quiz.get_grade()
	# $ScrollContainer/Elements/Margin/BasicInformation/Control/Label.text = String.num(grade, 2).replace(".", ",")
	$Time/Label.text = (str(minutes) + "m "  if minutes > 0 else "") + str(seconds) + 's'
	var loaded_ques = answerer_node
	for answer in quiz.get_answers():
		var ques = loaded_ques.instantiate()
		ques.answer = answer
		ques.correct()
		$ScrollContainer/Elements/Questions.add_child(ques)
	# BGM.fade_out()
	SFX.speak(result_speak(grade))
	await SFX.speak_finished
	$Blackscreen/Transition.play("unblack")
	BGM.autoplay(result(quiz.get_grade()))

func result_speak(grade):
	randomize()
	if grade >= 20.0:
		return Text.quiz_results.victory.best_voice.pick_random()
	elif grade >= 17.5:
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
		$ResultParticles.emitting = true
		get_tree().create_tween().tween_property($TextureLoop, "modulate", Color(1.0, 1.0, 0.0), 1.5)
		return "results_victory_best"
	elif grade >= 18.5:
		get_tree().create_tween().tween_property($TextureLoop, "modulate", Color(0.0, 0.0, 1.0), 1.5)
		return "results_victory_greatest"
	elif grade >= 14.5:
		return "results_victory_great"
	elif grade >= 9.5:
		return "results_victory_good"
	elif grade >= 6.5:
		return "results_defeat_nice"
	elif grade >= 3.5:
		get_tree().create_tween().tween_property($TextureLoop, "modulate", Color(0.5, 0.0, 0.0), 1.5)
		return "results_defeat_tried"
	else:
		get_tree().create_tween().tween_property($TextureLoop, "modulate", Color(1.0, 0.0, 0.0), 1.5)
		return "results_defeat_terrible"

func _on_redo_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/quiz/quiz.tscn")
