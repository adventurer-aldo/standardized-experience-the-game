extends Label

func _ready() -> void:
	var last_quiz = Main.data.get_last_quiz()
	var title = last_quiz.get_subject().title
	text = "Your last quiz was of " + title + " with the grade..."
