extends Control

signal question_alt_changed

@export var question_packed_scene: PackedScene
@export var tag_packed_scene: PackedScene
var subject_id: int
var title = "Default Subject"
var question = Question.new()

func _ready() -> void:
	question.subject_id = subject_id
	$SubjectBar/Title.text = title
	_on_add_question_alt_pressed()
	$Items/Data/Types/M/VBoxContainer/Types/Open.button_pressed = true
	_on_open_pressed()

func _on_add_question_alt_pressed() -> void:
	var q_scene = question_packed_scene.instantiate()
	$Items/Data/Question/Texts.add_child(q_scene)
	question_alt_changed.emit($Items/Data/Question/Texts.get_child_count() + 1)
	question_alt_changed.connect(q_scene.refresh)
	q_scene.delete_pressed.connect(_on_question_delete_pressed)
	# q_scene.tree_exited.connect(_on_question_delete_pressed)
	
func _on_question_delete_pressed() -> void:
	print("Alt changed")
	# await get_tree().create_timer(1).timeout
	question_alt_changed.emit($Items/Data/Question/Texts.get_child_count() - 1)

func _on_open_pressed() -> void:
	question.is_open = !question.is_open
	$Items/Data/Opens.visible = question.is_open

func _on_choice_pressed() -> void:
	question.is_choice = !question.is_choice
	$Items/Data/Choices.visible = question.is_choice

func _on_match_pressed() -> void:
	question.is_connect = !question.is_connect
	$Items/Data/Match.visible = question.is_connect

func _on_table_pressed() -> void:
	question.is_table = !question.is_table
	$Items/Data/Table.visible = question.is_table

func _on_label_pressed() -> void:
	question.is_label = !question.is_label

func fetch_question_texts() -> PackedStringArray:
	var strings = $Items/Data/Question/Texts.get_children().map(func (question_row):
		return question_row.fetch()
	)
	return PackedStringArray(strings)

func _on_submit_pressed() -> void:
	$Voice.random_play("questions_1")
	# print(fetch_question_texts())
	# print($Items/Data/Opens.fetch())
	# print($Items/Data/Choices.fetch())
	# print($Items/Data/Match.fetch())
	print($Items/Data/Table.fetch())


func _on_increase_level_pressed() -> void:
	question.level = [1, 2, 3, 4, 1][question.level]
	var tar = $Items/Data/Question/GloballyRelevant/IncreaseLevel/Elements/Text
	var texts = ['Beginner Level', 'Advanced Level', 'Dissertation', 'Master Level']
	tar.text = texts[question.level - 1]


func _on_add_tag_button_pressed() -> void:
	var text: String = $Items/Data/Tag/Text.text.strip_edges()
	if !question.tags.map(func (string: String): return string.to_lower()).has(text.to_lower):
		var tag_scene = tag_packed_scene.instantiate()
		tag_scene.set_text(text)
		tag_scene.delete_pressed.connect(delete_tag)
		$Items/Data/TagsContainer/TagsFlow.add_child(tag_scene)
		question.tags.push_back(text)
	$Items/Data/Tag/Text.text = ""

func delete_tag(text: String) -> void:
	question.tags.erase(text)

func _on_button_pressed() -> void:
	print(question.subject_id)
