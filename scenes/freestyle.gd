extends Control

@export var subject_scene: PackedScene

func _ready() -> void:
	Main.wipe_out()
	Main.data.get_subjects().map(func (subject):
		var subj = subject_scene.instantiate()
		subj.subject_id = subject.id
		$SubjectsContainer.add_child(subj)
	)


func _on_back_buton_pressed() -> void:
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
