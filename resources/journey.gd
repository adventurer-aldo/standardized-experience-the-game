@tool
extends Resource
class_name Journey

@export var id: int
@export var start_time: float
@export var end_time: float
@export var progress: int

func create() -> void:
	DirAccess.make_dir_recursive_absolute(get_dir_path())
	save()

func save() -> void:
	ResourceSaver.save(self, get_file_path())

func get_dir_path() -> String:
	return "user://journeys/" + str(id).lpad(10, '0' + '/')

func get_file_path() -> String:
	return "user://journeys/" + str(id).lpad(10, '0') + ".tres"

func get_chairs() -> Array[Chair]:
	var ret: Array[Chair]
	for chair_filename in DirAccess.get_files_at(get_dir_path()):
		ret.push_back(ResourceLoader.load(get_dir_path() + chair_filename))
	return ret
