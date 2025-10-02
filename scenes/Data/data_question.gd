extends Control

signal question_alt_changed

@export var question_packed_scene: PackedScene
@export var saved_question_packed_scene: PackedScene
@export var tag_packed_scene: PackedScene
@export var parent_packed_scene: PackedScene
var subject_id: int
var title = "Default Subject"
var question = Question.new()

func _ready() -> void:
	question.subject_id = subject_id
	$SubjectBar/Title.text = title
	_on_add_question_alt_pressed()
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Open.button_pressed = true
	_on_open_pressed()
	set_container()

func set_container() -> void:
	question.get_subject().get_questions().map(func (saved_question):
		add_question_to_container(saved_question)
	)

func add_question_to_container(saved_question: Question) -> void:
	var question_to_add = saved_question_packed_scene.instantiate()
	question_to_add.id = saved_question.id
	question_to_add.set_text(saved_question.question[0])
	question_to_add.name = str(saved_question.id)
	question_to_add.parent_pressed.connect(on_parent_pressed)
	$QuestionsContainer.add_child(question_to_add)
	$QuestionsContainer.move_child(question_to_add, 0)

func _on_add_question_alt_pressed() -> void:
	var q_scene = question_packed_scene.instantiate()
	$Items/ScrollData/Data/Question/Texts.add_child(q_scene)
	question_alt_changed.emit($Items/ScrollData/Data/Question/Texts.get_child_count() + 1)
	question_alt_changed.connect(q_scene.refresh)
	q_scene.delete_pressed.connect(_on_question_delete_pressed)
	# q_scene.tree_exited.connect(_on_question_delete_pressed)
	
func _on_question_delete_pressed() -> void:
	print("Alt changed")
	# await get_tree().create_timer(1).timeout
	question_alt_changed.emit($Items/ScrollData/Data/Question/Texts.get_child_count() - 1)

func _on_open_pressed() -> void:
	if question.get_types().size() == 1 && question.is_open: return
	question.is_open = !question.is_open
	$Items/ScrollData/Data/Opens.visible = question.is_open

func _on_choice_pressed() -> void:
	if question.get_types().size() == 1 && question.is_choice: return
	question.is_choice = !question.is_choice
	$Items/ScrollData/Data/Choices.visible = question.is_choice

func _on_match_pressed() -> void:
	if question.get_types().size() == 1 && question.is_connect: return
	question.is_connect = !question.is_connect
	$Items/ScrollData/Data/Match.visible = question.is_connect

func _on_table_pressed() -> void:
	if question.get_types().size() == 1 && question.is_table: return
	question.is_table = !question.is_table
	$Items/ScrollData/Data/Table.visible = question.is_table

func _on_label_pressed() -> void:
	if question.get_types().size() == 1 && question.is_label: return
	question.is_label = !question.is_label
	$Items/ScrollData/Data/Label.visible = question.is_label

func fetch_question_texts() -> PackedStringArray:
	var strings = $Items/ScrollData/Data/Question/Texts.get_children().map(func (question_row):
		return question_row.fetch()
	)
	return PackedStringArray(strings)

func _on_increase_level_pressed() -> void:
	question.level = [1, 2, 3, 4, 1][question.level]
	var tar = $Items/ScrollData/Data/Question/GloballyRelevant/IncreaseLevel/Elements/Text
	var texts = ['Beginner Level', 'Advanced Level', 'Dissertation', 'Master Level']
	tar.text = texts[question.level - 1]

func _on_add_tag_button_pressed() -> void:
	var text: String = $Items/ScrollData/Data/Tag/Text.text.strip_edges()
	if !question.tags.map(func (string: String): return string.to_lower()).has(text.to_lower):
		var tag_scene = tag_packed_scene.instantiate()
		tag_scene.set_text(text)
		tag_scene.delete_pressed.connect(delete_tag)
		$Items/ScrollData/Data/TagsContainer/TagsFlow.add_child(tag_scene)
		question.tags.push_back(text)
	$Items/ScrollData/Data/Tag/Text.text = ""

func delete_tag(text: String) -> void:
	question.tags.erase(text)

func on_parent_pressed(id: int) -> void:
	if question.parents.has(id):
		question.parents.erase(id)
		$Items/ScrollData/Data/ParentsContainer/ParentsFlow.get_node(str(id)).queue_free()
	else:
		question.parents.push_back(id)
		var parent_scene = parent_packed_scene.instantiate()
		parent_scene.delete_pressed.connect(on_parent_pressed)
		parent_scene.id = id
		$Items/ScrollData/Data/ParentsContainer/ParentsFlow.add_child(parent_scene)
		parent_scene.name = str(id)

func fetch_data() -> void:
	question.question = $Items/ScrollData/Data/Question/Texts.get_children().map(func (question): return question.fetch())
	question.created_at = Time.get_unix_time_from_system()
	question.last_time_edited = question.created_at
	question.answer = $Items/ScrollData/Data/Opens.fetch()
	question.choices = $Items/ScrollData/Data/Choices.fetch()
	question.columns = $Items/ScrollData/Data/Table.fetch()
	var matches = $Items/ScrollData/Data/Match.fetch()
	question.match_a = matches["a"]
	question.match_b = matches["b"]
	question.labels = $Items/ScrollData/Data/Label.fetch()

func _on_submit_pressed() -> void:
	$Voice.random_play("questions_1")
	fetch_data()
	question.create()
	add_question_to_container(question)
	$SFX.play_file("submit")
	$Items/ScrollData/Data/Question/Texts.get_children().map(func (child): child.reset())
	$Items/ScrollData/Data/Opens.reset()
