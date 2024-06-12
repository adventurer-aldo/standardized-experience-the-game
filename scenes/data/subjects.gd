extends ColorRect

@export var subj_node: PackedScene

func _ready():
	var subjects = Global.subjects.values()
	subjects.sort_custom(sort_by_last_time_edited)
	for subject in subjects:
		var dup = subj_node.instantiate()
		dup.title = subject.title
		dup.questions = DirAccess.get_files_at("user://subjects/" + str(subject.id)).size()
		dup.color = subject.color
		dup.id = subject.id
		dup.resource = subject
		$GridContainer2/GridContainer.add_child(dup)

func sort_by_last_time_edited(subj_a: Subject, subj_b: Subject): 
	return subj_a.last_time_edited > subj_b.last_time_edited

func _on_button_pressed():
	queue_free()

func _on_add_subject_button_pressed() -> void:
	$AddBG.show()

func _on_submit_subject_pressed() -> void:
	if $AddBG/LineEdit.text.strip_edges() == "" || Global.subjects.values().map(func i(subject): return subject.title.to_lower()).has($AddBG/LineEdit.text.strip_edges().to_lower()):
		return
	var subj = Subject.new()
	Global.stats.last_subject_id += 1
	subj.id = Global.stats.last_subject_id
	subj.title = $AddBG/LineEdit.text
	subj.color = Global.generate_random_color_with_contrast()
	subj.last_time_edited = Time.get_unix_time_from_system()
	Global.save_stats()
	subj.create()
	get_tree().reload_current_scene()
