@tool 
class_name Subject
extends Resource

@export var id := 0
@export var title := ""
@export var description := ""

@export_category("Experience")
@export var level:= 0
@export var experience:= 0.0
@export var maximum_experience:= 0

func get_dir_path() -> String:
	return "user://subjects/" + str(id).lpad(10, '0')

func get_file_path() -> String:
	return "user://subjects/" + str(id).lpad(10, '0') + ".tres"

func create() -> void:
	id = Main.data.next_subject_id()
	if !DirAccess.dir_exists_absolute(get_dir_path()):
		DirAccess.make_dir_recursive_absolute(get_dir_path())
	save()

func erase() -> void:
	DirAccess.remove_absolute(get_file_path())
	DirAccess.remove_absolute(get_dir_path())

func get_questions() -> Array[Question]:
	var files = Array(DirAccess.get_files_at("user://subjects/" + str(id).lpad(10, '0')))
	var questions: Array[Question] = []
	for question_filename in files:
		var file_path = "user://subjects/" + str(id).lpad(10, '0') + "/" + question_filename
		questions.push_back(ResourceLoader.load(file_path))
	return questions

func get_question(question_id: int) -> Question:
	return ResourceLoader.load("user://subjects/" + str(id).lpad(10, '0') + "/" + str(question_id).lpad(10, '0') + ".tres")

func has_question(question_id: int) -> bool:
	return FileAccess.file_exists(get_dir_path() + "/" + str(question_id).lpad(10, '0') + ".tres")

func erase_question(question_id: int) -> void:
	DirAccess.remove_absolute(get_dir_path() + '/' + str(question_id).lpad(10, "0") + '.tres')

func get_quizzes() -> Array[Quiz]:
	var quizzes: Array[Quiz]
	for filename in DirAccess.get_files_at("user://quizzes"):
		var res: Quiz = ResourceLoader.load("user://quizzes/" + filename)
		if res.subject_id == id:
			quizzes.push_back(res)
	return quizzes

func size() -> int:
	return DirAccess.get_files_at(get_dir_path()).size()

func save() -> void:
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)

func update_experience() -> void:
	var levels = get_questions().map(func (question: Question): return question.experience_level)
	if !(levels.size() > 0): return
	print(maximum_experience)
	maximum_experience = levels.size() * 15
	var xp:= 0
	for question_level in levels:
		xp += question_level
	experience = xp
	print(experience)
	level = int((float(experience) / float(maximum_experience)) * 15.0)
	save()
