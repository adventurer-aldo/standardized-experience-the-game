extends Node

var stats: Statistics

func _ready() -> void:
	if FileAccess.file_exists("user://stats.tres"):
		stats = ResourceLoader.load("user://stats.tres")
	else:
		stats = Statistics.new()
