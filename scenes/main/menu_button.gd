extends MarginContainer

signal pressed

func _input(event: InputEvent) -> void:
	if has_focus():
		if event is InputEventKey:
			if Key.KEY_ENTER == event.key_label:
				pressed.emit()
		elif event is InputEventMouse:
			if event.button_mask == MouseButton.MOUSE_BUTTON_LEFT:
				pressed.emit()

func _on_mouse_entered() -> void:
	grab_focus()

func _on_focus_entered() -> void:
	$Anims.play("focused")
	$Texts/Label/Icon.show()
	$Texts/MDesc.show()

func _on_focus_exited() -> void:
	$Anims.play("RESET")
	$Texts/Label/Icon.hide()
	$Texts/MDesc.hide()

func _on_anims_animation_finished(anim_name: StringName) -> void:
	if anim_name == "focused":
		$Anims.play("focused")
