extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var subj_node = load("res://scenes/data/subject.tscn") as PackedScene
	var subjs = Global.subjects.keys()
	subjs.sort_custom(sorter)
	for i in subjs:
		var dup = subj_node.instantiate()
		dup.title = Global.subjects[i].title
		dup.questions = DirAccess.get_files_at("user://subjects/" + str(i)).size()
		dup.color = Global.subjects[i].color
		dup.id = i
		dup.resource = Global.subjects[i]
		$GridContainer2/GridContainer.add_child(dup)

func sorter(subj_a, subj_b): 
	return Global.subjects[subj_a].last_time_edited > Global.subjects[subj_b].last_time_edited


func _on_button_pressed():
	queue_free()
