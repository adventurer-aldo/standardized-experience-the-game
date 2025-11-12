extends VBoxContainer

@export var attempt_row_scene: PackedScene
@export var id:= 0
@export var question_id:= 0
@export var question: Question
@export var edit_shortcut: PackedScene

signal add_to_rush(value: int)

func _on_add_row_button_pressed() -> void:
	var new_child = attempt_row_scene.instantiate()
	$OpensRow.add_child(new_child)
	new_child.text_has_changed.connect(a_text_has_changed)
	new_child.get_focus()

func a_text_has_changed(difference: int) -> void:
	add_to_rush.emit(difference)

func set_description(text: String) -> void:
	$Description.text = str(get_index() + 1) + ". " + text

func prepare(with_question: Question):
	question = with_question
	question_id = with_question.id
	if question.media.size() > 0: $Image.texture = question.media[0]
	randomize()
	var questions = Array(with_question.question)
	questions.shuffle()
	set_description(questions[0])

func fetch() -> Array:
	var result = []
	for child in $OpensRow.get_children():
		result.push_back(child.fetch())
	return result

func replicate() -> void:
	randomize()
	var difference = question.answer.size() - $OpensRow.get_child_count()
	for remainder in difference:
		_on_add_row_button_pressed()
	for i in range(question.answer.size()):
		var ans = question.answer[i]["texts"].duplicate()
		ans.shuffle()
		$OpensRow.get_child(i).set_text(ans[0])
		# await get_tree().create_timer(10).timeout
		# $OpensRow.get_child(i).set_text("")

func map_array_to_lowercase(array: Array) -> Array:
	return array.map(func (element: String): return element.to_lower())

func map_string_to_lower(string: String) -> String:
	return string.to_lower()
	
func solve() -> bool:
	var res = false
	var attempts = fetch()
	var answers = question.answer.map(func (answer):
		var mapped = answer["texts"].map(map_string_to_lower)
		# print(answer)
		# print(mapped)
		var a = attempts.map(map_string_to_lower).map(func (attempt): return mapped.has(attempt))
		# print(a)
		return a.has(true)
	)
	# 	print(answers)
	if !answers.has(false): res = true
	# for attempt in fetch():
	# 	if question.answer[0].map(map_string_to_lower).has(attempt.to_lower()): res = true
	if res:
		$Right.show()
		$Wrong.hide()
		question.get_subject().get_question(question.id).hit()
	else:
		replicate()
		$Right.hide()
		$Wrong.show()
		question.get_subject().get_question(question.id).miss()
	return res

func edit() -> void:
	var edit_scene = edit_shortcut.instantiate()
	edit_scene.subject_id = question.subject_id
	add_child(edit_scene)
	edit_scene.on_edit_pressed(question.id)
