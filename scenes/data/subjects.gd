extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var subj_node = load("res://scenes/data/subject.tscn") as PackedScene
	# subjs.sort_custom(sorter)
	for i in Global.subjects.keys():
		var dup = subj_node.instantiate()
		dup.title = Global.subjects[i].title
		dup.questions = DirAccess.get_files_at("user://subjects/" + str(i)).size()
		dup.color = Global.subjects[i].color
		dup.id = i
		$GridContainer2/GridContainer.add_child(dup)

func sorter(subj): return Global.subjects[subj].starred == true


func _on_button_pressed():
	queue_free()
