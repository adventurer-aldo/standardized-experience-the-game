extends AudioStreamPlayer

func random_play(filename: String, delay:= 0.0) -> void:
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
	if delay > 0.0: await get_tree().create_timer(delay).timeout
	play()

func play_file(filename: String, delay:= 0.0) -> void:
	stream = load("res://audio/voice/" + filename)
	if delay > 0.0: 
		await get_tree().create_timer(delay).timeout
	play()
