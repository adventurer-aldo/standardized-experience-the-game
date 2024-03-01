extends Control

var key_match := {}

var question := [""]
var answers := [[""]]
var choices := [[]]
var types := ["open"]  # "open" is included by default
var tags := []
var level := 1
var subject := 1

func _on_answer_input_text_changed():
	answers[0] = $AnswerInput.text

func _on_submit_pressed():
	User.stats.last_question_id += 1
	var key = User.stats.last_question_id
	var new_question = load("res://resources/question.tres")
	new_question.question = get_tree().get_nodes_in_group("question").map(func i(node): return node.text)
	new_question.answers = get_tree().get_nodes_in_group("answer").map(func i(node): return node.get_array())
	new_question.choices = choices
	new_question.open = true
	new_question.level = level
	new_question.tags = tags
	new_question.subject_id = key_match[$Scroller/Components/Subject.get_item_text($Scroller/Components/Subject.selected)]
	User.save_stats()
	ResourceSaver.save(new_question, "user://subjects/{subj}/{id}.res".format({"subj": new_question.subject_id, "id": key}), ResourceSaver.FLAG_COMPRESS)

func _on_subject_item_selected(index):
	for i in User.subjects.keys():
		if User.subjects[i].title == $Scroller/Components/Subject.get_item_text(index):
			subject = i

func _on_open_pressed():
	if types.size() > 1 || !types.has("open"):
		if types.has("open"):
			types.erase("open")
			$OpenButton.modulate = Color(1, 1, 1)  # Change Open button color back to white
		else:
			types.append("open")
			$OpenButton.modulate = Color(0.5, 0.5, 0.5)  # Change Open button color to gray

func _on_list_pressed():
	if types.size() > 1 || !types.has("list"):
		if types.has("list"):
			types.erase("list")
			$ListButton.modulate = Color(1, 1, 1)  # Change List button color back to white
		else:
			types.append("list")
			$ListButton.modulate = Color(0.5, 0.5, 0.5)  # Change List button color to gray

func tmp(n): 
	return User.questions[n].hits == 0

func _ready():
	print(User.subjects)
	if User.subjects.size() < 1:
		# get_tree().change_scene_to_file("res://scenes/data/subjects.tscn")
		return
	for i in User.subjects.keys():
		$Scroller/Components/Subject.add_item(User.subjects[i].title)
		key_match[User.subjects[i].title] = i
	_on_subject_item_selected($Scroller/Components/Subject.selected)

func _on_button_pressed():
	queue_free()
