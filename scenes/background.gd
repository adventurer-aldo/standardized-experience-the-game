extends Control

@export_range(0.0, 2.0, 0.01) var speed = 0.25

func _ready():
	$LoopAnim.speed_scale = speed
	var time = {"hour": 10} # Time.get_time_dict_from_system()
	if time.hour >= 18 || time.hour <= 6:
		$Background/BackgroundDark.show()
	else:
		$Background/BackgroundDark.hide()
	$LoopAnim.play("loop")

func _on_loop_anim_animation_finished(_anim_name):
	$LoopAnim.play("loop")
