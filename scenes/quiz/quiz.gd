extends Control

func generate_quiz(subject_id: int, duration: int, level: int = 1):
	var questions = User.questions.keys().filter(
		func i(k):
			var question = User.questions[k]
			return question.subject_id == subject_id && question.types.has('open')
	)
	randomize()
	questions.shuffle()
	questions.resize(clamp(randi_range(199, 299), 0, questions.size()))
	var answers = questions.map(func i(question):
		var choices = User.questions[question].choices
		choices = choices.map(func n(k): return choices.find(k))
		choices.shuffle()
		choices.resize(clamp(randi_range(2, 6), 0, choices.size()))
		choices += User.questions[question].answers.map(func n(k): return str(User.questions[question].answers.find(k)))
		return {
		"attempt": [], 
		"question_id": question, 
		"question_sample": randi() % User.questions[question].question.size(),
		"type": randi() % User.questions[question].types.size(),
		"choices": choices
	})
	var time = Time.get_datetime_dict_from_system()
	var start_time = time.second * time.minute * time.hour * time.day * time.month * time.year
	var end_time = start_time + duration
	return {"subject_id": subject_id, "start_time": start_time, "end_time": end_time,
	"level": level, "answers": answers}

func _ready():
	var a = FileAccess.open("user://questions.dat", FileAccess.WRITE)
	a.store_var(User.questions)
	a.close()
	var quiz = generate_quiz(User.subjects.keys()[1], 60)
	for i in quiz.answers:
		var ques := $Question.duplicate()
		ques.setup(i.question_id, i.question_sample, 
		User.questions[i.question_id].types[i.type], i.choices, 1)
		$ScrollContainer/Questions.add_child(ques)
		ques.show()
