extends GridContainer

@export var subject_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for subject in Global.subjects.values():
		var subj = subject_scene.instantiate()
		subj.id = subject.id
		subj.title = subject.title
		add_child(subj)
