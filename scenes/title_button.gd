extends MarginContainer

func _on_story_button_mask_focus_entered() -> void:
	$Glowing.play("glow")
	$Focus.play("expand")

func _on_story_button_mask_focus_exited() -> void:
	SFX.effect("choice")
	$Focus.play("shrink")
	$Glowing.play("RESET")

func _on_glowing_animation_finished(anim_name: StringName) -> void:
	if anim_name == "glow": $Glowing.play("glow")

func grab_button_focus():
	$ButtonMask.grab_focus()

func _on_button_mask_pressed() -> void:
	SFX.effect("decision")
