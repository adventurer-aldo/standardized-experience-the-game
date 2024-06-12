extends AudioStreamPlayer

signal fade_in_finished
signal rush_time_started

var can_rush := false

func autoplay_rush(trackname: String):
	autoplay(trackname + '_pre', false, trackname)

func autoplay(trackname: String, mighty_start := false, with_rush:= ""):
	$Transitions.play("RESET")
	await $Transitions.animation_finished
	stop_rush()
	var might_exists = FileAccess.file_exists("res://audio/tracks/%s.ogg" % (trackname + '_might'))
	if might_exists:
		stream.set_sync_stream(1, load("res://audio/tracks/{name}_might.ogg".format({"name": trackname})))
	else:
		stream.set_sync_stream(1, null)
	stream.set_sync_stream(0, load("res://audio/tracks/{name}.ogg".format({"name": trackname})))
	if mighty_start == true && might_exists:
		$MightTimer.wait_time = 20.0
		stream.set_sync_stream_volume(0, -60)
		stream.set_sync_stream_volume(1, 0)
		$MightTimer.start()
	else:
		$MightTimer.stop()
	if with_rush == "":
		$Rush.stop()
		can_rush = false
	else:
		can_rush = true
		$Rush.stream = load("res://audio/tracks/{name}.ogg".format({"name": with_rush}))
	play()

func stop_rush():
	$Rush.stop()

func fade_out():
	$Transitions.play("fade_out")
	await $Transitions.animation_finished
	stop()
	fade_in_finished.emit()

func pump_might(amount := 1.0):
	if $Rush.is_playing() || (stream.get_sync_stream(1) == null && !can_rush):
		return
	else:
		if can_rush:
			rush()
			return
		$MightTimer.wait_time = clampf($MightTimer.time_left + amount, 0.1, 21.0)
		$MightTimer.start()
		if $MightTimer.wait_time >= 20.0:
			might()

func rush():
	$Rush.play()
	$Transitions.play("rush")
	rush_time_started.emit("blink")

func might():
	if stream.get_sync_stream_volume(1) != -60: return
	$Transitions.play("might")

func _on_might_timer_timeout():
	if stream.get_sync_stream_volume(0) != -60: return
	$Transitions.play("demight")
