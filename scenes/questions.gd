extends Control

@export var question_scene: PackedScene
@export var subject_id: int
@export var box: PackedScene

var image: Image
var level := 1

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
	new_question.image = image
	new_question.question = $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question.get_all_strings()
	new_question.answers = []
	for answer in $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_children():
		new_question.answers.push_back(answer.get_all_strings())
	for choice in $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Choices.get_children():
		new_question.choices.push_back({"texts": choice.get_all_strings(), "veracity": false})
	for answer in new_question.answers:
		new_question.choices.push_back({"texts": answer, "veracity": true})
	new_question.level = level
	new_question.tags = []
	new_question.parents = parents
	new_question.open = !($NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Choices.get_child_count() > 0)
	new_question.choice = $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Choices.get_child_count() > 0
	Global.stats.last_question_id += 1
	Global.save_stats()
	new_question.id = Global.stats.last_question_id
	new_question.subject_id = subject_id
	var new_node = add_question_to_stack(new_question)
	$QuestionsPart/Scroller/GridContainer.move_child(new_node, 0)
	var subj = new_question.get_subject()
	subj.last_time_edited = Time.get_unix_time_from_system()
	subj.maximum_experience = float(DirAccess.get_files_at("user://subjects/" + str(subj.id)).size()) * 10.0
	subj.save()
	var line = question_milestone_voice()
	if line != null: SFX.speak(question_milestone_voice())
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question/Editables/MainElement/Text.grab_focus()
	# $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question/Editables/MainElement/Text.grab_focus()
	
	
	new_question.save()
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question.clean()
	for node in $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_children():
		node.clean()
	for node in $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Choices.get_children():
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
		if find_prev_valid_focus(): 
			find_prev_valid_focus().grab_focus()
		elif find_next_valid_focus():
			find_next_valid_focus().grab_focus()
		$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_child(index).queue_free()

func _on_texture_button_pressed() -> void:
	queue_free()

func _on_reset_pressed() -> void:
	for question_box in get_tree().get_nodes_in_group("question_box"):
		question_box.reset()
	for answer in $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Answers.get_children():
		if answer.get_index() != 0: answer.queue_free()
	for choice in $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Choices.get_children():
		choice.queue_free()
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Question/Editables/MainElement/Text.grab_focus()

func _on_image_button_pressed() -> void:
	image = DisplayServer.clipboard_get_image()
	if image != null:
		var imgtexture = ImageTexture.create_from_image(image)
		$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Image.texture = imgtexture
	else:
		$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Image.texture = null

func choice_add_pressed(index: int) -> void:
	var new_choice = box.instantiate()
	new_choice.data_type = 2
	new_choice.add_pressed.connect(choice_add_pressed)
	new_choice.delete_pressed.connect(choice_delete_pressed)
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Choices.add_child(new_choice)
	new_choice.grab_text_focus()

func choice_delete_pressed(index: int) -> void:
	if find_prev_valid_focus(): 
		find_prev_valid_focus().grab_focus()
	elif find_next_valid_focus():
		find_next_valid_focus().grab_focus()
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Choices.get_children()[index].queue_free()

func _on_choice_pressed() -> void:
	if $NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/Choices.get_child_count() < 1:
		choice_add_pressed(0)

func _on_veracity_pressed() -> void:
	pass # Replace with function body.
	
	
	

func _on_increase_level_pressed() -> void:
	level = [1, 2, 4, 0 , 1][level]
	$NewQuestionPart/ScrollContainer/Margin/HBoxes/Details/LevelStuff/Level.text = str(level)


func question_milestone_voice():
	match $QuestionsPart/Scroller/GridContainer.get_child_count():
		1: return "1_question"
		5: return "5_questions"
		25: return "25_questions"
		50: return "50_questions"
		75: return "75_questions"
		100: return "100_questions"
		125: return "125_questions"
		150: return "150_questions"
		175: return "175_questions"
		200: return "200_questions"
		225: return "225_questions"
		250: return "250_questions"
		275: return "275_questions"
		300: return "300_questions"
		325: return "325_questions"
		350: return "350_questions"
		375: return "375_questions"
		400: return "400_questions"
		425: return "425_questions"
		450: return "450_questions"
		475: return "475_questions"
		500: return "500_questions"
		525: return "525_questions"
		550: return "550_questions"
		575: return "575_questions"
		600: return "600_questions"
		625: return "625_questions"
		650: return "650_questions"
		675: return "675_questions"
		700: return "700_questions"
		725: return "725_questions"
		750: return "750_questions"
		775: return "775_questions"
		800: return "800_questions"
		825: return "825_questions"
		850: return "850_questions"
		875: return "875_questions"
		900: return "900_questions"
		925: return "925_questions"
		950: return "950_questions"
		975: return "975_questions"
		1000: return "1000_questions"
