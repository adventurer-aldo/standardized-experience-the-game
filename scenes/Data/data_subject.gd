extends Control

var subject = Subject.new()

func _on_create_button_pressed() -> void:
	subject.title = $DataSubject/Elements/TitleLine.text
	subject.description = $DataSubject/Elements/DescriptionText.text
	subject.create()
	$DataSubject/Elements/DescriptionText.text = ""
	$DataSubject/Elements/TitleLine.text = ""
	$DataSubject/SubjectsContainer.add_to_container(subject)


func _on_exit_pressed() -> void:
	queue_free()
