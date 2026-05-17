extends Control

var subject = Subject.new()
var sort_criteria:= "last_edited"
var sort_ascending:= false
@onready var average_formula_option: OptionButton = $DataSubject/Elements/AverageFormula
@onready var subject_image_preview: TextureRect = $DataSubject/Elements/SubjectImagePreview
var pending_subject_image: Texture2D

func _ready() -> void:
	_setup_average_formula_control()
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
	new_subject.average_formula = int(average_formula_option.get_selected_metadata()) if average_formula_option != null else Chair.AverageFormula.TESTS_ONLY
	new_subject.create()
	if pending_subject_image != null:
		new_subject.get_or_create_image_mediaset().add_image(pending_subject_image)
		pending_subject_image = null
		subject_image_preview.texture = null
	$DataSubject/Elements/DescriptionText.text = ""
	$DataSubject/Elements/TitleLine.text = ""
	$Interface/GradientMask/SubjectsScroll/SubjectsContainer.add_to_container(new_subject)
	_apply_sort_and_search()
	$Slides.play("RESET")


func _on_search_bar_text_changed(new_text: String) -> void:
	_apply_search(new_text)

func _apply_search(new_text: String) -> void:
	var search = new_text.strip_edges()
	for subj in $Interface/GradientMask/SubjectsScroll/SubjectsContainer.get_children():
		if search == "":
			subj.show()
		else:
			var subject_res = Main.data.get_subject(subj.subject_id)
			var subject_title = subject_res.title if subject_res != null else ""
			if !subject_title.containsn(search):
				subj.hide()
			else:
				subj.show()

func _setup_sort_controls() -> void:
	var elements = $Interface/Search/Elements
	var sort_option: OptionButton = elements.get_node("SortCriteria")
	sort_option.clear()
	sort_option.add_item("Last Edited")
	sort_option.set_item_metadata(0, "last_edited")
	sort_option.add_item("Title")
	sort_option.set_item_metadata(1, "title")
	sort_option.add_item("Level")
	sort_option.set_item_metadata(2, "level")
	sort_option.add_item("Questions")
	sort_option.set_item_metadata(3, "questions")
	var direction_option: OptionButton = elements.get_node("SortDirection")
	direction_option.clear()
	direction_option.add_item("Descending")
	direction_option.set_item_metadata(0, false)
	direction_option.add_item("Ascending")
	direction_option.set_item_metadata(1, true)

func _setup_average_formula_control() -> void:
	average_formula_option.clear()
	average_formula_option.add_item("Tests Only")
	average_formula_option.set_item_metadata(0, Chair.AverageFormula.TESTS_ONLY)
	average_formula_option.add_item("Tests 80 + Dissertation 20")
	average_formula_option.set_item_metadata(1, Chair.AverageFormula.TESTS_80_DISSERTATION_20)
	average_formula_option.add_item("Best Two Tests")
	average_formula_option.set_item_metadata(2, Chair.AverageFormula.BEST_TWO_TESTS)
	average_formula_option.add_item("Reposition Replaces Lowest")
	average_formula_option.set_item_metadata(3, Chair.AverageFormula.REPOSITION_REPLACES_LOWEST_TEST)
	average_formula_option.add_item("Best Test 60 + Dissertation 40")
	average_formula_option.set_item_metadata(4, Chair.AverageFormula.BEST_TEST_60_DISSERTATION_40)

func _on_sort_criteria_selected(index: int) -> void:
	sort_criteria = str($Interface/Search/Elements/SortCriteria.get_item_metadata(index))
	_apply_sort_and_search()

func _on_sort_direction_selected(index: int) -> void:
	sort_ascending = bool($Interface/Search/Elements/SortDirection.get_item_metadata(index))
	_apply_sort_and_search()

func _apply_sort_and_search() -> void:
	$Interface/GradientMask/SubjectsScroll/SubjectsContainer.sort_subjects(sort_criteria, sort_ascending)
	_apply_search($Interface/Search/Elements/SearchBar.text)


func _on_subjects_container_subject_was_focused(_subject_id: int) -> void:
	pass

func might_bgm() -> void:
	$MightTransitions.play("might")

func calm_bgm() -> void:
	$MightTransitions.play("calm")

func _on_create_subject_pressed() -> void:
	$Slides.play("slide_out")

func _on_subject_image_pressed() -> void:
	var image = DisplayServer.clipboard_get_image()
	if image == null || image.is_empty():
		return
	pending_subject_image = ImageTexture.create_from_image(image)
	subject_image_preview.texture = pending_subject_image
