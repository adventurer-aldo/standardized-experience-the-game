@tool
extends Resource
class_name Quiz

@export var id:= 0
@export var subject_id:= 0
@export var level:= 0
@export var start_time:= 0.0
@export var end_time:= 0.0
@export var journey_id:= 0
@export var template:= 0

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + ".tres")

func get_dir_path() -> String:
	return "user://quizzes/" + str(id).lpad(10, '0')

func get_file_path() -> String:
	return get_dir_path() + '.tres'

func create() -> void:
	start_time = Time.get_unix_time_from_system()
	end_time = start_time + 3000.0
	DirAccess.make_dir_recursive_absolute(get_dir_path())
	save()

func save() -> void:
	return ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)

func generate() -> bool:
	randomize()
	var questions = get_filtered_questions()
	
	# Give priority to questions with a miss streak
	questions.sort_custom(func (question_a: Question, question_b: Question):
		return question_a.miss_streak > question_b.miss_streak
	)
	questions = questions.slice(0, randi() % 10 + 11)
	questions.shuffle()
	for question in questions:
		var possible_types = question.get_types().filter(func (type: String): 
			return ['choice', 'open'].has(type)
		)
		possible_types.shuffle()
		question.attempt_type = possible_types[0]
		move_question_to_quiz(question, questions.find(question))
	return questions.size() > 0

func get_questions() -> Array[Question]:
	var files = Array(DirAccess.get_files_at("user://quizzes/" + str(id).lpad(10, '0')))
	var res: Array[Question] = []
	for question_filename in files:
		res.push_back(ResourceLoader.load("user://quizzes/" + str(id).lpad(10, '0') + "/" + question_filename))
	return res

func get_filtered_questions() -> Array[Question]:
	var res:= get_subject().get_questions()
	# Filter based on quiz's level
	res = res.filter(func (question: Question):
		match level:
			0, 4, 5, 6:
				return question.level != 3
			1:
				return question.level == 1
			2:
				return question.level == 2
			3:
				return question.level == 3
	)
	# Filter based on the parents having completed basic mastery
	res = res.filter(func (question: Question):
		return question.are_parents_decent()
	)
	# Filter based on question type
	res = res.filter(func (question: Question): return (question.is_open || question.is_choice))
	# Filter based on not being in the leveling queue
	res = res.filter(func (question: Question): return !question.is_level_up_queued)
	return res

func get_rush_questions() -> Array[Question]:
	print("Updating")
	Main.begin_update()
	await Main.update_finished
	print("I awaited the finish.")
	var questions = get_filtered_questions()
	# Filter based on whether level up was completed in midst of quiz
	var queue_range = range(start_time, Time.get_unix_time_from_system() + 10.0)
	questions = questions.filter(func (question: Question):
		return queue_range.has(int(question.last_time_leveled))
	)	
	return questions.slice(0, 4)

func move_question_to_quiz(question: Question, positioning: int) -> void:
	randomize()
	var types = question.get_types()
	types.shuffle()
	question.attempt_type = types[0]
	match question.attempt_type:
		"choice":
			for i in question.answer:
				var shuffled_ans: Array = i["texts"].duplicate()
				shuffled_ans.shuffle()
				question.formulated_variables.push_back(shuffled_ans[0])
			var shuffled_choices: Array = question.choices.duplicate()
			question.choices.shuffle()
			for i in randi_range(0, shuffled_choices.size()):
				question.formulated_variables.push_back(shuffled_choices[i])
	question.save_to_quiz(id, positioning)
