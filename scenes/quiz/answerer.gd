extends HBoxContainer

func setup(question_id: int, question_sample: int, type: String, choices: Array, _answer_id: int):
	if User.questions.has(question_id) == false: return
	var question = User.questions[question_id] as Dictionary
	if question.has("image"):
		var img = Image.new() as Image
		if question.image_format == 'jpg':
			img.load_jpg_from_buffer(question.image)
		elif question.image_format == 'png':
			img.load_png_from_buffer(question.image)
		$Ratio/Margin/VContent/Image.texture = ImageTexture.create_from_image(img)
	$Ratio/Margin/VContent/Question.text = question.question[question_sample]
	if ['open', 'formula'].has(type):
		var open_packed = load("res://scenes/quiz/open.tscn") as PackedScene
		for i in question.answers.size():
			var open = open_packed.instantiate()
			open.answers = question.answers
			$Ratio/Margin/VContent.add_child(open)
	elif type == 'veracity' || type == 'choice':
		var button_group = ButtonGroup.new()
		var cho = load("res://scenes/quiz/{type}.tscn".format({"type": type})) as PackedScene
		for i in choices:
			var new_choice = cho.instantiate()
			var text = question.choices[i][0] if typeof(i) == TYPE_INT else question.answers[int(i)]
			new_choice.value = text
			$Ratio/Margin/VContent/Choices.add_child(new_choice)
			if type == 'choice' && choices.filter(func n(k): return typeof(k) == TYPE_STRING).size() <= 1:
				new_choice.button_group = button_group

func _ready():
	$Info/Number.text = str(get_parent().get_children().find(self) + 1) + '. '
