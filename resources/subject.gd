@tool 
class_name Subject
extends Resource

@export var id := 0
@export var title := ""
@export var description := ""
@export var last_question_id:= 0
@export var image_mediaset_id:= 0

@export var is_journey_eligible:= false

@export_category("Journey Rules")
@export var exemption:= true
@export var rigid:= false
@export_range(0.0, 1.0, 0.01) var negative_likelihood:= 0.0

@export_category("Experience")
@export var level:= 0
@export var experience:= 0.0
@export var maximum_experience:= 0

@export_category("Stats")
@export var last_time_saved:= Time.get_unix_time_from_system()

func get_dir_path() -> String:
	return "user://subjects/" + str(id).lpad(10, '0')

func get_file_path() -> String:
	return "user://subjects/" + str(id).lpad(10, '0') + ".tres"

func get_image_mediaset() -> Mediaset:
	if image_mediaset_id <= 0:
		return null
	return ResourceLoader.load("user://mediasets/" + str(image_mediaset_id).lpad(10, "0") + ".tres")

func get_or_create_image_mediaset() -> Mediaset:
	var mediaset = get_image_mediaset()
	if mediaset != null:
		return mediaset
	mediaset = Mediaset.new()
	mediaset.create()
	image_mediaset_id = mediaset.id
	save()
	return mediaset

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
	update_experience()

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
	last_time_saved = Time.get_unix_time_from_system()
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)

func update_experience() -> void:
	var questions = get_questions()
	maximum_experience = questions.size() * 15 * 15
	if questions.is_empty():
		experience = 0.0
		level = 0
		save()
		return
	var xp:= 0.0
	for question in questions:
		xp += clampi(question.experience_level, 0, 15) * 15
	experience = xp
	level = get_experience_level()
	save()

func update_level() -> void:
	update_experience()

func get_experience_level() -> int:
	var questions_amount = size()
	if questions_amount <= 0:
		return 0
	var level_width = questions_amount * 15
	return clampi(floori(experience / level_width), 0, 15)

func get_experience_for_level(target_level: int) -> int:
	return clampi(target_level, 0, 15) * size() * 15

func get_experience_until_next_level() -> float:
	if level >= 15 || size() <= 0:
		return 0.0
	return max(0.0, get_experience_for_level(level + 1) - experience)

func get_level_progress() -> float:
	if level >= 15 || size() <= 0:
		return 1.0
	var current_level_experience = get_experience_for_level(level)
	var next_level_experience = get_experience_for_level(level + 1)
	return clampf((experience - current_level_experience) / float(next_level_experience - current_level_experience), 0.0, 1.0)

func has_questions_at_level(question_level: int) -> bool:
	for question in get_questions():
		if question.level == question_level:
			return true
	return false

func register_question_added() -> void:
	update_experience()
	save()

func next_question_id(should_save:= true) -> int:
	var value_to_return = 0
	if should_save:
		last_question_id += 1
		value_to_return = last_question_id
		save()
	else:
		value_to_return = last_question_id + 1
	return value_to_return
