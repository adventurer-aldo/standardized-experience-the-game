extends Control

signal animation_finished

# Called when the node enters the scene tree for the first time.
func play() -> void:
	$RushTransition.play("showcase")
	$TextBackground/DashesAnim.play("dashloop")

func _on_dashes_anim_animation_finished(_anim_name: StringName) -> void:
	if $RushTransition.is_playing() && $RushTransition.current_animation == "showcase":
		$TextBackground/DashesAnim.play("dashloop")

func play_hide_dims() -> void:
	$RushTransition.play("hide_dims")

func _on_rush_transition_animation_finished(_anim_name: StringName) -> void:
	animation_finished.emit()

func reset() -> void:
	$RushTransition.play("RESET")
	$TextBackground/DashesAnim.play("RESET")
