extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in User.subjects.keys():
		var dup = $Subject.duplicate()
		dup.setup(User.subjects[i].title, DirAccess.get_files_at("user://subjects/" + str(i)).size(), User.subjects[i].color)
		$GridContainer2/GridContainer.add_child(dup)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
