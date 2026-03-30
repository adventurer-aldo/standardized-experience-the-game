extends Panel

signal bookmark_pressed(to: bool)

func _input(event: InputEvent) -> void:
	if has_focus():
		if event is InputEventKey:
			if event.key_label == Key.KEY_ENTER:
				print("Did the thing")
				on_bookmark_pressed()
		elif event is InputEventMouse:
			if event.button_mask == MouseButton.MOUSE_BUTTON_LEFT:
				print("Did the thing")
				on_bookmark_pressed()

func on_bookmark_pressed() -> void:
	if $Filler.visible:
		$Filler.hide()
		bookmark_pressed.emit(false)
	else:
		$Filler.show()
		bookmark_pressed.emit(true)

func _on_mouse_entered() -> void:
	grab_focus()

func _on_mouse_exited() -> void:
	release_focus()
