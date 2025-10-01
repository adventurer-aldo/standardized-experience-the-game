extends HBoxContainer

signal delete_pressed

func _ready() -> void:
	refresh(get_parent().get_child_count())

func refresh(amount) -> void:
	print(amount)
	if amount > 1:
		$DeleteButton.show()
	else:
		$DeleteButton.hide()


func _on_delete_button_pressed() -> void:
	queue_free()
	delete_pressed.emit()

func fetch() -> String:
	return $Text.text
