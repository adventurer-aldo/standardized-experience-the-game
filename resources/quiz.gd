extends Resource

signal questions_generated

@export var id := 0
@export var subject_id := 0
@export var start_time: int
@export var end_time: int
@export var negative_grades := false
@export var username := ""
@export var surname := ""
@export var level := 0

func save():
	ResourceSaver.save(self, "user://quizzes/" + str(id) + ".res")
	DirAccess.make_dir_absolute("user://quizzes/" + str(id))

func get_subject():
	return ResourceLoader.load("user://subjects/" + str(subject_id) + ".res")

func get_answers():
	return Array(DirAccess.get_files_at("user://quizzes/" + str(id))).map(func i(answer):
		return ResourceLoader.load("user://quizzes/" + str(id) + '/'+ answer)
	)

func generate_answers():
	var questions = Array(DirAccess.get_files_at("user://subjects/{subj}/".format({"subj": subject_id}))).map(func i(question):
		return ResourceLoader.load("user://subjects/" + str(subject_id) + "/" + question)
	)
	randomize()
	questions.sort_custom(func i(question_a, question_b): return question_a.hit_streak < question_b.hit_streak)
	questions.resize(clamp(randi_range(10, 20), 0, questions.size()))
	var answer_resource = load("res://resources/answer.tres")
	var index_count = -1
	for question in questions:
		var answer = answer_resource.duplicate()
		index_count += 1
		answer.index = index_count
		answer.question_id = question.id
		answer.question_sample = randi() % question.question.size()
		answer.type = question.get_types()[randi() % question.get_types().size()]
		answer.grade = 20.0 / questions.size()
		answer.quiz_id = id
		question.appearances += 1
		question.save()
		
		match answer.type:
			'choice':
				var rchoices = question.choices
				var true_choices = rchoices.filter(func i(choice):
					return choice.veracity == true)
				var false_choices = rchoices.filter(func i(choice):
					return choice.veracity == false)
				false_choices.resize(clamp(randi_range(1, 6), 0, false_choices.size()))
				var choices = true_choices + false_choices
				choices = choices.map(func n(k): return rchoices.find(k))
				choices.shuffle()
				answer.choice_indexes = choices
			'veracity':
				var choices = question.choices
				choices = choices.map(func n(k): return choices.find(k))
				choices.shuffle()
				choices.resize(clamp(randi_range(2, 10), 0, choices.size()))
				answer.choice_indexes = choices
		answer.save()
	emit_signal("questions_generated")
