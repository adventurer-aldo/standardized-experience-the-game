extends HBoxContainer

signal delete_pressed

func _on_delete_pressed():
	emit_signal("delete_pressed", self)


func clean():
	$Text.text = ""
