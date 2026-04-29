extends GridContainer

@export var subject_packed_scene: PackedScene

signal subject_was_focused(subject_id: int)

var subjects: Array[Subject] = []
var sort_criteria:= "last_edited"
var sort_ascending:= false

func _ready() -> void:
	reload_subjects()

func reload_subjects() -> void:
	subjects.clear()
	for res_filename in DirAccess.get_files_at("user://subjects"):
		var subj = ResourceLoader.load("user://subjects/" + res_filename)
		if subj != null:
			subjects.push_back(subj)
	sort_subjects(sort_criteria, sort_ascending)

func sort_subjects(criteria:= sort_criteria, ascending:= sort_ascending) -> void:
	sort_criteria = criteria
	sort_ascending = ascending
	subjects.sort_custom(func (subject_a: Subject, subject_b: Subject):
		var comparison = _compare_subjects(subject_a, subject_b, sort_criteria)
		return comparison < 0 if sort_ascending else comparison > 0
	)
	_rebuild()

func add_to_container(subj: Subject) -> void:
	if !subjects.has(subj):
		subjects.push_back(subj)
	var new_subject_scene = subject_packed_scene.instantiate()
	# new_subject_scene.name = str(subj.id)
	# new_subject_scene.set_title(subj.title)
	# new_subject_scene.set_description(subj.description)
	# new_subject_scene.set_level(subj.level)
	# var subj_size = subj.size()
	# new_subject_scene.set_progress(subj_size * subj.level, subj.experience)
	# new_subject_scene.set_questions_size(subj_size)
	new_subject_scene.subject_id = subj.id
	add_child(new_subject_scene)
	
	new_subject_scene.subject_was_focused.connect(subject_focused)

func subject_focused(id: int) -> void:
	subject_was_focused.emit(id)

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for subj in subjects:
		add_to_container(subj)

func _compare_subjects(subject_a: Subject, subject_b: Subject, criteria: String) -> int:
	var a
	var b
	match criteria:
		"title":
			a = subject_a.title.to_lower()
			b = subject_b.title.to_lower()
		"level":
			a = subject_a.level
			b = subject_b.level
		"questions":
			a = subject_a.size()
			b = subject_b.size()
		_:
			a = subject_a.last_time_saved
			b = subject_b.last_time_saved
	if a == b:
		return subject_a.title.naturalnocasecmp_to(subject_b.title)
	if a is String:
		return a.naturalnocasecmp_to(b)
	return 1 if a > b else -1
