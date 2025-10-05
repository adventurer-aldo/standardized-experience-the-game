extends Button

@export var data_question_scene: PackedScene
var subject_id: int

func set_title(to: String) -> void:
	text = to

func _on_subject_pressed() -> void:
	var question_scene = data_question_scene.instantiate()
	question_scene.subject_id = subject_id
	question_scene.title = text
	add_child(question_scene)
