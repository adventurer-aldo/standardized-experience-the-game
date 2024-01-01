extends GridContainer

func _ready():
	var arrs = User.questions.keys()
	arrs.resize(6)
	for i in arrs:
		var question = User.questions[i]
		var don: PackedScene = load("res://scenes/data/questions/question_panel.tscn")
		var pon = don.instantiate()
		pon.question = question.question[0]
		pon.answers = question.answers
		pon.types = question.types
		pon.subject = User.subjects[int(question.subject_id)].title
		pon.has_image = question.has("image")
		pon.setup()
		add_child(pon)
