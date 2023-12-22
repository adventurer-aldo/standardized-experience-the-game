extends VBoxContainer

@export var answer_open: PackedScene


var answers := [[""]]
var choices = [[]]
var types = ["open"]


func _on_add_pressed():
	answers.push_back([""])
	$AnswerBox/Answers.add_child(answer_open.instantiate())
