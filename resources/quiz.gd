@tool
extends Resource
class_name Quiz

const QUESTION_FILTER := preload("res://resources/question_filter.gd")

@export var id:= 0
@export var subject_id:= 0
@export var level:= 0
@export var start_time:= 0.0
@export var end_time:= 0.0
@export var journey_id:= 0
@export var saved_grade:= -1.0
@export var has_negative_points:= false
@export var should_ambush:= true
@export var should_rush:= true
@export var is_ambush_rush:= false
@export var template:= 0
@export var allowed_question_types:= []
@export var required_tags:= []
@export var required_parent_ids:= []
@export var include_parent_ancestors:= true

func get_subject() -> Subject:
	return ResourceLoader.load("user://subjects/" + str(subject_id).lpad(10, '0') + ".tres")

func get_dir_path() -> String:
	return "user://quizzes/" + str(id).lpad(10, '0')

func get_file_path() -> String:
	return get_dir_path() + '.tres'

func create() -> void:
	start_time = Time.get_unix_time_from_system()
	if level <= 0 && journey_id <= 0 && !Engine.is_editor_hint():
		level = Main.data.focus
	end_time = start_time + _get_duration_seconds()
	var subject = get_subject()
	if subject != null:
		has_negative_points = randf() < subject.negative_likelihood
	DirAccess.make_dir_recursive_absolute(get_dir_path())
	save()
	if !Engine.is_editor_hint():
		Main.data.prune_old_quizzes()

func delete() -> void:
	for filename in DirAccess.get_files_at(get_dir_path()):
		DirAccess.remove_absolute(get_dir_path() + "/" + filename)
	var one = DirAccess.remove_absolute(get_dir_path())
	var two = DirAccess.remove_absolute(get_file_path())
	print("Attempted deletion of Quiz ID#{id}. Codes: {one} | {two}".format({"id": id, "one": one, "two": two}))
	
func save() -> void:
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)

func generate() -> bool:
	randomize()
	if level <= 0 && journey_id <= 0 && !Engine.is_editor_hint():
		level = Main.data.focus
	var questions = get_filtered_questions(!(journey_id > 0))
	
	# Give priority to questions with a miss streak
	questions.sort_custom(func (question_a: Question, question_b: Question):
		return question_a.miss_streak > question_b.miss_streak
	)
	var target_count = 96 if level == 6 else randi() % 10 + 11
	questions = questions.slice(0, min(target_count, questions.size()))
	questions.shuffle()
	for question in questions:
		move_question_to_quiz(question, questions.find(question))
	return questions.size() > 0

func generate_async(tree: SceneTree) -> bool:
	randomize()
	if level <= 0 && journey_id <= 0 && !Engine.is_editor_hint():
		level = Main.data.focus
	var subject = get_subject()
	if subject == null:
		return false
	var filter_options = _get_filter_options(!(journey_id > 0))
	var questions: Array[Question] = []
	var loaded_count:= 0
	for question_filename in subject.get_question_file_names(true):
		var question = ResourceLoader.load(subject.get_question_file_path(question_filename), "", ResourceLoader.CACHE_MODE_REPLACE) as Question
		if QUESTION_FILTER.matches(question, subject, filter_options):
			questions.push_back(question)
		loaded_count += 1
		if loaded_count % 2 == 0:
			await tree.process_frame
	questions.sort_custom(func (question_a: Question, question_b: Question):
		return question_a.miss_streak > question_b.miss_streak
	)
	var target_count = 96 if level == 6 else randi() % 10 + 11
	questions = questions.slice(0, min(target_count, questions.size()))
	questions.shuffle()
	for question_index in range(questions.size()):
		move_question_to_quiz(questions[question_index], question_index)
		await tree.process_frame
	return questions.size() > 0

func generate_rush_questions() -> void:
	generate_ambush_questions()

func generate_ambush_questions() -> void:
	var questions = get_rush_questions()
	for question in questions:
		var insert_index = randi() % max(1, size())
		move_question_to_quiz(question, insert_index, true)
	
func get_questions() -> Array[Question]:
	var res: Array[Question] = []
	for file_path in get_question_file_paths():
		var question = ResourceLoader.load(file_path) as Question
		if question != null:
			res.push_back(question)
	# Sort by attempt ID
	res.sort_custom(func (question_a: Question, question_b: Question):
		return question_a.attempt_index < question_b.attempt_index
	)
	return res

func get_question_file_paths() -> Array:
	var files = Array(DirAccess.get_files_at(get_dir_path())).filter(func(filename):
		return str(filename).ends_with(".tres")
	)
	files.sort()
	return files.map(func(filename): return get_dir_path() + "/" + str(filename))

func has_rush_questions() -> bool:
	return has_ambush_questions()

func has_ambush_questions() -> bool:
	var rush_questions = get_questions().filter(func (question: Question):
		return question.is_ambush || question.is_rush
	)
	return rush_questions.size() > 0

func get_filtered_questions(block_unsolved_parents:= true) -> Array[Question]:
	var subject = get_subject()
	if subject == null:
		return []
	return QUESTION_FILTER.apply(subject.get_questions(), subject, _get_filter_options(block_unsolved_parents))

func _get_filter_options(block_unsolved_parents:= true) -> Dictionary:
	return {
		"quiz_level": level,
		"types": allowed_question_types,
		"tags": required_tags,
		"parent_ids": required_parent_ids,
		"include_parent_ancestors": include_parent_ancestors,
		"block_unsolved_parents": block_unsolved_parents,
		"exclude_level_up_queued": true,
	}

func get_rush_questions() -> Array[Question]:
	return get_ambush_questions()

func get_ambush_questions() -> Array[Question]:
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
	var quiz_question = question.make_quiz_attempt(positioning, allowed_question_types)
	quiz_question.is_rush = rush_question
	quiz_question.is_ambush = rush_question
	quiz_question.strip_for_quiz_attempt()
	quiz_question.save_to_quiz(id, positioning)

func calculate_grade(uses_negative_points:= false) -> float:
	var quiz_questions = get_questions()
	if quiz_questions.is_empty():
		saved_grade = 0.0
		save()
		return saved_grade
	var total_weight = 0.0
	for question in quiz_questions:
		total_weight += question.get_score_units()
	var grade = 0.0
	for question in quiz_questions:
		var points_per_question = 20.0 * (question.get_score_units() / total_weight)
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

func _get_duration_seconds() -> float:
	match level:
		5:
			return 20.0 * 60.0
		6:
			return 60.0 * 60.0
	return 10.0 * 60.0
