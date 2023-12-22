extends HBoxContainer

func setup(question_id: int, question_sample: int, type: String, choices: Array, _answer_id: int):
	if User.questions.has(question_id) == false: return
	var question = User.questions[question_id]
	$Ratio/Margin/VContent/Question.text = question.question[question_sample]
	if ['open', 'formula'].has(type):
		var open = load("res://scenes/quiz/open.tscn") as PackedScene
		for i in question.answers.size():
			$Ratio/Margin/VContent.add_child(open.instantiate())
	elif type == 'veracity':
		var ver = load("res://scenes/quiz/choice.tscn") as PackedScene
		var chos = question.answers + question.choices
		for i in chos:
			$Ratio/Margin/VContent/Choices.add_child(chos.instan)
	elif !['open', 'formula'].has(type):
		$Ratio/Margin/VContent/Open.hide()
		var button_group = ButtonGroup.new()
		for i in choices:
			var cho = load("res://scenes/quiz/choice.tscn") as PackedScene
			var new_choice = cho.instantiate()
			var text = question.choices[i][0] if typeof(i) == TYPE_INT else question.answers[int(i)]
			new_choice.value = text
			$Ratio/Margin/VContent/Choices.add_child(new_choice)
			if choices.filter(func n(k): return typeof(k) == TYPE_STRING).size() <= 1:
				new_choice.button_group = button_group

func _ready():
	$Info/Number.text = str(get_parent().get_children().find(self) + 1) + '. '
