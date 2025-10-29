extends VBoxContainer

@export var attempt_row_scene: PackedScene
@export var id:= 0
@export var question_id:= 0
@export var question: Question

func _on_add_row_button_pressed() -> void:
	$OpensRow.add_child(attempt_row_scene.instantiate())

func set_description(text: String) -> void:
	$Description.text = text

func prepare(with_question: Question):
	question = with_question
	question_id = with_question.id
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
	var ans = question.answer[0].duplicate()
	ans.shuffle()
	$OpensRow.get_child(0).set_text(ans[0])
	await get_tree().create_timer(10).timeout
	$OpensRow.get_child(0).set_text("")
	# var difference = question.answer.size() - $OpensRow.get_child_count())
		
func solve() -> bool:
	var res = false
	for attempt in fetch():
		if question.answer[0].has(attempt): res = true
	if res:
		$Right.show()
		$Wrong.hide()
	else:
		replicate()
		$Right.hide()
		$Wrong.show()
	return res
