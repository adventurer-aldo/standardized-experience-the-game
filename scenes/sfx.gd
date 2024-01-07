extends AudioStreamPlayer

func autoplay(trackname: String, main: bool = true):
	if main == true:
		stream = load("res://audio/sfx/{name}.ogg".format({"name": trackname}))
		play()
	else:
		$SFX_alt.stream = load("res://audio/sfx/{name}.ogg".format({"name": trackname}))
		$SFX_alt.play()
