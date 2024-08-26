extends TextureRect

func _ready() -> void:
	refresh_total()

func refresh_total():
	var amount = str(Array(DirAccess.get_files_at("user://subjects")).size())
	$DotTexture/HBox/Margin/TotalPanel/HBox/HBoxContainer/Amount.text = amount

func _on_texture_button_pressed() -> void:
	queue_free()
