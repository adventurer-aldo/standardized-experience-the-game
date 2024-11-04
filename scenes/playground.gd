extends Control

func _ready():
	# BGM.autoplay("title")
	$SpinDome.play("spin")
	await get_tree().create_timer(0.2).timeout
	SFX.speak(Text.start.pick_random())

func _on_spin_dome_animation_finished(_anim_name) -> void:
	$SpinDome.play("spin")


func _on_press_enter_pressed() -> void:
	SFX.effect("start")
	$PressEnter/EnterAnimation.play("enter")

func _on_enter_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "enter":
		$PressEnter/EnterAnimation.play("fade_out")
		$TitleTexture/EnterReactionAnimation.play("enter")
		$ChoicesScroll/Choices.show()
		$ChoiceAnim.play("enter")
		$ChoicesScroll/Choices.get_children()[0].grab_button_focus()


func _on_subjects_pressed() -> void:
	add_child(load("res://scenes/subjects.tscn").instantiate())


func _on_practice_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/quiz/quiz.tscn")
