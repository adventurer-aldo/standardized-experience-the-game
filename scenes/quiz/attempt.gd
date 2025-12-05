extends VBoxContainer

@export var attempt_row_scene: PackedScene
@export var id:= 0
@export var question_id:= 0
@export var question: Question
@export var edit_shortcut: PackedScene

signal add_to_might(value: int)

func set_description(text: String) -> void:
	$Description.text = str(question.attempt_index + 1) + ". " + text

func prepare(with_question: Question):
	question = with_question
	question_id = with_question.id
	if question.has_media(): 
		$Image.texture = question.get_mediaset().images[0]
	randomize()
	var questions = Array(with_question.question)
	questions.shuffle()
	set_description(questions[0])

func fetch() -> Array:
	var result = []
	for child in $OpensRow.get_children():
		result.push_back(child.fetch())
	return result

func edit() -> void:
	var edit_scene = edit_shortcut.instantiate()
	edit_scene.subject_id = question.subject_id
	add_child(edit_scene)
	edit_scene.on_edit_pressed(question.id)
