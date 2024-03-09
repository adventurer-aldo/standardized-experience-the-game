extends VBoxContainer

@export var answer_open: PackedScene

func _on_add_pressed():
	var nodex = answer_open.instantiate()
	$AnswerBox/Answers.add_child(nodex)
	nodex.grab_first_focus()
