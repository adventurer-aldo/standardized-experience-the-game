extends TextEdit

var last_style = load("res://scenes/questions/alt_question_last.tres")
var regular_style = load("res://scenes/questions/alt_question.tres")

func _ready() -> void:
	texture_by_pos()

func texture_by_pos():
	if get_parent().get_children().find(self) == get_parent().get_children().size() - 1:
		add_theme_stylebox_override("normal", last_style)
	else:
		add_theme_stylebox_override("normal", regular_style)
