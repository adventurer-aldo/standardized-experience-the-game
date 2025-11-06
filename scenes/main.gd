extends Panel

@export var quiz_scene: PackedScene
@export var practice_subject: PackedScene
@export var data_subject_scene: PackedScene

func subject_pressed(id: int) -> void:
	var quiz = Quiz.new()
	quiz.id = Main.data.next_quiz_id()
	quiz.subject_id = id
	quiz.create()
	quiz.generate()
	get_tree().change_scene_to_packed(quiz_scene)

func _ready() -> void:
	for subject in Main.data.get_subjects():
		var new = practice_subject.instantiate()
		new.subject_id = subject.id
		new.set_title(subject.title)
		new.subject_pressed.connect(subject_pressed)
		$Practice/GridContainer.add_child(new)


func _on_subjects_pressed() -> void:
	add_child(data_subject_scene.instantiate())
