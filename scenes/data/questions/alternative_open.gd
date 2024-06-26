extends HBoxContainer

var order = 1
var text = ""

func get_order():
	var par_child = get_parent().get_children()
	for i in par_child.size():
		if par_child[i - 1] == self: order = i
	if order == 0:
		$Lister.texture = load("res://scenes/data/questions/alternative_lister_last.png")
	else:
		$Lister.texture = load("res://scenes/data/questions/alternative_lister.png")

func _on_delete_pressed():
	if find_prev_valid_focus(): 
		find_prev_valid_focus().grab_focus()
	elif find_next_valid_focus():
		find_next_valid_focus().grab_focus()
	queue_free()

func set_text(gtext = ""):
	$Text.text = gtext
	text = gtext

func grab_text_focus():
	$Text.grab_focus()

func clean():
	$Text.text = ""
	text = ""

func _on_text_text_changed():
	text = $Text.text
