extends Control

@export var subject_scene: PackedScene


func _on_button_pressed() -> void:
	$IntoCard.play("into_card")
	var new_subject = Subject.new()
	new_subject.id = Main.data.next_subject_id()
	new_subject.title = $Title/Elements/TitleBar.text
	new_subject.description = $Description/Elements/DescriptionBar.text
	new_subject.create()
	var subj = subject_scene.instantiate()
	subj.subject_id = new_subject.id
	subj.show_behind_parent = true
	$TempPosition.add_child(subj)
	await get_tree().create_timer(0.5).timeout
	$IntoCard.play("fade_card")
	await $IntoCard.animation_finished
	$IntoCard.play("move_card")
	await $IntoCard.animation_finished
	$IntoCard.play("return_elements")
	await $IntoCard.animation_finished
	$IntoCard.play("RESET")
	
