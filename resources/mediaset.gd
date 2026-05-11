@tool
extends Resource
class_name Mediaset

@export var id: int

@export var images: Array[Texture2D]
@export var sounds: Array[AudioStream]
@export var videos: Array[VideoStream]

func get_file_path() -> String:
	var id_filename = str(id).lpad(10, '0') + '.tres'
	return "user://mediasets/" + id_filename

func create() -> void:
	id = Main.data.next_mediaset_id(true)
	save()

func add_image(image: Texture2D) -> Dictionary:
	return _add_media("image", image)

func add_sound(sound: AudioStream) -> Dictionary:
	return _add_media("sound", sound)

func add_video(video: VideoStream) -> Dictionary:
	return _add_media("video", video)

func get_media(ref: Dictionary):
	var media_type = str(ref.get("type", ""))
	var index = int(ref.get("index", -1))
	match media_type:
		"image":
			return images[index] if index >= 0 && index < images.size() else null
		"sound":
			return sounds[index] if index >= 0 && index < sounds.size() else null
		"video":
			return videos[index] if index >= 0 && index < videos.size() else null
	return null

func _add_media(media_type: String, media) -> Dictionary:
	if media == null:
		return {}
	var index:= -1
	match media_type:
		"image":
			index = images.find(media)
			if index < 0:
				images.push_back(media)
				index = images.size() - 1
				save()
			return {"type": media_type, "index": index}
		"sound":
			index = sounds.find(media)
			if index < 0:
				sounds.push_back(media)
				index = sounds.size() - 1
				save()
			return {"type": media_type, "index": index}
		"video":
			index = videos.find(media)
			if index < 0:
				videos.push_back(media)
				index = videos.size() - 1
				save()
			return {"type": media_type, "index": index}
	return {}

func erase() -> void:
	DirAccess.remove_absolute(get_file_path())

func save() -> void:
	ResourceSaver.save(self, get_file_path(), ResourceSaver.FLAG_COMPRESS)
