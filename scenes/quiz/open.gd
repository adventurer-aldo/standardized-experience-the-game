extends TextEdit

var answers: Array = []

func _ready():
	User.finished.connect(correct)

func correct(_strict := false):
	if answers.has(text):
		pass
	else:
		# self_modulate = Color(Color.WHITE, 0)
		add_theme_color_override("font_color", Color.TRANSPARENT)
		$Correction.show()
		var chos = answers.pick_random()
		var fin = "[s]" + text + "[/s][color=red]" + chos + "[/color]"
		text += chos
		$Correction.text = fin
		$Correction.size = size
