extends ColorRect

@export var main_scene: PackedScene
signal subjects_completed
signal questions_completed
signal deletions_completed
var base = "https://standardized-experience-cloud.adventureraldo.workers.dev"
var append = "?last_sync_time={sync}"

func _ready() -> void:
	var fin_append = append.format({"sync": Main.data.last_sync_time})
	$SubjectRequest.request(base + "/api/subjects/" + fin_append, [], HTTPClient.METHOD_GET)
	await subjects_completed
	$QuestionRequest.request(base + "/api/questions/" + fin_append, [], HTTPClient.METHOD_GET)
	await questions_completed
	$DeleteRequest.request(base + "/api/deletions/" + fin_append, [], HTTPClient.METHOD_GET)
	await deletions_completed
	Main.sync()
	$EmblemAnim.play("splash")
	await get_tree().create_timer(0.7).timeout
	$BGM.play()
	await get_tree().create_timer(2.0).timeout
	$Voice.random_play("welcome")
	await $Voice.finished
	Main.wipe_in()
	await Main.wipe_finished
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(main_scene)


func _on_subject_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == 0:
		print(body.get_string_from_utf8())
		var subject_dicts = JSON.parse_string(body.get_string_from_utf8())
		for dict in subject_dicts:
			var subject_data = Subject.new()
			subject_data.absorb_dictionary(dict)
			subject_data.save(false)
		subjects_completed.emit()


func _on_question_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == 0:
		var question_dicts = JSON.parse_string(body.get_string_from_utf8())
		for dict in question_dicts:
			var question_data = Question.new()
			question_data.absorb_dictionary(dict)
			question_data.save(false)
		questions_completed.emit()


func _on_delete_request_request_completed(result: int, _r, _h, body: PackedByteArray) -> void:
	if result == 0:
		var deletion_dicts = JSON.parse_string(body.get_string_from_utf8())
		for deletion in deletion_dicts:
			if Main.data.get_subject(deletion["subject_id"]):
				var subject = Main.data.get_subject(deletion["subject_id"])
				subject.erase_question(deletion["question_id"], false)
		deletions_completed.emit()
