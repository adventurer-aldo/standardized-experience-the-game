extends MarginContainer

var tagtext = ""

signal delete_pressed

func set_text(text: String):
	$HElements/Text.text = text
	tagtext = text


func _on_button_pressed():
	delete_pressed.emit(tagtext)
	Global.emit_signal("data_questions_parent_was_deleted", tagtext)
	queue_free()
