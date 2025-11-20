extends Control

var thread = Thread.new()
var data: Data

signal wipe_finished
signal update_finished

func _ready() -> void:
	if FileAccess.file_exists("user://data.tres"):
		data = ResourceLoader.load("user://data.tres")
	else:
		data = Data.new()
	if !DirAccess.dir_exists_absolute("user://mediasets"):
		DirAccess.make_dir_absolute("user://mediasets")
	if !DirAccess.dir_exists_absolute("user://subjects"):
		DirAccess.make_dir_absolute("user://subjects")
	if !DirAccess.dir_exists_absolute("user://leveling_queues"):
		DirAccess.make_dir_absolute("user://leveling_queues")
	if !DirAccess.dir_exists_absolute("user://quizzes"):
		DirAccess.make_dir_absolute("user://quizzes")

func begin_update() -> void:
	thread.start(update)

func update() -> bool:
	var files = DirAccess.get_files_at("user://leveling_queues")
	for file in files:
		var queue: LevelingQueue
		var file_path = "user://leveling_queues/" + file
		queue = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_REPLACE)
		if queue.process_leveling(): 
			print(str(queue.id) + " has finished SR wait time.")
	update_finished.emit()
	if files.size() > 0:
		return true
	else:
		return false

func wipe_in(to_color:= Color('ffb600')) -> void:
	$WipeAnim.play("wipe_in")
	await $WipeAnim.animation_finished
	var new_tween = get_tree().create_tween()
	new_tween.tween_property($LoadingWipe, 'color', to_color, 1.0)
	await new_tween.finished
	wipe_finished.emit()

func wipe_out() -> void:
	$WipeAnim.play("wipe_out")
	await $WipeAnim.animation_finished
	wipe_finished.emit()
