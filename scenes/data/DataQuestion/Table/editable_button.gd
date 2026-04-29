extends Button

signal pressed_cell(x, y)

func _on_pressed():
	pressed_cell.emit(get_parent().get_index(), get_index())
