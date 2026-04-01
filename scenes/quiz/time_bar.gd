extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_time_string(to: String) -> void:
	$HBoxC/TimeLabel.text = to
	if to == "30s" && !$WarnAnim.is_playing():
		$WarnAnim.play("warn_text")

func _on_ticking_anim_animation_finished(_anim_name: StringName) -> void:
	$TickingAnim.play("ticktock")

func stop() -> void:
	$TickingAnim.stop()
	$WarnAnim.stop()

func display() -> void:
	$DisplayAnim.play("display")
	$TickingAnim.play("ticktock")

func reset() -> void:
	$DisplayAnim.play("RESET")

func start_warning_text() -> void:
	$WarnAnim.play("warn_text")

func _on_warn_anim_animation_finished(_anim_name: StringName) -> void:
	$WarnAnim.play("warn_text")
