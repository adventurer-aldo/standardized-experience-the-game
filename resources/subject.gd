@tool 
class_name Subject
extends Resource

@export var id := 0
@export var mediaset_id: int
@export var title := ""
@export var description := ""
@export var last_question_id:= 0

@export var is_journey_eligible:= false

@export_category("Experience")
@export var level:= 0
@export var experience:= 0.0
@export var maximum_experience:= 0

@export_category("Stats")
@export var last_time_saved:= Time.get_unix_time_from_system()

func get_dictionary() -> Dictionary:
	var res: Dictionary
	var elements: PackedStringArray = ['id','title','description',
	'last_question_id','is_journey_eligible', 'last_time_saved']
	for element in elements:
		res[element] = get(element)
	return res

func get_dir_path() -> String:
	return "user://subjects/" + str(id).lpad(10, '0')

func get_file_path() -> String:
	return "user://subjects/" + str(id).lpad(10, '0') + ".tres"

func create() -> void:
	id = Main.data.next_subject_id()
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

func erase_question(question_id: int, post:= true) -> void:
	var question = get_question(question_id)
	if question:
		question.erase(post)
	# DirAccess.remove_absolute(get_dir_path() + '/' + str(question_id).lpad(10, "0") + '.tres')

func get_quizzes() -> Array[Quiz]:
	var quizzes: Array[Quiz]
	for filename in DirAccess.get_files_at("user://quizzes"):
		var res: Quiz = ResourceLoader.load("user://quizzes/" + filename)
		if res.subject_id == id:
			quizzes.push_back(res)
	return quizzes

func size() -> int:
	return DirAccess.get_files_at(get_dir_path()).size()

func save(post:= true) -> void:
	if !DirAccess.dir_exists_absolute(get_dir_path()):
		DirAccess.make_dir_recursive_absolute(get_dir_path())
	last_time_saved = Time.get_unix_time_from_system()
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)
	if post:
		Main.subject_http.request("https://standardized-experience-cloud.adventureraldo.workers.dev/api/subject/", ["Content-type: application/json"], HTTPClient.METHOD_POST,
		JSON.stringify([get_dictionary()]))

func absorb_dictionary(dict: Dictionary) -> void:
	id = dict["local_id"]
	title = dict["title"]
	description = dict["description"]
	last_time_saved = dict["last_time_saved"]
	is_journey_eligible = dict["is_journey_eligible"]
	last_question_id = dict["last_question_id"]

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
	save(false)

func update_level() -> void:
	var exper = experience
	var max_exp = size() * 15
	print("The current subject is: " + title + " with the ID " + str(id))
	var lvl = (exper / max_exp) * 15
	level = clampi(lvl, 0, 15)
	if max_exp > 0: 
		level = clampi(lvl, 1, 15)
	print("Finished dealing with " + title)
	save(false)

func next_question_id(should_save:= true) -> int:
	var value_to_return = 0
	if should_save:
		last_question_id += 1
		value_to_return = last_question_id
		save(false)
	else:
		value_to_return = last_question_id + 1
	return value_to_return
