extends MarginContainer

var id: int
var level := 1
var questions := 0
var color := Color.BLACK
var image: Image
var title := ""
var resource: Resource

# Called when the node enters the scene tree for the first time.
func _ready():
	var a = title.replace("(", " ").replace(")", "").replace("  ", " ")
	var tit = "".join(PackedStringArray(Array(a.split(" ")).map(func i(strin): return strin[0])))
	$SubjectElements/Title.text = tit
	$SubjectElements/FullTitleContainer/FullTitleMargin/FullTitle.text = title
	$SubjectElements/Title/QuestionNumber.text = str(questions)
	$BackgroundColor.self_modulate = color
	if image != null: ImageTexture.create_from_image(image)
	Global.data_questions_question_was_submitted.connect(new_question_was_submitted)

func star():
	var subj = Global.subjects[id]
	subj.starred = !subj.starred

func _on_mouse_entered():
	$HBoxContainer.show()

func _on_mouse_exited():
	$HBoxContainer.hide()

func _on_questions_pressed():
	var pep = load("res://scenes/data/questions.tscn") as PackedScene
	var pop = pep.instantiate()
	pop.subject = id
	pop.subject_name = title
	add_child(pop)

func new_question_was_submitted(question):
	if question.subject_id == id:
		resource.last_time_edited = Time.get_unix_time_from_system()
		resource.save()
