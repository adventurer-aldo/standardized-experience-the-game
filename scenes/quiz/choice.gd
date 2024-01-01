extends MarginContainer

var alphabet = 'abcdefghijklmnopqrstuvwxyz'
var index: int = 0
var value: String = "a"
var answer: int = 0
var button_group: ButtonGroup = ButtonGroup.new()

func _ready():
	index = get_parent().get_children().find(self)
	$HBoxContainer/Alternative.text = alphabet[index] + ') '
	$HBoxContainer/Value.text = value
	$HBoxContainer/Value.button_group = button_group

func _on_value_pressed():
	answer = [1, 2, 0][answer]
	$HBoxContainer/Value/Checkbox/Answer.text = ['', 'V', 'F'][answer]
