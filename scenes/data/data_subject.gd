extends Control

var subject = Subject.new()
var currently_selected_subject_id: int
var sort_criteria:= "last_edited"
var sort_ascending:= false

func _ready() -> void:
	_setup_sort_controls()
	Main.localize_tree(self)
	Main.wipe_out()

func _on_create_button_pressed() -> void:
	var title = $DataSubject/Elements/TitleLine.text.strip_edges()
	if title == "":
		return
	var new_subject = Subject.new()
	new_subject.title = title
	new_subject.description = $DataSubject/Elements/DescriptionText.text
	new_subject.create()
	$DataSubject/Elements/DescriptionText.text = ""
	$DataSubject/Elements/TitleLine.text = ""
	$Interface/GradientMask/SubjectsScroll/SubjectsContainer.add_to_container(new_subject)
	_apply_sort_and_search()
	$Slides.play("RESET")


func _on_search_bar_text_changed(new_text: String) -> void:
	_apply_search(new_text)

func _apply_search(new_text: String) -> void:
	for subj in $Interface/GradientMask/SubjectsScroll/SubjectsContainer.get_children():
		if new_text.strip_edges() == '':
			subj.show()
		else:
			var title: String = subj.title.text
			if !title.containsn(new_text):
				subj.hide()
			else:
				subj.show()

func _setup_sort_controls() -> void:
	var elements = $Interface/Search/Elements
	if !elements.has_node("SortCriteria"):
		var sort_option = OptionButton.new()
		sort_option.name = "SortCriteria"
		sort_option.custom_minimum_size.x = 160
		sort_option.add_item("Last Edited")
		sort_option.set_item_metadata(0, "last_edited")
		sort_option.add_item("Title")
		sort_option.set_item_metadata(1, "title")
		sort_option.add_item("Level")
		sort_option.set_item_metadata(2, "level")
		sort_option.add_item("Questions")
		sort_option.set_item_metadata(3, "questions")
		sort_option.item_selected.connect(_on_sort_criteria_selected)
		elements.add_child(sort_option)
	if !elements.has_node("SortDirection"):
		var direction_option = OptionButton.new()
		direction_option.name = "SortDirection"
		direction_option.custom_minimum_size.x = 130
		direction_option.add_item("Descending")
		direction_option.set_item_metadata(0, false)
		direction_option.add_item("Ascending")
		direction_option.set_item_metadata(1, true)
		direction_option.item_selected.connect(_on_sort_direction_selected)
		elements.add_child(direction_option)

func _on_sort_criteria_selected(index: int) -> void:
	sort_criteria = str($Interface/Search/Elements/SortCriteria.get_item_metadata(index))
	_apply_sort_and_search()

func _on_sort_direction_selected(index: int) -> void:
	sort_ascending = bool($Interface/Search/Elements/SortDirection.get_item_metadata(index))
	_apply_sort_and_search()

func _apply_sort_and_search() -> void:
	$Interface/GradientMask/SubjectsScroll/SubjectsContainer.sort_subjects(sort_criteria, sort_ascending)
	_apply_search($Interface/Search/Elements/SearchBar.text)


func _on_subjects_container_subject_was_focused(subject_id: int) -> void:
	currently_selected_subject_id = subject_id
	print(currently_selected_subject_id)

func might_bgm() -> void:
	$MightTransitions.play("might")

func calm_bgm() -> void:
	$MightTransitions.play("calm")

func _on_create_subject_pressed() -> void:
	$Slides.play("slide_out")
