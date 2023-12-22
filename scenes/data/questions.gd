extends Control

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
	var key = (User.questions.keys()[-1] || -1) + 1
	User.questions[key] = {
		'question': question,
		'answers': answers,
		'choices': choices,
		'types': types,
		'tags': tags,
		'level': level,
		'subject': subject
	}

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
	if User.subjects.size() < 1:
		get_tree().change_scene_to_file("res://scenes/data/subjects.tscn")
		return
	for i in User.subjects.keys():
		$Scroller/Components/Subject.add_item(User.subjects[i].title)
	_on_subject_item_selected($Scroller/Components/Subject.selected)

