extends VBoxContainer

signal alternatives_modified

@export var alternative_scene: PackedScene

func _on_add_pressed(text = ""):
	var new_alternative = alternative_scene.instantiate()
	$Alternatives.add_child(new_alternative)
	new_alternative.set_text(text)
	alternatives_modified.connect(new_alternative.get_order)
	new_alternative.tree_exiting.connect(ab)
	emit_signal("alternatives_modified")
	new_alternative.grab_text_focus()

func ab():
	emit_signal("alternatives_modified")

func get_array(delete_afterwards := true):
	var arr = [$Main/Text.text]
	for alternative in $Alternatives.get_children():
		arr.push_back(alternative.text)
		if delete_afterwards == true:
			alternative.clean()
	if delete_afterwards == true:
		$Main/Text.text = ""
	return arr

func get_alternatives_nodes():
	return $Alternatives.get_children()

func delete():
	for alternative in $Alternatives.get_children():
		alternative.clean()
	$Main/Text.text = ""

func grab_first_focus():
	$Main/Text.grab_focus()

func set_text(text = ""):
	$Main/Text.text = text

func _on_delete_pressed():
	if get_parent().get_child_count() > 1:
		if find_prev_valid_focus(): 
			find_prev_valid_focus().grab_focus()
		elif find_next_valid_focus():
			find_next_valid_focus().grab_focus()
		queue_free()
