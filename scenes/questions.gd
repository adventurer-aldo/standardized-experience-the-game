extends ColorRect

var id = 2
var questions = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in DirAccess.get_files_at("user://subjects/2"):
		questions[int(i)] = load("user://subjects/2/{i}".format({"i": i}))
		var pen = $"1234".duplicate()
		$GridContainer.add_child(pen)
		pen.get_children()[3].get_children()[0].get_children()[0].get_children()[0].text = questions[int(i)].question[0]
		pen.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
