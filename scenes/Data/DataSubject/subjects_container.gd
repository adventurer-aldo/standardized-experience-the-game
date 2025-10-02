extends GridContainer

@export var subject_packed_scene: PackedScene

func _ready() -> void:
	var subj_files = Array(DirAccess.get_files_at("user://subjects"))
	subj_files.map(func (res_filename): 
		var subj = ResourceLoader.load("user://subjects/" + res_filename)
		add_to_container(subj)
	)

func add_to_container(subj: Subject) -> void:
	var new_subject_scene = subject_packed_scene.instantiate()
	new_subject_scene.set_title(subj.title)
	new_subject_scene.subject_id = subj.id
	add_child(new_subject_scene)
