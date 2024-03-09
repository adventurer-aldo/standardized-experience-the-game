extends TextEdit

var answers: Array = []
var id := 1

func _ready():
	Global.finished.connect(correct)

func correct(_strict := false):
	if answers.map(func i(alternatives_array): return alternatives_array.has(text)).has(true):
		pass
	else:
		# self_modulate = Color(Color.WHITE, 0)
		add_theme_color_override("font_color", Color.TRANSPARENT)
		$Correction.show()
		var chos
		if typeof(answers[id - 1]) == TYPE_ARRAY:
			chos = answers[id - 1].pick_random()
		else:
			chos = answers.pick_random()
		var fin = "[s]" + text + "[/s][color=red]" + chos + "[/color]"
		text += chos
		$Correction.text = fin
		$Correction.size = size
