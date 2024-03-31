extends AudioStreamPlayer

signal fade_in_finished

var can_rush := false

func autoplay(trackname: String, might:= "", mighty_start := false, rush:= ""):
	$Transitions.play("RESET")
	await $Transitions.animation_finished
	stop_rush()
	if might == "":
		stream.set_sync_stream(1, null)
	else:
		stream.set_sync_stream(1, load("res://audio/tracks/{name}.ogg".format({"name": might})))
	stream.set_sync_stream(0, load("res://audio/tracks/{name}.ogg".format({"name": trackname})))
	if mighty_start == true && might != "":
		$MightTimer.wait_time = 20.0
		stream.set_sync_stream_volume(0, -60)
		stream.set_sync_stream_volume(1, 0)
		$MightTimer.start()
	else:
		$MightTimer.stop()
	if rush == "":
		$Rush.stop()
		can_rush = false
	else:
		can_rush = true
		$Rush.stream = load("res://audio/tracks/{name}.ogg".format({"name": rush}))
	play()

func stop_rush():
	$Rush.stop()

func fade_out():
	$Transitions.play("fade_out")
	await $Transitions.animation_finished
	emit_signal("fade_in_finished")

func pump_might(amount := 1.0):
	if $Rush.is_playing():
		return
	else:
		if can_rush:
			rush()
		$MightTimer.wait_time = clampf($MightTimer.time_left + amount, 0.1, 21.0)
		$MightTimer.start()
		if $MightTimer.wait_time >= 20.0:
			might()

func rush():
	$Rush.play()
	$Transitions.play("rush")

func might():
	if stream.get_sync_stream_volume(1) != -60: return
	$Transitions.play("might")

func _on_might_timer_timeout():
	if stream.get_sync_stream_volume(0) != -60: return
	$Transitions.play("demight")
