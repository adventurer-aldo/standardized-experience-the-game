extends Control

var level = {0: [],
1: ['Exercícios', 'Prática', 'Mini-teste'],
2: [],
3: [],
4: [],
5: [],
6: [],
7: []}

func _process(delta):
	$SubmitButton/Glow.global_position = get_global_mouse_position()
	# load("res://texts/level1_cheers.txt") as TextLine Resource

func generate_quiz(subject_id: int, duration: int, level: int = 1):
	var questions = User.questions.keys().filter(
		func i(k):
			var question = User.questions[k]
			return question.subject_id == subject_id && question.types.has('open')
	)
	randomize()
	questions.shuffle()
	questions.resize(clamp(randi_range(9, 15), 0, questions.size()))
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
				var choices = User.questions[question].choices
				choices = choices.map(func n(k): return choices.find(k))
				choices.shuffle()
				choices.resize(clamp(randi_range(2, 6), 0, choices.size()))
				choices += User.questions[question].answers.map(func n(k): return str(User.questions[question].answers.find(k)))
				result['choices'] = choices
			'veracity':
				var choices = User.questions[question].choices
				choices = choices.map(func n(k): return choices.find(k))
				choices += User.questions[question].answers.map(func n(k): return str(User.questions[question].answers.find(k)))
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
	var a = FileAccess.open("user://questions.dat", FileAccess.WRITE)
	a.store_var(User.questions)
	a.close()
	var quiz = generate_quiz(User.subjects.keys()[1], 10)
	$ScrollContainer/Elements/Margin/BasicInformation/Subject.text = User.subjects[quiz.subject_id].title
	$Time/Timer.wait_time = quiz.end_time - quiz.start_time
	for i in quiz.answers:
		var ques := $Question.duplicate()
		ques.setup(i.question_id, i.question_sample, 
		User.questions[i.question_id].types[i.type], i.choices, 1)
		$ScrollContainer/Elements/Questions.add_child(ques)
		ques.show()
	$Time/Timer.start()
	BGM.autoplay("test1_1")


func _on_timer_timeout():
	User.emit_signal("finished")
