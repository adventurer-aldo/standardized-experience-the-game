@tool
extends Resource
class_name Quiz

@export var id:= 0
@export var subject_id:= 0
@export var level:= 0
@export var start_time:= 0.0
@export var end_time:= 0.0
@export var journey_id:= 0
@export var saved_grade:= -1.0
@export var has_negative_points:= false
@export var should_rush:= true
@export var template:= 0

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + ".tres")

func get_dir_path() -> String:
	return "user://quizzes/" + str(id).lpad(10, '0')

func get_file_path() -> String:
	return get_dir_path() + '.tres'

func create() -> void:
	start_time = Time.get_unix_time_from_system()
	end_time = start_time + 600.0
	var subject = get_subject()
	if subject != null:
		has_negative_points = randf() < subject.negative_likelihood
	DirAccess.make_dir_recursive_absolute(get_dir_path())
	save()

func delete() -> void:
	var one = DirAccess.remove_absolute(get_dir_path())
	var two = DirAccess.remove_absolute(get_file_path())
	print("Attempted deletion of Quiz ID#{id}. Codes: {one} | {two}".format({"id": id, "one": one, "two": two}))
	
func save() -> void:
	return ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)

func generate() -> bool:
	randomize()
	var questions = get_filtered_questions(!(journey_id > 0))
	
	# Give priority to questions with a miss streak
	questions.sort_custom(func (question_a: Question, question_b: Question):
		return question_a.miss_streak > question_b.miss_streak
	)
	questions = questions.slice(0, randi() % 10 + 11)
	questions.shuffle()
	for question in questions:
		move_question_to_quiz(question, questions.find(question))
	return questions.size() > 0

func generate_rush_questions() -> void:
	var questions = get_rush_questions()
	for question in questions:
		var insert_index = randi() % max(1, size())
		move_question_to_quiz(question, insert_index, true)
	
func get_questions() -> Array[Question]:
	var files = Array(DirAccess.get_files_at("user://quizzes/" + str(id).lpad(10, '0')))
	var res: Array[Question] = []
	for question_filename in files:
		res.push_back(ResourceLoader.load("user://quizzes/" + str(id).lpad(10, '0') + "/" + question_filename))
	# Sort by attempt ID
	res.sort_custom(func (question_a: Question, question_b: Question):
		return question_a.attempt_index < question_b.attempt_index
	)
	return res

func has_rush_questions() -> bool:
	var rush_questions = get_questions().filter(func (question: Question):
		return question.is_rush
	)
	return rush_questions.size() > 0

func get_filtered_questions(block_unsolved_parents:= true) -> Array[Question]:
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
	if block_unsolved_parents:
		res = res.filter(func (question: Question):
			return question.are_parents_decent()
		)
	# Filter based on question type (This is only because other types haven't been properly implemented yet.)
	res = res.filter(func (question: Question): return (question.is_open || question.is_choice))
	# Filter based on not being in the leveling queue
	res = res.filter(func (question: Question): return !question.is_level_up_queued)
	return res

func get_rush_questions() -> Array[Question]:
	print("Fetching Rush questions")
	# Filter based on whether level up will be completed in midst of quiz
	var all_queued_questions = Main.data.get_questions_with_leveling_due_at(end_time)
	var questions = all_queued_questions.filter(func (question: Question):
		return question.subject_id == subject_id && (journey_id > 0 || question.are_parents_decent())
	)
	randomize()
	questions.shuffle()
	return questions.slice(0, 4)

func size() -> int:
	return DirAccess.get_files_at("user://quizzes/" + str(id).lpad(10, "0")).size()

func move_question_to_quiz(question: Question, positioning: int, rush_question:= false) -> void:
	var quiz_question = question.make_quiz_attempt(positioning, ["open", "choice", "veracity"])
	quiz_question.is_rush = rush_question
	quiz_question.save_to_quiz(id, positioning)

func calculate_grade(uses_negative_points:= false) -> float:
	var quiz_questions = get_questions()
	if quiz_questions.is_empty():
		saved_grade = 0.0
		save()
		return saved_grade
	var points_per_question = 20.0 / quiz_questions.size()
	var grade = 0.0
	for question in quiz_questions:
		grade += question.get_grade_points(points_per_question, uses_negative_points)
	saved_grade = clampf(grade, 0.0, 20.0)
	save()
	return saved_grade

func get_chair_grade_slot() -> int:
	match level:
		1:
			return Chair.GradeSlot.FIRST
		2:
			return Chair.GradeSlot.SECOND
		3:
			return Chair.GradeSlot.DISSERTATION
		4:
			return Chair.GradeSlot.REPOSITION
		5:
			return Chair.GradeSlot.EXAM
		6:
			return Chair.GradeSlot.RECURRENCE
	return 0
