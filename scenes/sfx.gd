extends AudioStreamPlayer

func autoplay(trackname: String):
	stream = load("res://audio/sfx/{name}.ogg".format({"name": trackname}))
	play()
