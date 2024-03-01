extends MarginContainer

# Called when the node enters the scene tree for the first time.
func setup(title: String = "", questions: int = 0, color: Color = Color.BLACK):
	var a = title.replace("(", " ").replace(")", "").replace("  ", " ")
	var tit = "".join(PackedStringArray(Array(a.split(" ")).map(func i(str): return str[0])))
	$SubjectElements/Title.text = tit
	$SubjectElements/FullTitleContainer/FullTitleMargin/FullTitle.text = title
	$SubjectElements/Title/QuestionNumber.text = str(questions)
	$BackgroundColor.self_modulate = color
