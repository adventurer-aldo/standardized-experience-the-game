extends GridContainer

@export var subject_packed_scene: PackedScene

signal subject_was_focused(subject_id: int)

func _ready() -> void:
	var subj_files = Array(DirAccess.get_files_at("user://subjects"))
	subj_files.map(func (res_filename): 
		var subj = ResourceLoader.load("user://subjects/" + res_filename)
		add_to_container(subj)
	)

func add_to_container(subj: Subject) -> void:
	var new_subject_scene = subject_packed_scene.instantiate()
	new_subject_scene.name = str(subj.id)
	new_subject_scene.set_title(subj.title)
	new_subject_scene.set_description(subj.description)
	new_subject_scene.set_level(subj.level)
	var size = subj.size()
	new_subject_scene.set_progress(size * subj.level, subj.experience)
	new_subject_scene.set_questions_size(size)
	new_subject_scene.subject_id = subj.id
	add_child(new_subject_scene)
	
	new_subject_scene.subject_was_focused.connect(subject_focused)

func subject_focused(id: int) -> void:
	subject_was_focused.emit(id)
