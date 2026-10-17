extends ColorRect

signal ping_completed
signal subjects_completed
signal questions_completed

var local:= true
var base = "http://localhost:5173"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PingRequest.request("http://localhost:5173/")
	await ping_completed
	# var base = "http://localhost:5173" if local else "https://standardized-experience-cloud.adventureraldo.workers.dev"
	print("Doing it locally" if local else "Doing it serverwise")
	questions()
	await $HTTPRequest.request_completed
	#questions()
	#await $HTTPRequest.request_completed
	$Button.show()
	return
	$SubjectRequest.request(base + "/api/subjects/", [], HTTPClient.METHOD_GET)
	await subjects_completed
	$QuestionRequest.request(base + "/api/questions/", [], HTTPClient.METHOD_GET)
	await questions_completed


func questions() -> void:
	for subject: Subject in Main.data.get_subjects():
		var questions_arr: Array
		$Button.hide()
		for question in subject.get_questions():
			questions_arr.push_back(question.get_dictionary())
		$HTTPRequest.request(base + "/api/question/", ["Content-type: application/json"],HTTPClient.METHOD_POST, 
		JSON.stringify(questions_arr))
		await $HTTPRequest.request_completed

func subjects() -> void:
	var subjects_arr: Array
	for subject: Subject in Main.data.get_subjects():
		subjects_arr.push_back(subject.get_dictionary())
	$HTTPRequest.request(base + "/api/subject/", ["Content-type: application/json"], HTTPClient.METHOD_POST,
	JSON.stringify(subjects_arr))
	
func _on_http_request_request_completed(_r, _re, _h, body: PackedByteArray) -> void:
	$Button.show()


func _on_ping_request_request_completed(result: int, _r: int, _h, _body: PackedByteArray) -> void:
	if result != 0: 
		local = false
		base = "https://standardized-experience-cloud.adventureraldo.workers.dev"
	ping_completed.emit()


func _on_subject_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == 0:
		var subject_dicts = JSON.parse_string(body.get_string_from_utf8())
		for dict in subject_dicts:
			var subject_data = Subject.new()
			subject_data.absorb_dictionary(dict)
			subject_data.save()
		subjects_completed.emit()


func _on_question_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == 0:
		var question_dicts = JSON.parse_string(body.get_string_from_utf8())
		for dict in question_dicts:
			var question_data = Question.new()
			question_data.absorb_dictionary(dict)
			question_data.save()
		questions_completed.emit()
