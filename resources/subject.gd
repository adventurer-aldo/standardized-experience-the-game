@tool 
class_name Subject
extends Resource

@export var id := 0
@export var title := ""
@export var description := ""

@export_category("Experience")
@export var level := 0

func get_file_path() -> String:
	return "user://subjects/" + str(id).lpad(10, '0')

func create() -> void:
	id = Main.stats.next_subject_id()
	if !DirAccess.dir_exists_absolute(get_file_path()):
		DirAccess.make_dir_absolute(get_file_path())
	save()

func erase() -> void:
	DirAccess.remove_absolute(get_file_path())
	Resource

func get_questions() -> Array:
	var files = Array(DirAccess.get_files_at("user://subjects/" + str(id).lpad(10, '0')))
	return files.map(func (question_filename):
		return ResourceLoader.load("user://subjects/" + str(id).lpad(10, '0') + "/" + question_filename)
	)

func get_question(question_id: int) -> Question:
	return ResourceLoader.load("user://subjects/" + str(id).lpad(10, '0') + "/" + str(question_id).lpad(10, '0') + ".tres")

func save() -> void:
	ResourceSaver.save(self, get_file_path() + ".tres", ResourceSaver.FLAG_COMPRESS)
