extends Control

var thread = Thread.new()
var data: Data
@onready var http:= $HTTPRequest
@onready var subject_http:= $SubjectHTTP
@onready var question_http:= $QuestionHTTP

signal wipe_finished
signal update_finished
signal signal_sync

func _ready() -> void:
	if FileAccess.file_exists("user://data.tres"):
		data = ResourceLoader.load("user://data.tres")
	else:
		data = Data.new()
		data.save()
	if !DirAccess.dir_exists_absolute("user://journeys"):
		DirAccess.make_dir_absolute("user://journeys")
	if !DirAccess.dir_exists_absolute("user://mediasets"):
		DirAccess.make_dir_absolute("user://mediasets")
	if !DirAccess.dir_exists_absolute("user://subjects"):
		DirAccess.make_dir_absolute("user://subjects")
	if !DirAccess.dir_exists_absolute("user://leveling_queues"):
		DirAccess.make_dir_absolute("user://leveling_queues")
	if !DirAccess.dir_exists_absolute("user://quizzes"):
		DirAccess.make_dir_absolute("user://quizzes")
	begin_update()
	for subject in data.get_subjects():
		subject.maximum_experience = subject.size() * 15
		subject.update_experience()

func begin_update() -> void:
	thread.start(update)

func sync() -> void:
	$HTTPRequest.request("https://standardized-experience-cloud.adventureraldo.workers.dev/api/sync/", [], HTTPClient.METHOD_POST)

func update() -> bool:
	var files = DirAccess.get_files_at("user://leveling_queues")
	var to_post:= []
	for file in files:
		var queue: LevelingQueue
		var file_path = "user://leveling_queues/" + file
		queue = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_REPLACE)
		if queue.process_leveling(): 
			print(str(queue.id) + " has finished SR wait time.")
			to_post.push_back(queue.get_question().get_dictionary())
	if to_post.size() > 0:
		print("Size of questions to post: ", to_post, "\n", to_post)
		Main.post_questions(to_post)
	call_deferred("emit_signal", "update_finished")
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

func _on_update_finished() -> void:
	thread.wait_to_finish()
	print("Thread finished...?")
	thread = Thread.new()


func rank_grade(grade: float) -> String:
	if grade >= 19.9:
		return 's'
	elif grade >= 14.5:
		return 'a'
	elif grade >= 12.0:
		return 'b'
	elif grade >= 9.5:
		return 'c'
	elif grade >= 8.0:
		return 'd'
	elif grade >= 5.0:
		return 'e'
	elif grade >= 0.1:
		return 'f'
	else:
		return 'g'

func post_questions(questions: Array) -> void:
	$QuestionHTTP.request("https://standardized-experience-cloud.adventureraldo.workers.dev/api/question/", ["Content-type: application/json"], HTTPClient.METHOD_POST,
			JSON.stringify(questions))

func _on_http_request_request_completed(_result: int, _response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if headers.has("Content-Type: application/json"):
		var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		if json.has("time"):
			data.last_sync_time = json["time"]
			data.save()


func _on_question_http_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("After querying question server on autoload: ", body.get_string_from_utf8())
