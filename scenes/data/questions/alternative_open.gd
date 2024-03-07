extends HBoxContainer

signal de

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
	queue_free()

func clean():
	$Text.text = ""
	text = ""

func _on_text_text_changed():
	text = $Text.text
