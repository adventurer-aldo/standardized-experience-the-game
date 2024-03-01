extends HBoxContainer

var grade := 0.0

func setup(question_id: int, question_sample: int, type: String, choices: Array, subject_id: int):
	var question = ResourceLoader.load("user://subjects/{subj}/{q}.res".format({"subj": subject_id, "q": question_id}))
	if question.image != null:
		$Ratio/Margin/VContent/Image.texture = ImageTexture.create_from_image(question.image)
	$Ratio/Margin/VContent/Question.text = question.question[question_sample]
	if ['open', 'formula', 'caption'].has(type):
		var open_packed = load("res://scenes/quiz/open.tscn") as PackedScene
		for i in question.answers.size():
			var open = open_packed.instantiate()
			open.answers = question.answers
			print(open.answers)
			open.id = i
			$Ratio/Margin/VContent.add_child(open)
	elif type == 'veracity' || type == 'choice':
		var button_group = ButtonGroup.new()
		var cho = load("res://scenes/quiz/{type}.tscn".format({"type": type})) as PackedScene
		for i in choices:
			var new_choice = cho.instantiate()
			new_choice.answers = question.answers
			print(question.choices[i])
			var text = question.choices[i].texts[0]
			new_choice.value = text
			$Ratio/Margin/VContent/Choices.add_child(new_choice)
			new_choice.grade = grade
			if type == 'choice' && choices.filter(func n(k): return typeof(k) == TYPE_STRING).size() <= 1:
				new_choice.button_group = button_group

func _ready():
	$Info/Number.text = str(get_parent().get_children().find(self) + 1) + '. '
