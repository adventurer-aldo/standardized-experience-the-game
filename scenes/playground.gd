extends Node

func _ready():
	var voices = load("res://texts/level1_cheers.txt")
	print(FileAccess.open("res://texts/level1_cheers.txt", FileAccess.READ).get_as_text())
