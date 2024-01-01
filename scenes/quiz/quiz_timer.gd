extends Panel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = str(int($Timer.time_left)) + 's'
