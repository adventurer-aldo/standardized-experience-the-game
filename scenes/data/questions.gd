extends Control

signal submitted(id: int)
@export var question_parent_node: PackedScene
@export var question_tag_node: PackedScene

var key = Global.stats.last_question_id

var question := [""]
var answers := [[""]]
var choices := [[]]
var types := ["open"]  # "open" is included by default
var parents := []
var tags := []
var level := 1
var subject := 1
var subject_name := ""

func _on_submit_pressed():
	var submitted_questions = get_tree().get_nodes_in_group("question").map(func i(node): return node.text)
	var submitted_answers = get_tree().get_nodes_in_group("answer").map(func i(node): return node.get_array(false))
	if submitted_questions.has(""): return
	if submitted_answers.map(func i(answ): return answ.has("")).has(true): return
	get_tree().get_nodes_in_group("answer").map(func i(node): node.delete())
	for ques in $Editables/QuestionDetails/Details/Components/QuestionsManager/Questions.get_children():
		ques.clean()
	var new_question = load("res://resources/question.tres")
	new_question.question = submitted_questions
	new_question.answers = submitted_answers
	new_question.choices = choices
	new_question.open = true
	new_question.parents = parents
	new_question.id = key
	new_question.level = level
	new_question.tags = tags
	new_question.subject_id = subject
	new_question.save()
	if key == Global.stats.last_question_id: 
		Global.stats.last_question_id += 1
		emit_signal("submitted", key)
	key = Global.stats.last_question_id
	Global.save_stats()
	$Editables/QuestionDetails/Details/Components/QuestionsManager/Questions.get_children()[0].grab_text_focus()

func _ready():
	$Editables/QuestionDetails/Details/Components/Exit/Margin/HBoxContainer/SubjectName.text = subject_name
	$Editables/ScrollContainer/GridContainer.subject_id = subject
	$Editables/ScrollContainer/GridContainer.load_questions()
	$Editables/QuestionDetails/Details/Components/QuestionsManager/Questions/Question/Text.grab_focus()
	Global.data_questions_delete_button_pressed.connect(_on_question_delete_pressed)
	Global.data_questions_edit_button_pressed.connect(_on_question_edit_pressed)
	Global.data_questions_parent_button_pressed.connect(_on_question_parent_pressed)

func _on_exit_pressed():
	queue_free()

func _on_question_parent_pressed(id):
	var par_id = parents.find(id)
	if par_id != -1:
		parents.remove_at(par_id)
		$Editables/QuestionDetails/Details/Components/Parents.get_children()[par_id].queue_free()
	else:
		parents.push_back(id)
		var pop = question_parent_node.instantiate()
		pop.set_text(str(id))
		$Editables/QuestionDetails/Details/Components/Parents.add_child(pop)
		pop.delete_pressed.connect(_on_question_parent_deleted)

func _on_tag_submit_pressed():
	add_tag($Editables/QuestionDetails/Details/Components/TagInput/Input.text)
	$Editables/QuestionDetails/Details/Components/TagInput/Input.text = ""

func add_tag(text: String):
	if text.strip_edges().length() < 1: return
	tags.push_back(text.to_lower())
	var tag = question_tag_node.instantiate()
	tag.set_text(text.to_lower())
	$Editables/QuestionDetails/Details/Components/Tags.add_child(tag)
	tag.delete_pressed.connect(_on_question_tag_deleted)

func _on_question_tag_deleted(tag_text):
	tags.erase(tag_text)

func _on_question_parent_deleted(tag_text):
	parents.erase(int(tag_text))

func _on_question_delete_pressed(resource: Resource):
	DirAccess.remove_absolute(resource.resource_path)

func _on_question_edit_pressed(resource):
	for i in $Editables/QuestionDetails/Details/Components/QuestionsManager/Questions.get_children():
		i.queue_free()
	for question_text in resource.question:
		$Editables/QuestionDetails/Details/Components/QuestionsManager._on_add_answer_button_pressed(question_text)
	for i in $Editables/QuestionDetails/Details/Components/AnswersManager/AnswerBox/Answers.get_children():
		i.queue_free()
	for answer in resource.answers:
		$Editables/QuestionDetails/Details/Components/AnswersManager._on_add_pressed(answer)
	for i in $Editables/QuestionDetails/Details/Components/Parents.get_children():
		i.queue_free()
	parents = []
	for i in $Editables/QuestionDetails/Details/Components/Tags.get_children():
		i.queue_free()
	for tag in resource.tags:
		add_tag(tag)
	tags = []
	key = resource.id


func _on_reset_pressed():
	for child in $Editables/QuestionDetails/Details/Components/QuestionsManager/Questions.get_children():
		if child.get_index() != 0:
			child.queue_free()
	for child in $Editables/QuestionDetails/Details/Components/AnswersManager/AnswerBox/Answers.get_children():
		if child.get_index() != 0: 
			child.queue_free()
		else:
			for alternative in child.get_alternatives_nodes():
				alternative.queue_free()

