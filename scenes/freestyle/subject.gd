extends Panel

var subject_id:= 6

signal pressed

func _ready() -> void:
	set_title(Main.data.get_subject(subject_id).title)

func _input(event: InputEvent) -> void:
	if has_focus():
		if event is InputEventKey:
			if Key.KEY_ENTER == event.key_label:
				pressed.emit()
		elif event is InputEventMouse:
			if event.button_mask == MouseButton.MOUSE_BUTTON_LEFT:
				pressed.emit()


func _on_focus_entered() -> void:
	$Focus.show()

func _on_focus_exited() -> void:
	$Focus.hide()

func _on_mouse_entered() -> void:
	grab_focus()

func _on_pressed() -> void:
	var new_quiz = Quiz.new()
	new_quiz.id = Main.data.next_quiz_id()
	new_quiz.subject_id = subject_id
	new_quiz.create()
	new_quiz.generate()
	get_tree().change_scene_to_file("res://scenes/quiz/quiz.tscn")

func set_title(from: String) -> void:
	Array(from.split(" ")).map(func (part: String): 
		$Label.text += part[0]
	)
