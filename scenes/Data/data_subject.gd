extends Control

var subject = Subject.new()

func _on_create_button_pressed() -> void:
	subject.title = $Elements/TitleLine.text
	subject.description = $Elements/DescriptionText.text
	subject.create()
	$Elements/DescriptionText.text = ""
	$Elements/TitleLine.text = ""
	$SubjectsContainer.add_to_container(subject)


func _on_exit_pressed() -> void:
	queue_free()
