extends HBoxContainer

var grade := 0.0
var answer_index = 0
var answer: Answer

func map_to_lower(string: String):
	return string.to_lower()

func correct():
	$MarginContainer/VBoxContainer/EditButton.show()
	grade = answer.grade
	var question = answer.get_question()
	if question.image != null:
		$Ratio/Margin/VContent/Image.texture = ImageTexture.create_from_image(question.image)
	$Ratio/Margin/VContent/Question.text = question.question[answer.question_sample]
	var stored_answers = question.answers
	if ['open', 'formula', 'caption'].has(answer.type):
		var wrongs = []
		var is_correct_array = []
		randomize()
		stored_answers.shuffle()
		for ans in stored_answers:
			if !answer.intersects(ans.map(map_to_lower), answer.attempt.map(map_to_lower)):
				wrongs.push_back(ans)
		is_correct_array = answer.attempt.map(func i(att): return stored_answers.map(func k(ans): return answer.intersects(ans.map(map_to_lower), [att.to_lower()])).has(true))
		var open_packed = load("res://scenes/quiz/open_correct.tscn") as PackedScene
		var wrong_count = 0
		for i in range(answer.attempt.size()):
			var open = open_packed.instantiate()
			if is_correct_array[i] == false:
				open.text = "[s]" + answer.attempt[i] + "[/s][color=RED]" + wrongs[wrong_count].pick_random() + "[/color]"
				wrong_count += 1
			else:
				open.text = answer.attempt[i]
			$Ratio/Margin/VContent/Opens.add_child(open)
	elif answer.type == 'veracity' || answer.type == 'choice':
		var button_group = ButtonGroup.new()
		var cho = load("res://scenes/quiz/{type}.tscn".format({"type": answer.type})) as PackedScene
		for i in answer.choice_indexes:
			var new_choice = cho.instantiate()
			var whole_answer = []
			for answere in question.answers:
				whole_answer += Array(answere)
			new_choice.answers = whole_answer
			var text = question.choices[i].texts[0]
			new_choice.value = text
			$Ratio/Margin/VContent/Choices.add_child(new_choice)
			new_choice.grade = grade
			if answer.type == 'choice' && answer.choice_indexes.filter(func n(k): return typeof(k) == TYPE_STRING).size() <= 1:
				new_choice.button_group = button_group

func setup():
	grade = answer.grade
	var question = answer.get_question()
	if question.image != null:
		$Ratio/Margin/VContent/Image.texture = ImageTexture.create_from_image(question.image)
	$Ratio/Margin/VContent/Question.text = question.question[answer.question_sample]
	if ['open', 'formula', 'caption'].has(answer.type):
		var open_packed = load("res://scenes/quiz/open.tscn") as PackedScene
		for i in question.answers.size():
			var open = open_packed.instantiate()
			open.answers = question.answers
			open.id = i
			$Ratio/Margin/VContent/Opens.add_child(open)
	elif answer.type == 'veracity' || answer.type == 'choice':
		var button_group = ButtonGroup.new()
		var cho = load("res://scenes/quiz/{type}.tscn".format({"type": answer.type})) as PackedScene
		for i in answer.choice_indexes:
			var new_choice = cho.instantiate()
			var whole_answer = []
			for answere in question.answers:
				whole_answer += Array(answere)
			new_choice.answers = whole_answer
			var text = question.choices[i].texts[0]
			new_choice.value = text
			$Ratio/Margin/VContent/Choices.add_child(new_choice)
			new_choice.grade = grade
			if answer.type == 'choice' && answer.choice_indexes.filter(func n(k): return typeof(k) == TYPE_STRING).size() <= 1:
				new_choice.button_group = button_group

func respond():
	var response = []
	match answer.type:
		"open", "caption", "formula":
			for open in $Ratio/Margin/VContent/Opens.get_children():
				response.push_back(open.text)
		"choice", "veracity":
			for choice in $Ratio/Margin/VContent/Choices.get_children():
				if choice.pressed: response.push_back(choice.value)
	answer.respond(response)

func _ready():
	$MarginContainer/VBoxContainer/Number.text = str(get_parent().get_children().find(self) + 1) + '. '

func _on_button_pressed() -> void:
	var pep = load("res://scenes/data/questions.tscn") as PackedScene
	var pop = pep.instantiate()
	pop.subject = answer.get_subject().id
	pop.subject_name = answer.get_subject().title
	add_child(pop)
	Global.emit_signal("data_questions_edit_button_pressed", answer.get_question())
