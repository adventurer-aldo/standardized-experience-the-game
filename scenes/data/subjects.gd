extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var subj_node = load("res://scenes/data/subject.tscn") as PackedScene
	# subjs.sort_custom(sorter)
	for i in User.subjects.keys():
		var dup = subj_node.instantiate()
		dup.title = User.subjects[i].title
		dup.questions = DirAccess.get_files_at("user://subjects/" + str(i)).size()
		dup.color = User.subjects[i].color
		dup.id = i
		$GridContainer2/GridContainer.add_child(dup)

func sorter(subj): return User.subjects[subj].starred == true


func _on_button_pressed():
	queue_free()
