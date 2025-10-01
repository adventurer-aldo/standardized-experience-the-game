extends Control

var subject = Subject.new()

func _on_create_button_pressed() -> void:
	subject.title = $Elements/TitleLine.text
	subject.description = $Elements/DescriptionText.text
	subject.create()
