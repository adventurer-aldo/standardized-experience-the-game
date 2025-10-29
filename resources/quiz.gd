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

func generate() -> void:
	randomize()
	print(subject_id)
	print(get_subject())
	var questions = get_subject().get_questions()
	questions.shuffle()
	questions = questions.slice(0, 10)
	for question in questions:
		move_question_to_quiz(question)

func get_questions() -> Array:
	var files = Array(DirAccess.get_files_at("user://quizzes/" + str(id).lpad(10, '0')))
	return files.map(func (question_filename):
		return ResourceLoader.load("user://quizzes/" + str(id).lpad(10, '0') + "/" + question_filename)
	)

func move_question_to_quiz(question: Question) -> void:
	var types = question.get_types()
	types.shuffle()
	question.attempt_type = types[0]
	question.save_to_quiz(id)
