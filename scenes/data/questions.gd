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
var hits := 0
var misses := 0
var hit_streak := 0
var miss_streak := 0
var spaced_level := 1
var subject := 1
var subject_name := ""

func _ready():
	print("Checking questions for ID %s - %s" % [subject, subject_name])
	SFX.speak("you_want_to_create_new_questions")
	$Editables/QuestionDetails/Details/Components/Exit/Margin/HBoxContainer/SubjectName.text = subject_name
	$Editables/ScrollContainer/GridContainer.subject_id = subject
	$Editables/ScrollContainer/GridContainer.load_questions()
	$Editables/QuestionDetails/Details/Components/QuestionsManager/Questions/Question/Text.grab_focus()
	Global.data_questions_delete_button_pressed.connect(_on_question_delete_pressed)
	Global.data_questions_edit_button_pressed.connect(_on_question_edit_pressed)
	Global.data_questions_parent_button_pressed.connect(_on_question_parent_pressed)

func _on_level_pressed() -> void:
	$Editables/QuestionDetails/Details/Components/Level.text = ["1st Test", "2nd Test", "Dissertation", "Exam", "1st Test"][level]
	level = [1, 2, 3, 4, 1][level]

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
	new_question.hits = hits
	new_question.hit_streak = hit_streak
	new_question.misses = misses
	new_question.miss_streak = miss_streak
	new_question.spaced_level = spaced_level
	new_question.save()
	if key == Global.stats.last_question_id: 
		Global.stats.last_question_id += 1
		emit_signal("submitted", key)
		SFX.effect("submitted_question")
	else:
		unedit()
	key = Global.stats.last_question_id
	hits = 0
	hit_streak = 0
	misses = 0
	miss_streak = 0
	spaced_level = 1
	Global.save_stats()
	Global.emit_signal("data_questions_question_was_submitted", new_question)
	$Editables/QuestionDetails/Details/Components/QuestionsManager/Questions.get_children()[0].grab_text_focus()

func _on_exit_pressed():
	queue_free()

func unedit():
	$StateAnims.play("editing_to_normal")
	$Editables/QuestionDetails/Details/Components/Submit/Margin/Label.text = "Create New Question"

func _on_question_parent_pressed(id):
	if id == key: return
	if parents.has(id):
		parents.erase(id)
		for child in $Editables/QuestionDetails/Details/Components/Parents.get_children():
			if child.tagtext == str(id): child.queue_free()
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

func add_parent(text: String):
	if text.strip_edges().length() < 1: return
	tags.push_back(text.to_lower())
	var parent = question_parent_node.instantiate()
	parent.set_text(text.to_lower())
	$Editables/QuestionDetails/Details/Components/Tags.add_child(parent)
	parent.delete_pressed.connect(_on_question_parent_deleted)

func _on_question_tag_deleted(tag_text):
	tags.erase(tag_text)

func _on_question_parent_deleted(tag_text):
	parents.erase(int(tag_text))

func _on_question_delete_pressed(resource: Resource):
	DirAccess.remove_absolute(resource.resource_path)

func _on_question_edit_pressed(resource: Question):
	if resource.id == key:
		unedit()
		_on_reset_pressed()
		return
	if key != Global.stats.last_question_id:
		$StateAnims.play("editing")
	$Editables/QuestionDetails/Details/Components/Submit/Margin/Label.text = "Editing Question " + str(resource.id)
	for i in $Editables/QuestionDetails/Details/Components/QuestionsManager/Questions.get_children():
		i.queue_free()
	for question_text in resource.question:
		$Editables/QuestionDetails/Details/Components/QuestionsManager._on_add_answer_button_pressed(question_text)
	for i in $Editables/QuestionDetails/Details/Components/AnswersManager/AnswerBox/Answers.get_children():
		i.queue_free()
	for answer in resource.answers:
		$Editables/QuestionDetails/Details/Components/AnswersManager._on_add_pressed(answer)
	for i in $Editables/QuestionDetails/Details/Components/Tags.get_children():
		i.queue_free()
	tags = []
	for tag in resource.tags:
		add_tag(tag)
	key = resource.id
	hits = resource.hits
	hit_streak = resource.hit_streak
	misses = resource.misses
	miss_streak = resource.miss_streak
	spaced_level = resource.spaced_level
	$Editables/QuestionDetails/Details/Components/Level.text = ["1st Test", "2nd Test", "Dissertation", "Exam", "1st Test"][resource.level -1]
	level = resource.level
	SFX.speak(Text.questions_edit.pick_random())

func _on_reset_pressed():
	unedit()
	key = Global.stats.last_question_id
	for child in $Editables/QuestionDetails/Details/Components/QuestionsManager/Questions.get_children():
		if child.get_index() != 0:
			child.queue_free()
		else:
			child.set_text("")
	for child in $Editables/QuestionDetails/Details/Components/AnswersManager/AnswerBox/Answers.get_children():
		if child.get_index() != 0: 
			child.queue_free()
		else:
			child.set_text("")
			for alternative in child.get_alternatives_nodes():
				alternative.queue_free()
