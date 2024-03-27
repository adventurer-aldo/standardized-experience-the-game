extends AudioStreamPlayer

signal fade_in_finished

func autoplay(trackname: String, rush: String = ""):
	$MightTimer.stop()
	stream = load("res://audio/tracks/{name}.ogg".format({"name": trackname}))
	$Transitions.play("RESET")
	if rush == "":
		$BGM_Might.stream = null
	else:
		$BGM_Might.stream = load("res://audio/tracks/{name}.ogg".format({"name": rush}))
		$BGM_Might.play()
	play()

func fade_out():
	$Transitions.play("fade_out")
	await $Transitions.animation_finished
	emit_signal("fade_in_finished")

func pump_might(amount := 1.0):
	$MightTimer.wait_time = clampf($MightTimer.time_left + amount, 0.1, 21.0)
	$MightTimer.start()
	if $MightTimer.wait_time >= 20.0:
		might()

func might():
	if $BGM_Might.volume_db != -60: return
	$Transitions.play("might")

func _on_might_timer_timeout():
	if volume_db != -60: return
	$Transitions.play("demight")
