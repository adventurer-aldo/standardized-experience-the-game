extends Node

func _ready():
	# print(DisplayServer.clipboard_get())
	load("user://questions.dat")
	


func _on_file_dialog_file_selected(path):
	var ben = Image.new()
	ben.load(path)
	$TextureRect.texture = ImageTexture.create_from_image(ben)
