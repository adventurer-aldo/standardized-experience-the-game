extends Control

func _ready():
	var time = {"hour": 12} # Time.get_time_dict_from_system()
	if time.hour >= 18 || time.hour <= 6:
		$Background/BackgroundDark.show()
	else:
		$Background/BackgroundDark.hide()
	$LoopAnim.play("loop")

func _on_loop_anim_animation_finished(_anim_name):
	$LoopAnim.play("loop")
