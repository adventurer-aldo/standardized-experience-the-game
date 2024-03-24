extends AudioStreamPlayer

signal fade_in_finished

func autoplay(trackname: String, rush: String = ""):
	$MightTimer.stop()
	stream = load("res://audio/tracks/{name}.ogg".format({"name": trackname}))
	volume_db = 0
	$BGM_Rush.volume_db = -60
	if rush != "":
		$BGM_Rush.stream = load("res://audio/tracks/{name}.ogg".format({"name": rush}))
		$BGM_Rush.play()
	play()

func stop_might():
	$BGM_Rush.stop()


func fade_out(time := 1.0):
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "volume_db", -60, time)
	await fade_tween.finished
	stop()
	volume_db = 0.0
	emit_signal("fade_in_finished")

func pump_might(amount := 1.0):
	$MightTimer.wait_time = clampf($MightTimer.time_left + amount, 0.1, 21.0)
	$MightTimer.start()
	if $MightTimer.wait_time >= 20.0:
		might()

func might():
	get_tree().create_tween().tween_property($BGM_Rush, "volume_db", 0, 2.1)
	get_tree().create_tween().tween_property(self, "volume_db", -60, 5)

func _on_might_timer_timeout():
	get_tree().create_tween().tween_property(self, "volume_db", 0, 2.1)
	get_tree().create_tween().tween_property($BGM_Rush, "volume_db", -60, 5)
