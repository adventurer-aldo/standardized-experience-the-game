extends MarginContainer

var alphabet = 'abcdefghijklmnopqrstuvwxyz'
var index: int
var value: String
var button_group: ButtonGroup

func _ready():
	index = get_parent().get_children().find(self)
	$HBoxContainer/Alternative.text = alphabet[index] + ') '
	$HBoxContainer/Value.text = value
	$HBoxContainer/Value.button_group = button_group
