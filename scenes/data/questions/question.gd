extends HBoxContainer

signal delete_pressed

func _on_delete_pressed():
	if find_prev_valid_focus(): 
		find_prev_valid_focus().grab_focus()
	elif find_next_valid_focus():
		find_next_valid_focus().grab_focus()
	emit_signal("delete_pressed", self)

func grab_text_focus():
	$Text.grab_focus()

func set_text(text: String = ""):
	$Text.text = text

func can_delete(count: int):
	if count > 1: 
		$Delete.show()
	else:
		$Delete.hide()

func clean():
	$Text.text = ""
