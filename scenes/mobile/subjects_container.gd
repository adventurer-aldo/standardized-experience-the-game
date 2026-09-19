extends GridContainer

@export var subject_button: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var subjects = Main.data.get_subjects()
	subjects.sort_custom(func (subject_a: Subject, subject_b: Subject):
		return subject_a.last_time_saved > subject_b.last_time_saved)
	for subject in subjects:
		var subj_button = subject_button.instantiate()
		subj_button.subject_id = subject.id
		add_child(subj_button)
