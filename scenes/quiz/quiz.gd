extends Control

var grade := 0.0

func _process(_delta):
	$SubmitButton/Glow.global_position = get_global_mouse_position()

func generate_quiz(subject_id: int, duration: int, level: int = 1):
	var questions = User.questions.keys().filter(
		func i(k):
			var question = User.questions[k]
			return question.subject_id == subject_id
	)
	randomize()
	questions.shuffle()
	questions.resize(clamp(randi_range(10, 20), 0, questions.size()))
	var answers = questions.map(func i(question):
		var result = {
		"attempt": [], 
		"question_id": question, 
		"question_sample": randi() % User.questions[question].question.size(),
		"type": randi() % User.questions[question].types.size(),
		"choices": []
		}
		match User.questions[question].types[result.type]:
			'choice':
				var rchoices = User.questions[question].choices
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
				var choices = User.questions[question].choices
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
	var a = FileAccess.open("user://questions.dat", FileAccess.WRITE)
	a.store_var(User.questions)
	a.close()
	var quiz = generate_quiz(User.subjects.keys()[-1], 160)
	$ScrollContainer/Elements/Margin/BasicInformation/Subject.text = User.subjects[quiz.subject_id].title
	$Time/Timer.wait_time = quiz.end_time - quiz.start_time
	for i in quiz.answers:
		var loaded_ques = load("res://scenes/quiz/question.tscn") as PackedScene
		var ques := loaded_ques.instantiate()
		ques.grade = 20.0 / quiz.answers.size()
		ques.setup(i.question_id, i.question_sample, 
		User.questions[i.question_id].types[i.type], i.choices, 1)
		$ScrollContainer/Elements/Questions.add_child(ques)
		ques.show()
	$Time/Timer.start()
	# BGM.autoplay("test")

func finish():
	# BGM.autoplay("result")
	var tween = create_tween()
	tween.tween_property($ScrollContainer, "scroll_vertical", 0, 1.0)

func evaluate(value: float):
	grade += snapped(value, 0.01)
	$ScrollContainer/Elements/Margin/BasicInformation/Control/Label.text = str(grade).replace(".", ",")
	

func _on_timer_timeout():
	User.emit_signal("finished")


func _on_submit_button_pressed():
	$Time/Timer.paused = true
	User.emit_signal("finished")
