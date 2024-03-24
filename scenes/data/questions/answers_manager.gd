extends VBoxContainer

@export var answer_open: PackedScene

func _on_add_pressed(array = [""]):
	var nodex = answer_open.instantiate()
	$AnswerBox/Answers.add_child(nodex)
	var index = 0
	for answer in array:
		if index == 0: 
			nodex.set_text(answer)
			index += 1
		else:
			nodex._on_add_pressed(answer)
	nodex.grab_first_focus()
