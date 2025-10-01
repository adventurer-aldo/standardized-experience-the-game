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
	if !DirAccess.dir_exists_absolute(get_file_path()):
		DirAccess.make_dir_absolute(get_file_path())
	save()

func save() -> void:
	ResourceSaver.save(self, get_file_path() + ".tres", ResourceSaver.FLAG_COMPRESS)
