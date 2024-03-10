extends Control

signal submitted(id: int)

var key_match := {}

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
	Global.stats.last_question_id += 1
	var key = Global.stats.last_question_id
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
	Global.save_stats()
	new_question.save()
	$Editables/QuestionDetails/Details/Components/QuestionsManager/Questions.get_children()[0].grab_text_focus()
	# ResourceSaver.save(new_question, "user://subjects/{subj}/{id}.res".format({"subj": new_question.subject_id, "id": key}), ResourceSaver.FLAG_COMPRESS)
	# vResourceSaver.save(new_question, "res://" + str(key) + ".res")
	emit_signal("submitted", key)

func _ready():
	$Editables/QuestionDetails/Details/Components/Exit/Margin/HBoxContainer/SubjectName.text = subject_name
	$Editables/ScrollContainer/GridContainer.subject_id = subject
	$Editables/ScrollContainer/GridContainer.load_questions()
	$Editables/QuestionDetails/Details/Components/QuestionsManager/Questions/Question/Text.grab_focus()

func _on_grid_container_parent_pressed(id):
	var par_id = parents.find(id)
	if par_id != -1:
		parents.remove_at(par_id)
		$Editables/QuestionDetails/Details/Components/Parents.get_children()[par_id].queue_free()
	else:
		parents.push_back(id)
		var pap = load("res://scenes/data/tag.tscn") as PackedScene
		var pop = pap.instantiate()
		pop.text = str(id)
		$Editables/QuestionDetails/Details/Components/Parents.add_child(pop)

func _on_exit_pressed():
	queue_free()

func _on_grid_container_delete_pressed(resource: Resource):
	DirAccess.remove_absolute(resource.resource_path)

func _on_grid_container_edit_pressed(resource):
	for i in $Editables/QuestionDetails/Details/Components/QuestionsManager/Questions.get_children():
		i.queue_free()
	for i in $Editables/QuestionDetails/Details/Components/AnswersManager/AnswerBox/Answers.get_children():
		i.queue_free()
	
	for question in resource.question:
		var non = load("res://scenes/data/questions/question.tscn").instantiate()
		non.get_children()[0].text = question


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
