extends HBoxContainer

var last_style = load("res://scenes/questions/alt_last.tres")
var regular_style = load("res://scenes/questions/alt.tres")
var last_delete = load("res://scenes/questions/alt_delete_last.tres")
var regular_delete = load("res://scenes/questions/alt_delete.tres")

var placeholder_text = "A different phrasing for the question..."

var text = ""

func _ready() -> void:
	texture_by_pos()
	$Alt.placeholder_text = placeholder_text

func texture_by_pos():
	# print(get_parent().get_children().find(self), "--", get_parent().get_children().size())
	if get_index() == get_parent().get_children().size() - 1:
		$Alt.add_theme_stylebox_override("normal", last_style)
		$Delete.add_theme_stylebox_override("normal", last_delete)
	else:
		$Alt.add_theme_stylebox_override("normal", regular_style)
		$Delete.add_theme_stylebox_override("normal", regular_delete)

func clean():
	$Alt.text = ""
	text = ""

func _on_delete_pressed() -> void:
	queue_free()

func _on_alt_text_changed() -> void:
	text = $Alt.text

func grab_text_focus() -> void:
	$Alt.grab_focus()
