@tool
class_name Quiz
extends Resource

signal questions_generated

@export var id := 0
@export var subject_id := 0
@export var start_time: int
@export var end_time: int
@export var completed_grade: float
@export var negative_grades := false
@export var username := ""
@export var surname := ""
@export var level := 0

func generate_answers(min_answers := 3, max_answers := 5) -> void:
	var questions = Array(DirAccess.get_files_at("user://subjects/{subj}/".format({"subj": subject_id}))).map(func i(question):
		return ResourceLoader.load("user://subjects/" + str(subject_id) + "/" + question)
	).filter(func i(question: Question):
		return question.level == level || (level == 4 && [1, 2].has(question.level))).filter(func i(question: Question): 
		return question.are_parents_above_spaced_level(7) || question.are_parents_level_up_queued())
	
	var unleveled_questions = questions.filter(
			func i(question: Question):
				return question.is_level_up_queued == false)

	var evaluable_questions := []
		
	var amount_of_questions = clamp(randi_range(min_answers, max_answers), 0, questions.size())
	
	var splits = divide_randomly_with_minimums(amount_of_questions, 3, [0, 0, 1])
	unleveled_questions.sort_custom(func i(question_a: Question, question_b: Question): 
		return question_a.appearances < question_b.appearances
	)
	for i in range(splits[0]):
		evaluable_questions.push_back(unleveled_questions.pop_back())
	
	unleveled_questions.sort_custom(func i(question_a: Question, question_b: Question):
		return question_a.hit_streak > question_b.hit_streak
	)
	for i in range(splits[1]):
		evaluable_questions.push_back(unleveled_questions.pop_back())
	
	unleveled_questions.sort_custom(func i(question_a: Question, question_b: Question):
		return question_a.miss_streak > question_b.miss_streak
	)
	for i in range(splits[2]):
		evaluable_questions.push_back(unleveled_questions.pop_back())
	
	if unleveled_questions.size() < amount_of_questions && [false, false].pick_random():
		var arr = questions.filter(func i(question: Question): return !evaluable_questions.has(question))
		arr.shuffle()
		for i in range(amount_of_questions - unleveled_questions.size() - 1):
			evaluable_questions.push_back(arr.pop_back())
	
	evaluable_questions = evaluable_questions.filter(func i(question: Question): return question != null)
	print("%s questions are evaluable for the current subject ID %s." % [str(questions.size()), subject_id])
	randomize()
	evaluable_questions.shuffle()
	var answer_resource = load("res://resources/answer.tres")
	var index_count = -1
	for question in evaluable_questions:
		var answer = answer_resource.duplicate()
		index_count += 1
		if index_count > 5:
			answer.hidden = [false].pick_random()
		answer.index = index_count
		answer.question_id = question.id
		answer.question_sample = randi() % question.question.size()
		answer.type = question.get_types()[randi() % question.get_types().size()]
		answer.grade = 20.0 / evaluable_questions.size()
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
	questions_generated.emit()

func get_subject():
	return ResourceLoader.load("user://subjects/" + str(subject_id) + ".res")

func get_answers() -> Array:
	return Array(DirAccess.get_files_at("user://quizzes/" + str(id))).map(func i(answer):
		return ResourceLoader.load("user://quizzes/" + str(id) + '/'+ answer)
	)

func divide_randomly_with_minimums(x: int, y: int, mins: Array) -> Array:
	var parts = []
	var remaining = x
	var total_minimum = 0
	
	# Calculate total minimum required
	for min_value in mins:
		total_minimum += min_value
	
	# If total minimum exceeds x, adjust minimums
	if total_minimum > x:
		var scale_factor = float(x) / float(total_minimum)
		for i in range(mins.size()):
			mins[i] = int(mins[i] * scale_factor)
	
	for i in range(y - 1):
		var min_value = mins[i] if mins.size() > i else 0
		var part = randi_range(min_value, remaining)
		parts.append(part)
		remaining -= part
	
	# Add the remaining to the last part
	parts.append(remaining)
	
	return parts

func get_grade() -> float:
	var grade = 0.0
	for answer in get_answers():
		if answer.is_correct(): grade += answer.grade
	if !completed_grade:
		completed_grade = grade
		save()
	return grade

func save():
	ResourceSaver.save(self, "user://quizzes/" + str(id) + ".res")
	DirAccess.make_dir_absolute("user://quizzes/" + str(id))
