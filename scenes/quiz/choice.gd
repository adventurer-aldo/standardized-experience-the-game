extends MarginContainer

var alphabet = 'abcdefghijklmnopqrstuvwxyz'
var index: int = 0
var value: String = "a"
var answer: int = 0
var button_group: ButtonGroup = ButtonGroup.new()
var is_correct = false
var relevant = false
var grade := 0.0
var pressed := false

var answers = []

func _ready():
	index = get_parent().get_children().find(self)
	$HBoxContainer/Alternative.text = alphabet[index] + ') '
	$HBoxContainer/Value.text = value
	$HBoxContainer/Value/Button.button_group = button_group
	Global.finished.connect(correct)

func _on_value_pressed():
	answer = [1, 2, 0][answer]
	$HBoxContainer/Value/Checkbox/Answer.text = ['', 'V', 'F'][answer]

func correct():
	$HBoxContainer/Value/Button.disabled = true
	if $HBoxContainer/Value/Button.button_pressed == true:
		relevant = true
		if answers.has(value):
			$HBoxContainer/Value/Button.modulate = Color.GREEN
			$HBoxContainer/Value.add_theme_color_override("default_color", Color(0, 0.1, 0))
			is_correct = true
			Global.emit_signal("grade", grade)
		else:
			$HBoxContainer/Value/Button.modulate = Color.RED
			$HBoxContainer/Value.add_theme_color_override("default_color", Color(0.1, 0, 0))
	elif answers.has(value):
		$HBoxContainer/Value/Button.modulate = Color.ORANGE


func _on_button_pressed():
	pressed = $HBoxContainer/Value/Button.button_pressed
