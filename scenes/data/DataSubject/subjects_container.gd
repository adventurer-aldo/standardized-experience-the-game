extends GridContainer

@export var subject_packed_scene: PackedScene

signal subject_was_focused(subject_id: int)

func _ready() -> void:
	var subj_files = Array(DirAccess.get_files_at("user://subjects"))
	subj_files.sort_custom(func (subj_a, subj_b):
		var a: Subject = ResourceLoader.load("user://subjects/" + subj_a)
		var b: Subject = ResourceLoader.load("user://subjects/" + subj_b)
		return a.last_time_saved > b.last_time_saved
	)
	subj_files.map(func (res_filename): 
		var subj = ResourceLoader.load("user://subjects/" + res_filename)
		add_to_container(subj)
	)

func add_to_container(subj: Subject) -> void:
	var new_subject_scene = subject_packed_scene.instantiate()
	new_subject_scene.subject_id = subj.id
	add_child(new_subject_scene)
	
	new_subject_scene.subject_was_focused.connect(subject_focused)

func subject_focused(id: int) -> void:
	subject_was_focused.emit(id)
