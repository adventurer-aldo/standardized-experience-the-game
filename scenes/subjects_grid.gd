extends GridContainer

@export var subject_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var s = Global.subjects.values()

	s.sort_custom(func i(subj: Subject, subj_b: Subject): return subj.last_time_edited > subj_b.last_time_edited)
	for subject in s:
		var subj = subject_scene.instantiate()
		subj.id = subject.id
		var exp = subject.maximum_experience
		var current_exp = subject.experience
		subj.level = subject.get_level()
		subj.xp = current_exp
		subj.title = subject.title
		add_child(subj)
