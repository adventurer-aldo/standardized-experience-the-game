extends HBoxContainer

@export var answer_package: PackedScene

func _on_add_answer_button_pressed():
	var new_answer = answer_package.instantiate()
	$Questions.add_child(new_answer)
	new_answer.delete_pressed.connect(_on_answer_delete_pressed)
	
	

func _on_answer_delete_pressed(node: HBoxContainer):
	if $Questions.get_child_count() > 1:
		node.queue_free()
	else:
		node.get_children()[0].text = ''


func _on_submit_pressed():
	for question in $Questions.get_children():
		question.clean()
