extends AudioStreamPlayer

signal speak_finished

func effect(trackname: String, main: bool = true):
	if main == true:
		stream = load("res://audio/sfx/{name}.ogg".format({"name": trackname}))
		play()
	else:
		$SFX_alt.stream = load("res://audio/sfx/{name}.ogg".format({"name": trackname}))
		$SFX_alt.play()

func speak(trackname: String):
	$Voice.stream = load("res://audio/voice/{name}.ogg".format({"name": trackname}))
	$Voice.play()

func speak_stop():
	$Voice.stop()

func _on_voice_finished():
	emit_signal("speak_finished")
