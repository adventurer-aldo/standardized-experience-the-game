extends Control

@export var subject_scene: PackedScene
const FOCUS_OPTIONS := {
	1: "1st Test",
	2: "2nd Test",
	4: "Exam",
}

func _ready() -> void:
	_setup_focus_picker()
	Main.wipe_out()
	Main.data.get_subjects().map(func (subject):
		var subj = subject_scene.instantiate()
		subj.subject_id = subject.id
		subj.focused.connect(change_subject_text)
		$SubjectsContainer.add_child(subj)
	)
	Main.localize_tree(self)

func change_subject_text(from_subject_id: int) -> void:
	$ColorRect/Label.text = Main.data.get_subject(from_subject_id).title

func _on_back_buton_pressed() -> void:
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _setup_focus_picker() -> void:
	var picker: OptionButton = $FocusPicker
	picker.clear()
	for focus_level in FOCUS_OPTIONS.keys():
		picker.add_item(FOCUS_OPTIONS[focus_level])
		picker.set_item_metadata(picker.item_count - 1, focus_level)
	_select_focus()

func _select_focus() -> void:
	var picker = $FocusPicker
	for index in range(picker.item_count):
		if int(picker.get_item_metadata(index)) == Main.data.focus:
			picker.select(index)
			return
	picker.select(0)
	Main.data.focus = int(picker.get_item_metadata(0))
	Main.data.save()

func _on_focus_selected(index: int) -> void:
	Main.data.focus = int($FocusPicker.get_item_metadata(index))
	Main.data.save()
