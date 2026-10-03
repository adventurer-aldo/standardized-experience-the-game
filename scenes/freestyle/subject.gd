extends Panel

var subject_id:= 6

signal pressed(id: int)
signal focused(id: int)

func _ready() -> void:
	set_title(Main.data.get_subject(subject_id).title)

func _input(event: InputEvent) -> void:
	if has_focus():
		if event is InputEventKey:
			if Key.KEY_ENTER == event.key_label:
				_on_pressed()
		elif event is InputEventMouse:
			if event.button_mask == MouseButton.MOUSE_BUTTON_LEFT:
				_on_pressed()


func _on_focus_entered() -> void:
	$Focus.show()
	focused.emit(subject_id)

func _on_focus_exited() -> void:
	$Focus.hide()

func _on_mouse_entered() -> void:
	grab_focus()

func _on_pressed() -> void:
	pressed.emit(subject_id)

func set_title(from: String) -> void:
	Array(from.split(" ")).map(func (part: String): 
		$Label.text += part[0]
	)
