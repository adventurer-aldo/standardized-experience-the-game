extends HBoxContainer

signal add_pressed(index: int)
signal delete_pressed(index: int)

@export_enum("Question", "Answer", "Choice") var data_type: int
var alt = load("res://scenes/questions/alt.tscn") as PackedScene

func _ready() -> void:
	match data_type:
		0:
			var question_style = load("res://scenes/questions/box_question.tres")
			var first_delete = load("res://scenes/questions/alt_delete_first.tres")
			$AddSiblingQuestion.hide()
			# $Editables/MainElement/Text.add_theme_stylebox_override("normal", question_style)
			$Editables/MainElement/Delete.add_theme_stylebox_override("normal", first_delete)
			$Editables/MainElement/Delete.reparent(self)
			
			$Editables/MainElement/Text.placeholder_text = "What will be the question?"
		1:
			$AddAlt/M/Icon.texture = load("res://graphics/icons/a.svg")
			
			$Editables/MainElement/Text.placeholder_text = "What will be an answer?"
		2:
			$AddAlt/M/Icon.texture = load("res://graphics/icons/c.svg")
			
			var textbox_delete = load("res://scenes/questions/question_box_text_delete.tres")
			$Editables/MainElement/Text.add_theme_stylebox_override("normal", textbox_delete)
			$Editables/MainElement/Text.placeholder_text = "What will be a decoy answer?"

func _on_add_sibling_pressed() -> void:
	add_pressed.emit(get_index())

func _on_alt_button_pressed() -> void:
	var new_alt = alt.instantiate()
	match data_type:
		1:
			new_alt.placeholder_text = "What is an alternative for that answer?"
		2:
			new_alt.placeholder_text = "What is an alternative for that choice?"
	$Editables/Alternatives.add_child(new_alt)
	new_alt.grab_text_focus()
	for alt_thing in get_tree().get_nodes_in_group("alt"):
		alt_thing.texture_by_pos()

func _on_delete_pressed() -> void:
	$Editables/MainElement/Text.text = ""
	delete_pressed.emit(get_index())

func reset() -> void:
	$Editables/MainElement/Text.text = ""
	for child in $Editables/Alternatives.get_children():
		child.queue_free()

func clean():
	$Editables/MainElement/Text.text = ""
	for child in $Editables/Alternatives.get_children():
		child.clean()

func get_alts() -> Array:
	var arr = []
	for alte in $Editables/Alternatives.get_children():
		arr.push_back(alte.text)
	return arr

func get_all_strings() -> Array:
	return [$Editables/MainElement/Text.text] + get_alts()

func get_first_string() -> String:
	return $Editables/MainElement/Text.text

func grab_text_focus() -> void:
	$Editables/MainElement/Text.grab_focus()
