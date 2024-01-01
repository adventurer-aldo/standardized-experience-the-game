extends TextEdit

var answers: Array = []

func _ready():
	User.finished.connect(correct)

func correct(strict := false):
	if answers.has(text):
		pass
	else:
		self_modulate = Color(Color.WHITE, 0)
		$Correction.show()
		var fin = text + "[color=red]" + answers.pick_random() + "[/color]"
		text = fin
		$Correction.text = fin
		$Correction.size = size
