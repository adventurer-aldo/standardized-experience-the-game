extends ColorRect

var quiz = Quiz.new()

@export var open_attempt: PackedScene

func _ready() -> void:
	hey()
	for question in quiz.get_questions():
		var new_attempt = open_attempt.instantiate()
		new_attempt.prepare(question)
		$ScrollContainer/AttemptsContainer.add_child(new_attempt)

func hey():
	quiz.id = Main.data.next_quiz_id()
	quiz.subject_id = 6
	quiz.create()
	quiz.generate()


func _on_button_pressed() -> void:
	for child in $ScrollContainer/AttemptsContainer.get_children():
		child.solve()
