extends AudioStreamPlayer

func play_file(filename: String) -> void:
	stream = load("res://audio/sfx/" + filename + ".ogg")
	play()
