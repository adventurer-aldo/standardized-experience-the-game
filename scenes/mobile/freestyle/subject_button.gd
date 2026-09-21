extends Button

@export var subject_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var subject = Main.data.get_subject(subject_id)
	if subject:
		var initials = Array(subject.title.split(' ')).map(func (word: String): return word[0])
		$Abbreviation.text = ''.join(PackedStringArray(initials))

func _on_pressed() -> void:
	var quiz = Quiz.new()
	quiz.id = Main.data.next_quiz_id()
	quiz.subject_id = subject_id
	quiz.level = 1
	quiz.create()
	quiz.generate()
	quiz.save()
	get_tree().change_scene_to_file("res://scenes/mobile/quiz_mobile.tscn")
