extends Node

var data: Data
@onready var leveling_queue_manager = $LevelingQueueManager

func _ready() -> void:
	
	if FileAccess.file_exists("user://data.tres"):
		data = ResourceLoader.load("user://data.tres")
	else:
		data = Data.new()
	if !DirAccess.dir_exists_absolute("user://subjects"):
		DirAccess.make_dir_absolute("user://subjects")
	if !DirAccess.dir_exists_absolute("user://leveling_queues"):
		DirAccess.make_dir_absolute("user://leveling_queues")
	if !DirAccess.dir_exists_absolute("user://quizzes"):
		DirAccess.make_dir_absolute("user://quizzes")
