extends VBoxContainer

signal button_toggled

var current_choice: String

func _on_button_toggled(button_pressed):
	if button_pressed == true:
		current_choice = get_children().filter(pressed_child)[0].text

func pressed_child(child: Button):
	return child.button_pressed == true
