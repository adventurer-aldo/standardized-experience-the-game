@tool
extends Resource
class_name Mediaset

@export var id: int

@export var images: Array[ImageTexture]
@export var sounds: Array[AudioStream]
@export var videos: Array[VideoStream]

func get_file_path() -> String:
	var id_filename = str(id).lpad(10, '0') + '.tres'
	return "user://mediasets/" + id_filename

func create() -> void:
	id = Main.data.next_mediaset_id(true)
	save()

func add_image(image: ImageTexture) -> void:
	if !images.has(image):
		images.push_back(image)
		save()

func erase() -> void:
	DirAccess.remove_absolute(get_file_path())

func save() -> void:
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)
