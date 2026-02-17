extends Panel

signal subject_was_focused(subject_id: int)

@export var data_question_scene: PackedScene

@onready var title = $M/Elements/Quick/MTitle/M/Name/Title
@onready var description = $M/Elements/MTitle/VBox/Description
var subject_id: int

func _input(event: InputEvent) -> void:
	if has_focus():
		if event is InputEventKey:
			if event.key_label == Key.KEY_ENTER:
				_on_subject_pressed()
		elif event is InputEventMouse:
			if event.button_mask == MouseButton.MOUSE_BUTTON_LEFT:
				_on_subject_pressed()

func set_title(to: String) -> void:
	$M/Elements/Quick/MTitle/M/Name/Title.text = to

func set_description(to: String) -> void:
	$M/Elements/MTitle/VBox/Description.text = to

func set_level(to: int) -> void:
	$M/Elements/Quick/Level.text = "Lv. " + str(to)

func set_questions_size(to: int) -> void:
	var res:= str(to) + " Question"
	if to != 1: res+= "s"
	$M/Elements/MTitle/VBox/Details/Questions.text = res

func set_progress(maximum: int, value: int):
	$M/Elements/MTitle/VBox/Details/Outline/Experience.max_value = maximum
	$M/Elements/MTitle/VBox/Details/Outline/Experience.value = value

func _on_subject_pressed() -> void:
	var question_scene = data_question_scene.instantiate()
	question_scene.subject_id = subject_id
	question_scene.title = $M/Elements/Quick/MTitle/M/Name/Title.text
	add_child(question_scene)

func _on_selected_focus_entered() -> void:
	$Selected.show()
	subject_was_focused.emit(subject_id)

func _on_selected_focus_exited() -> void:
	$Selected.hide()

func _on_selected_mouse_entered() -> void:
	grab_focus()
