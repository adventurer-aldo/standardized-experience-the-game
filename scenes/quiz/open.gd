extends TextEdit

var answers: Array = []
var id := 1
@onready var prev_text = text # For m

func _ready():
	pass # Global.finished.connect(correct)

func correct(_strict := false):
	if answers.map(func i(alternatives_array): 
		return alternatives_array.map(func i(k): 
			return k.to_lower()).has(text.to_lower())
		).has(true):
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


func _on_text_changed():
	if text.length() > prev_text.length():
		BGM.pump_might(0.5)
	elif text.length() < prev_text.length():
		BGM.pump_might(-0.5)
	prev_text = text
