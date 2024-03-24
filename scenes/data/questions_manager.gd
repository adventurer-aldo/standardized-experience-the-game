extends HBoxContainer

@export var answer_package: PackedScene

func _on_add_answer_button_pressed(text = ""):
	var new_answer = answer_package.instantiate()
	$Questions.add_child(new_answer)
	new_answer.delete_pressed.connect(_on_answer_delete_pressed)
	new_answer.set_text(text)
	new_answer.grab_text_focus()
	for child in $Questions.get_children():
		child.can_delete($Questions.get_child_count())


func _on_answer_delete_pressed(node: HBoxContainer):
	var count = $Questions.get_child_count()
	if count > 1:
		if find_prev_valid_focus(): 
			find_prev_valid_focus().grab_focus()
		elif find_next_valid_focus():
			find_next_valid_focus().grab_focus()
		node.queue_free()
	else:
		node.get_children()[0].text = ''
	for child in $Questions.get_children():
		child.can_delete(count - 1)


func _on_submit_pressed():
	for question in $Questions.get_children():
		question.clean()
	$Questions.get_children()[0].get_children()[0].grab_focus()
