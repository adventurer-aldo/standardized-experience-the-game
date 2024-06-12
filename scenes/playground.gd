extends ColorRect

func _ready():
	var i = load("res://scenes/bgm.tscn") as PackedScene
	i = i.instantiate()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
	print(i.get_class())
