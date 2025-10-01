extends Node

func _ready() -> void:
	if !DirAccess.dir_exists_absolute("user://subjects"):
		DirAccess.make_dir_absolute("user://subjects")
	# DirAccess.make_dir_absolute("user://subjects")
