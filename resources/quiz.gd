@tool
extends Resource
class_name Quiz

@export var id:= 0
@export var subject_id:= 0
@export var level:= 0
@export var start_time:= 0
@export var end_time:= 0
@export var journey_id:= 0
@export var template:= 0

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + ".tres")

func get_dir_path() -> String:
	return "user://quizzes/" + str(id).lpad(10, '0')

func get_file_path() -> String:
	return get_dir_path() + '.tres'

func create() -> void:
	DirAccess.make_dir_recursive_absolute(get_dir_path())
	save()

func save() -> void:
	return ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)

func generate() -> bool:
	randomize()
	var questions = get_subject().get_questions()
	questions = questions.filter(func (question: Question):
		return question.are_parents_decent()
	).filter(func (question: Question): return (question.is_open || question.is_choice) && !question.is_level_up_queued)
	questions.sort_custom(func (question_a: Question, question_b: Question):
		return question_a.miss_streak > question_b.miss_streak
	)
	questions.shuffle()
	questions = questions.slice(0, randi() % 10 + 11)
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
