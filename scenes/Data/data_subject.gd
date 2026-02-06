extends Control

var subject = Subject.new()
var currently_selected_subject_id: int

func _on_create_button_pressed() -> void:
	subject.title = $DataSubject/Elements/TitleLine.text
	subject.description = $DataSubject/Elements/DescriptionText.text
	subject.create()
	$DataSubject/Elements/DescriptionText.text = ""
	$DataSubject/Elements/TitleLine.text = ""
	$GradientMask/SubjectsScroll/SubjectsContainer.add_to_container(subject)


func _on_exit_pressed() -> void:
	queue_free()


func _on_search_bar_text_changed(new_text: String) -> void:
	for subject in $GradientMask/SubjectsScroll/SubjectsContainer.get_children():
		if new_text.strip_edges() == '':
			subject.show()
		else:
			var title: String = subject.title.text
			if !title.containsn(new_text):
				subject.hide()
			else:
				subject.show()


func _on_subjects_container_subject_was_focused(subject_id: int) -> void:
	currently_selected_subject_id = subject_id
	print(currently_selected_subject_id)
