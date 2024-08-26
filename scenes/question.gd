extends MarginContainer

signal parent_pressed(id: int)
signal child_pressed(id: int)
signal sibling_pressed(id: int)

@export var question := ""
@export var spaced_level := 1
@export var level := 1
var id := 0

var normal_panel = load("res://themes/questionpanel_normal.tres")
var focus_panel = load("res://themes/questionpanel_focusl.tres")
var levels = ["1st Test", "2nd Test", "Coursework", "Exam"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Elements/QuestionButton/Panel/Text.text = question
	$Elements/Actions/Container/Levels/SRLevel/SRLabelMargin/HBoxContainer/SRLabel.text = "SR" + str(spaced_level).pad_zeros(2)
	$Elements/Actions/Container/Levels/Level/MarginContainer/HBoxContainer/Label.text = levels[level - 1]

func _on_parent_button_pressed() -> void:
	parent_pressed.emit(id)

func _on_child_button_pressed() -> void:
	child_pressed.emit(id)

func _on_sibling_button_pressed() -> void:
	sibling_pressed.emit(id)

func _on_delete_button_pressed() -> void:
	pass

func _on_question_button_focus_entered() -> void:
	$Elements/QuestionButton/Panel.add_theme_stylebox_override("panel", focus_panel)
	$Elements/QuestionButton/Panel/Text.add_theme_color_override("font_color", Color.WHITE)

func _on_question_button_focus_exited() -> void:
	$Elements/QuestionButton/Panel.add_theme_stylebox_override("panel", normal_panel)
	$Elements/QuestionButton/Panel/Text.add_theme_color_override("font_color", Color.BLACK)
