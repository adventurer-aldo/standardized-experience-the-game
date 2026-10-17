extends ColorRect


var level:= 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.wipe_out()

func change_level(to: int) -> void:
	level = to

func _on_subjects_container_subject_pressed(id: int) -> void:
	var quiz = Quiz.new()
	quiz.id = Main.data.next_quiz_id()
	quiz.subject_id = id
	quiz.level = level
	quiz.create()
	quiz.generate()
	quiz.save()
	get_tree().change_scene_to_file("res://scenes/mobile/quiz_mobile.tscn")
