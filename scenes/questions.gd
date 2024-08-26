extends Control

@export var question_scene: PackedScene
@export var subject_id: int
@export var box: PackedScene

@export var parent_scene: PackedScene
var parents = []

func _ready() -> void:
	# return
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question/Editables/MainElement/Text.grab_focus()
	var questions = Global.get_subject(subject_id).get_questions()
	questions.reverse()
	for question in questions:
		add_question_to_stack(question)

func add_question_to_stack(question: Question) -> MarginContainer:
	var new_question = question_scene.instantiate()
	new_question.name = str(question.id)
	new_question.id = question.id
	new_question.question = question.question[0]
	new_question.level = question.level
	new_question.spaced_level = question.spaced_level
	$QuestionsPart/Scroller/GridContainer.add_child(new_question)
	
	new_question.parent_pressed.connect(parent_pressed)
	return new_question

func focus_on_question(id: int):
	print("HEY")
	if $QuestionsPart/Scroller/GridContainer.has_node(str(id)):
		$QuestionsPart/Scroller/GridContainer
		get_node("QuestionsPart/Scroller/GridContainer/" + str(id)).grab_focus()

func parent_pressed(id: int):
	if parents.has(id):
		parents.erase(id)
		get_node("NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/M/Parents/" + str(id)).queue_free()
	else:
		var new_parent = parent_scene.instantiate()
		new_parent.id = id
		new_parent.name = str(id)
		
		new_parent.delete_pressed.connect(parent_pressed)
		new_parent.parent_pressed.connect(focus_on_question)
		$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/M/Parents.add_child(new_parent)
		parents.push_back(id)

func _on_submit_button_pressed() -> void:
	SFX.effect("create_question")
	var new_question = Question.new()
	new_question.question = $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question.get_all_strings()
	new_question.answers = []
	for answer in $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_children():
		new_question.answers.push_back(answer.get_all_strings())
	new_question.level = 1
	new_question.tags = []
	new_question.parents = parents
	new_question.open = true
	Global.stats.last_question_id += 1
	Global.save_stats()
	new_question.id = Global.stats.last_question_id
	new_question.subject_id = subject_id
	var new_node = add_question_to_stack(new_question)
	$QuestionsPart/Scroller/GridContainer.move_child(new_node, 0)
	var subj = new_question.get_subject()
	subj.last_time_edited = Time.get_unix_time_from_system()
	subj.save()
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question/Editables/MainElement/Text.grab_focus()
	# $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question/Editables/MainElement/Text.grab_focus()
	
	
	new_question.save()
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question.clean()
	for node in $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_children():
		node.clean()

func answer_add_pressed(index: int) -> void:
	var new_ans = box.instantiate()
	new_ans.data_type = 1
	new_ans.add_pressed.connect(answer_add_pressed)
	new_ans.delete_pressed.connect(_on_answer_delete_pressed)
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_child(index).add_sibling(new_ans)
	new_ans.grab_text_focus()

func _on_answer_delete_pressed(index: int) -> void:
	if $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_child_count() > 1:
		$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_child(index).queue_free()

func _on_texture_button_pressed() -> void:
	queue_free()

func _on_reset_pressed() -> void:
	for question_box in get_tree().get_nodes_in_group("question_box"):
		question_box.reset()
	for answer in $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_children():
		if answer.get_index() != 0: answer.queue_free()
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question/Editables/MainElement/Text.grab_focus()
