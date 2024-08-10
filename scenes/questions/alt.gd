extends HBoxContainer

var last_style = load("res://scenes/questions/alt_last.tres")
var regular_style = load("res://scenes/questions/alt.tres")
var last_delete = load("res://scenes/questions/alt_delete_last.tres")
var regular_delete = load("res://scenes/questions/alt_delete.tres")

func _ready() -> void:
	texture_by_pos()

func texture_by_pos():
	if get_parent().get_children().find(self) == get_parent().get_children().size() - 1:
		$Alt.add_theme_stylebox_override("normal", last_style)
	else:
		$Alt.add_theme_stylebox_override("normal", regular_style)
