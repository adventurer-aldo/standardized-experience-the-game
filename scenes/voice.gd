extends AudioStreamPlayer

func random_play(filename: String) -> void:
	var dir = "res://audio/voice/" + filename + "/"
	
	# Get all files at directory
	var files = Array(DirAccess.get_files_at(dir)) 
	
	# The line below removes the files that contain ".import" so that .import
	# files are not included in the list, and only valid audio files
	# (supposedly) are accounted for.
	files = files.filter(func (file_name: String): return !file_name.contains('.import'))
	
	# Randomizes so that it isn't the same audio file being played every time.
	randomize()
	stream = load(dir + files[randi() % files.size()])
	play()

func play_file(filename: String) -> void:
	stream = load("res://audio/voice/" + filename)
	play()
