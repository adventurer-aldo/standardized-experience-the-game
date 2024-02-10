extends Panel

var question: String = ''
var answers: Array = []
var subject: String = ""
var types: Array = ["open"]
var has_image: bool = false

func setup():
	$Question.text = question
	var ans_text = answers[0]
	if answers.size() > 1:
		ans_text += ("\n" + answers[1])
		if answers.size() > 2:
			ans_text += "\n..."
	$Answer.text = ans_text
	$Subject.text = subject
	$Types/MainType.text = types[0]
	if types.size() > 1:
		for type in types.slice(1, -1):
			var pep = $Types/MainType.duplicate()
			pep.text = type
			$Types.add_child(pep)
	if has_image == false: 
		$ImgIcon.hide()
	else: 
		$ImgIcon.show()
