extends MarginContainer

@export var question := ""
@export var spaced_level := 1
@export var level := 1

var normal_panel = load("res://themes/questionpanel_normal.tres")
var focus_panel = load("res://themes/questionpanel_focusl.tres")
var levels = ["1st Test", "2nd Test", "Coursework", "Exam"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$QuestionButton/Panel/Text.text = question
	$QuestionButton/Actions/Container/Levels/SRLevel/SRLabelMargin/HBoxContainer/SRLabel.text = "SR" + str(spaced_level).pad_zeros(2)
	$QuestionButton/Actions/Container/Levels/Level/MarginContainer/HBoxContainer/Label.text = levels[level - 1]

func _on_parent_button_pressed() -> void:
	pass # Replace with function body.


func _on_child_button_pressed() -> void:
	pass # Replace with function body.


func _on_sibling_button_pressed() -> void:
	pass # Replace with function body.


func _on_delete_button_pressed() -> void:
	pass

func _on_question_button_focus_entered() -> void:
	$QuestionButton/Panel.add_theme_stylebox_override("panel", focus_panel)
	$QuestionButton/Panel/Text.add_theme_color_override("font_color", Color.WHITE)

func _on_question_button_focus_exited() -> void:
	$QuestionButton/Panel.add_theme_stylebox_override("panel", normal_panel)
	$QuestionButton/Panel/Text.add_theme_color_override("font_color", Color.BLACK)
