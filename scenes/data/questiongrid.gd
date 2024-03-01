extends GridContainer

func _ready():
	var arrs = DirAccess.get_files_at("user://subjects/6")
	arrs.resize(10)
	for i in arrs:
		var question = load("user://subjects/6/{file}".format({"file": i}))
		var don: PackedScene = load("res://scenes/data_question.tscn")
		var pon = don.instantiate()
		pon.questions = question.question
		pon.types = question.get_types()
		pon.tags = question.tags
		pon.level = question.level
		add_child(pon)
