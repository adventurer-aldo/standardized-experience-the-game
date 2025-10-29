extends Node

var data: Data

func _ready() -> void:
	if FileAccess.file_exists("user://data.tres"):
		data = ResourceLoader.load("user://data.tres")
	else:
		data = Data.new()
