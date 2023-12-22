extends AudioStreamPlayer

func autoplay(trackname: String):
	stream = load("res://audio/tracks/{name}.ogg".format({"name": trackname}))
	play()
