extends Node

var thread = Thread.new()

func update() -> void:
	for file in DirAccess.get_files_at("user://leveling_queues"):
		var queue: LevelingQueue
		var file_path = "user://leveling_queues/" + file
		queue = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_REPLACE)
		if queue.process_leveling(): print(str(queue.id) + " has finished SR wait time.")

func _ready() -> void:
	thread.start(update)
