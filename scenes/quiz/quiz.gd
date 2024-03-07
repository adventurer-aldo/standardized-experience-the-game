extends Control

var grade := 0.0
var subject_key := 0

func generate_quiz(subject_id: int, duration: int, level: int = 1):
	var questions = Array(DirAccess.get_files_at("user://subjects/{subj}/".format({"subj": subject_id})))
	randomize()
	questions.shuffle()
	questions.resize(clamp(randi_range(10, 20), 0, questions.size()))
	var answers = questions.map(func i(question):
		var loaded_question = ResourceLoader.load("user://subjects/{subj}/{q}".format({"subj": subject_id, "q": question}))
		print(question)
		print(loaded_question)
		var result = {
		"attempt": [], 
		"question_id": int(question), 
		"question_sample": randi() % loaded_question.question.size(),
		"type": randi() % loaded_question.get_types().size(),
		"choices": []
		}
		match loaded_question.get_types()[result.type]:
			'choice':
				var rchoices = loaded_question.choices
				var true_choices = rchoices.filter(func i(choice):
					return choice.veracity == true)
				var false_choices = rchoices.filter(func i(choice):
					return choice.veracity == false)
				false_choices.resize(clamp(randi_range(1, 6), 0, false_choices.size()))
				var choices = true_choices + false_choices
				choices = choices.map(func n(k): return rchoices.find(k))
				choices.shuffle()
				result['choices'] = choices
			'veracity':
				var choices = loaded_question.choices
				choices = choices.map(func n(k): return choices.find(k))
				choices.shuffle()
				choices.resize(clamp(randi_range(2, 10), 0, choices.size()))
				result['choices'] = choices
		return result)
	var time = Time.get_datetime_dict_from_system()
	var start_time = time.second * time.minute * time.hour * time.day * time.month * time.year
	var end_time = start_time + duration
	return {"subject_id": subject_id, "start_time": start_time, "end_time": end_time,
	"level": level, "answers": answers}

func _ready():
	User.finished.connect(finish)
	User.grade.connect(evaluate)
	if subject_key == 0:
		for i in User.subjects.keys():
			var clone = $Discard/ScrollContainer/Subjects/SubjectSelector.duplicate()
			$Discard/ScrollContainer/Subjects.add_child(clone)
			clone.text = str(i) + ": " + User.subjects[i].title
			clone.key = User.subjects.keys().find(i)
	else:
		$Discard.hide()
		prepare()

func prepare():
	var quiz = generate_quiz(User.subjects.keys()[subject_key], 160)
	$ScrollContainer/Elements/Margin/BasicInformation/Subject.text = User.subjects[quiz.subject_id].title
	$Time/Timer.wait_time = quiz.end_time - quiz.start_time
	var loaded_ques = preload("res://scenes/quiz/question.tscn") as PackedScene
	for i in quiz.answers:
		var ques = loaded_ques.instantiate()
		ques.grade = 20.0 / quiz.answers.size()
		ques.setup(i.question_id, i.question_sample, 
		ResourceLoader.load("user://subjects/{subj}/{q}.res".format({"subj": quiz.subject_id, "q": i.question_id})).get_types()[i.type], i.choices, quiz.subject_id)
		$ScrollContainer/Elements/Questions.add_child(ques)
		ques.show()
	$Time/Timer.start()
	$Discard.hide()

func finish():
	var tween = create_tween()
	tween.tween_property($ScrollContainer, "scroll_vertical", 0, 1.0)

func evaluate(value: float):
	grade += snapped(value, 0.01)
	grade = clamp(grade, 0.0, 20.0)
	$ScrollContainer/Elements/Margin/BasicInformation/Control/Label.text = str(grade).replace(".", ",")

func _on_timer_timeout():
	User.emit_signal("finished")

func _on_submit_button_pressed():
	$Time/Timer.paused = true
	User.emit_signal("finished")

func _on_button_pressed():
	get_tree().reload_current_scene()

func _on_subject_selector_subject_selected(id):
	if id == -1:
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	else:
		subject_key = id
		prepare()
