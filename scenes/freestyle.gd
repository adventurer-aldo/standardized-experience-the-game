extends Control

@export var subject_scene: PackedScene

func _ready() -> void:
	Main.wipe_out()
	var subjects = Main.data.get_subjects()
	subjects.sort_custom(func (subject_a: Subject, subject_b:Subject):
		return subject_a.last_time_saved > subject_b.last_time_saved
	)
	subjects.map(func (subject):
		var subj = subject_scene.instantiate()
		subj.subject_id = subject.id
		subj.focused.connect(change_subject_text)
		$SubjectsContainer.add_child(subj)
	)

func change_subject_text(from_subject_id: int) -> void:
	$ColorRect/Label.text = Main.data.get_subject(from_subject_id).title

func _on_back_buton_pressed() -> void:
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
