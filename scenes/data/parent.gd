extends MarginContainer

var tagtext = ""

signal delete_pressed

func set_text(text: String):
	$HElements/Text.text = text
	tagtext = text


func _on_button_pressed():
	emit_signal("delete_pressed", tagtext)
	queue_free()
