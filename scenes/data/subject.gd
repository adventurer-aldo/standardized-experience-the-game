extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func setup(title: String = "", questions: int = 0):
	var a = title.replace("(", " ").replace(")", "").replace("  ", " ")
	var tit = "".join(PackedStringArray(Array(a.split(" ")).map(func i(str): return str[0])))
	$BackgroundColor/Title.text = tit
	$FullTitleContainer/FullTitleMargin/FullTitle.text = title
	$BackgroundColor/QuestionNumber.text = str(questions)
