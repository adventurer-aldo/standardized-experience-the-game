extends Control

signal question_alt_changed

signal might_started
signal might_ended

@export var question_packed_scene: PackedScene
@export var saved_question_packed_scene: PackedScene
var subject_id: int
var title = "Default Subject"
var question = Question.new()
var subject: Subject
@export var silence = false
var search_thread = Thread.new()

var might_mode:= false
var question_filter_level:= 0
var question_filter_type:= "any"
var question_sort_criteria:= "last_edited"
var question_sort_ascending:= false
var relationship_filter:= ""
var relationship_question_id:= 0

func _ready() -> void:
	question.subject_id = subject_id
	subject = Main.data.get_subject(subject_id) if subject_id > 0 else null
	$SubjectBar/Title.text = title
	_setup_question_search_controls()
	_on_add_question_alt_pressed()
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Open.button_pressed = true
	_on_open_pressed()
	if subject != null:
		set_container()
	Main.localize_tree(self)
	
	if silence:
		$BGM.stop()
		$MightBGM.stop()

func might_boost(value: float) -> void:
	var new_value = clamp($MightTimer.time_left + value, 0.0, 30.1)
	$MightTimer.start(new_value)
	if !might_mode:
		$MightTransitions.play("might")
		might_mode = true
		might_started.emit()

func _on_might_timer_timeout() -> void:
	if might_mode && $MightTimer.time_left > 120.0:
		$MightTransitions.play("calm")
		might_mode = false
		$MightTimer.wait_time = 0.06
		might_ended.emit()

func _on_reset_pressed() -> void:
	$Items/ScrollData/Data/Question/Texts.get_children().map(func (child): child.reset())
	$Items/ScrollData/Data/Question/Texts.get_child(0).get_focus()
	$Items/ScrollData/Data/Opens.reset(true)
	
	$Items/ScrollData/Data/ParentsContainer/ParentsFlow.reset()
	$Items/ScrollData/Data/TagsContainer/TagsFlow.reset()
	if has_node("Items/ScrollData/Data/Scheme"):
		$Items/ScrollData/Data/Scheme.replicate({})
	question.id = 0

func set_container() -> void:
	if subject == null:
		return
	subject.get_questions().map(func (saved_question):
		# var a = Thread.new()
		# a.start(add_question_to_container.bind(saved_question))
		add_question_to_container(saved_question)
	)

func add_question_to_container(saved_question: Question) -> void:
	var question_to_add
	var container_node = $QuestionsScroll/QuestionsContainer
	if container_node.has_node(str(saved_question.id)):
		question_to_add = container_node.get_node(str(saved_question.id))
	else:
		question_to_add = saved_question_packed_scene.instantiate()
		question_to_add.parent_pressed.connect(on_parent_pressed)
		question_to_add.edit_pressed.connect(on_edit_pressed)
		question_to_add.delete_pressed.connect(on_grid_delete_pressed)
		if question_to_add.has_signal("show_parents_pressed"):
			question_to_add.show_parents_pressed.connect(on_show_parents_pressed)
		if question_to_add.has_signal("show_children_pressed"):
			question_to_add.show_children_pressed.connect(on_show_children_pressed)
		question_to_add.name = str(saved_question.id)
		question_to_add.id = saved_question.id
	question_to_add.set_text(saved_question.question[0])
	question_to_add.set_level(saved_question.experience_level)
	if question_to_add.has_method("set_types"):
		question_to_add.set_types(saved_question.get_types())
	container_node.add_child(question_to_add)
	container_node.move_child(question_to_add, 0)
	$SubjectBar/AmountBar/Amount.text = str(container_node.get_child_count()).lpad(2, '0')
	_apply_question_filters_and_sort()

func _on_add_question_alt_pressed() -> void:
	var q_scene = question_packed_scene.instantiate()
	$Items/ScrollData/Data/Question/Texts.add_child(q_scene)
	question_alt_changed.emit($Items/ScrollData/Data/Question/Texts.get_child_count() + 1)
	question_alt_changed.connect(q_scene.refresh)
	q_scene.delete_pressed.connect(_on_question_delete_pressed)
	
func _on_question_delete_pressed() -> void:
	print("Alt changed")
	question_alt_changed.emit($Items/ScrollData/Data/Question/Texts.get_child_count() - 1)

func _on_open_pressed() -> void:
	if question.get_types().size() == 1 && question.is_open: return
	question.is_open = !question.is_open
	$Items/ScrollData/Data/Opens.visible = question.is_open

func _on_choice_pressed() -> void:
	if question.get_types().size() == 1 && question.is_choice: return
	question.is_choice = !question.is_choice
	$Items/ScrollData/Data/Opens.visible = (question.is_open || question.is_choice)
	$Items/ScrollData/Data/Choices.visible = question.is_choice

func _on_match_pressed() -> void:
	if question.get_types().size() == 1 && question.is_connect: return
	question.is_connect = !question.is_connect
	$Items/ScrollData/Data/Match.visible = question.is_connect

func _on_table_pressed() -> void:
	if question.get_types().size() == 1 && question.is_table: return
	question.is_table = !question.is_table
	$Items/ScrollData/Data/Table.visible = question.is_table

func _on_label_pressed() -> void:
	if question.get_types().size() == 1 && question.is_label: return
	question.is_label = !question.is_label
	$Items/ScrollData/Data/Label.visible = question.is_label

func _on_scheme_pressed() -> void:
	if question.get_types().size() == 1 && question.is_scheme: return
	question.is_scheme = !question.is_scheme
	$Items/ScrollData/Data/Scheme.visible = question.is_scheme

func _on_ordered_pressed() -> void:
	question.is_order = !question.is_order

func _on_strict_pressed() -> void:
	question.is_strict = !question.is_strict

func _on_gap_pressed() -> void:
	question.is_gap = !question.is_gap

func _on_veracity_pressed() -> void:
	question.is_veracity = !question.is_veracity

func _on_shuffle_pressed() -> void:
	question.is_shuffle = !question.is_shuffle

func fetch_question_texts() -> PackedStringArray:
	var strings = $Items/ScrollData/Data/Question/Texts.get_children().map(func (question_row):
		return question_row.fetch()
	)
	return PackedStringArray(strings)

func _on_increase_level_pressed() -> void:
	change_level([1, 2, 3, 4, 1][question.level])

func change_level(to: int) -> void:
	question.level = to
	var tar = $Items/ScrollData/Data/Question/GloballyRelevant/IncreaseLevel/Elements/Text
	var texts = ['Beginner Level', 'Advanced Level', 'Dissertation', 'Master Level']
	tar.text = Main.data.translate(texts[to - 1])

func _on_add_tag_button_pressed() -> void:
	var text: String = $Items/ScrollData/Data/Tag/Text.text.strip_edges()
	$Items/ScrollData/Data/TagsContainer/TagsFlow.add_tag(text)
	$Items/ScrollData/Data/Tag/Text.text = ""

func on_parent_pressed(id: int) -> void:
	$Items/ScrollData/Data/ParentsContainer/ParentsFlow.add_parent(id)

func on_grid_delete_pressed(id: int) -> void:
	question.get_subject().erase_question(id)

func on_edit_pressed(id: int) -> void:
	var to_edit = question.get_subject().get_question(id)
	question = to_edit.duplicate(true)
	question.subject_id = subject_id
	var questions_difference = to_edit.question.size() - $Items/ScrollData/Data/Question/Texts.get_child_count()
	if questions_difference > 0:
		for i in range(questions_difference):
			_on_add_question_alt_pressed()
	elif questions_difference < 0:
		for i in range(questions_difference * -1):
			$Items/ScrollData/Data/Question/Texts.get_child((i * -1) -1).queue_free()
	for i in range(to_edit.question.size()):
		$Items/ScrollData/Data/Question/Texts.get_child(i).set_text(to_edit.question[i])
	
	if to_edit.has_media():
		$Items/ScrollData/Data/Question/Image.texture = to_edit.get_mediaset().images[0]
	else:
		$Items/ScrollData/Data/Question/Image.texture = null
	$Items/ScrollData/Data/Opens.replicate(to_edit.answer)
	$Items/ScrollData/Data/Choices.replicate(to_edit.choices)
	
	$Items/ScrollData/Data/ParentsContainer/ParentsFlow.replicate(to_edit.parents)
	$Items/ScrollData/Data/TagsContainer/TagsFlow.replicate(to_edit.tags)
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Open.button_pressed = to_edit.is_open
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Choice.button_pressed = to_edit.is_choice
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Match.button_pressed = to_edit.is_connect
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Table.button_pressed = to_edit.is_table
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Label.button_pressed = to_edit.is_label
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Label2.button_pressed = to_edit.is_scheme
	$Items/ScrollData/Data/Opens.visible = to_edit.is_open || to_edit.is_choice
	$Items/ScrollData/Data/Choices.visible = to_edit.is_choice
	$Items/ScrollData/Data/Match.visible = to_edit.is_connect
	$Items/ScrollData/Data/Table.visible = to_edit.is_table
	$Items/ScrollData/Data/Label.visible = to_edit.is_label
	if has_node("Items/ScrollData/Data/Scheme"):
		$Items/ScrollData/Data/Scheme.visible = to_edit.is_scheme
		$Items/ScrollData/Data/Scheme.replicate({"nodes": to_edit.scheme_nodes, "links": to_edit.scheme_links})
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Ordered.button_pressed = to_edit.is_order
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Strict.button_pressed = to_edit.is_strict
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Gap.button_pressed = to_edit.is_gap
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Veracity.button_pressed = to_edit.is_veracity
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Shuffle.button_pressed = to_edit.is_shuffle
	change_level(to_edit.level)

func fetch_data() -> void:
	var was_existing = question.id > 0 && subject.has_question(question.id)
	var original_created_at = question.created_at
	question.question = $Items/ScrollData/Data/Question/Texts.get_children().map(func (question_row): return question_row.fetch())
	if !was_existing || original_created_at <= 0:
		question.created_at = Time.get_unix_time_from_system()
	question.last_time_edited = Time.get_unix_time_from_system()
	question.answer = $Items/ScrollData/Data/Opens.fetch()
	question.choices = $Items/ScrollData/Data/Choices.fetch()
	if question.is_choice && question.choices.is_empty():
		question.sync_choices_from_answers(false)
	question.columns = $Items/ScrollData/Data/Table.fetch()
	var matches = $Items/ScrollData/Data/Match.fetch()
	question.match_a = matches["a"]
	question.match_b = matches["b"]
	question.labels = $Items/ScrollData/Data/Label.fetch()
	if has_node("Items/ScrollData/Data/Scheme"):
		var scheme = $Items/ScrollData/Data/Scheme.fetch()
		question.scheme_nodes = scheme.get("nodes", [])
		question.scheme_links = scheme.get("links", [])
	
	question.tags = $Items/ScrollData/Data/TagsContainer/TagsFlow.fetch()
	question.parents = $Items/ScrollData/Data/ParentsContainer/ParentsFlow.fetch()
	var images = [$Items/ScrollData/Data/Question/Image.texture]
	for image in images.filter(func (img): return img != null):
		question.get_or_create_mediaset().add_image(image)

func play_submit_edit_voice() -> void:
	if question.get_subject().has_question(question.id):
		$Voice.random_play("questions_edit", 1.0)
	else:
		if DirAccess.dir_exists_absolute("res://audio/voice/questions_" + str(question.get_subject().size())):
			$Voice.random_play("questions_" + str(question.get_subject().size()), 1.0)
		else:
			$Voice.random_play("questions_new", 1.0)

func _on_submit_pressed() -> void:
	might_boost(45.0)
	play_submit_edit_voice()
	fetch_data()
	# Save or Edit Question. Also edit the Subject's last time saved variable.
	if subject.has_question(question.id):
		question.save()
	else:
		question.create()
	subject = Main.data.get_subject(subject_id)
	add_question_to_container(question)
	$SFX.play_file("submit")
	$Items/ScrollData/Data/Question/Texts.get_children().map(func (child): child.reset())
	$Items/ScrollData/Data/Question/Texts.get_child(0).get_focus()
	$Items/ScrollData/Data/Question/Image.texture = null
	$Items/ScrollData/Data/Opens.reset()
	$Items/ScrollData/Data/Choices.reset()
	if has_node("Items/ScrollData/Data/Scheme"):
		$Items/ScrollData/Data/Scheme.replicate({})
		$Items/ScrollData/Data/Scheme.visible = false
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Open.button_pressed = true
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Choice.button_pressed = false
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Match.button_pressed = false
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Table.button_pressed = false
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Label.button_pressed = false
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Label2.button_pressed = false
	question.id = 0
	question = Question.new()
	question.subject_id = subject_id
	question.is_open = true
	_apply_question_filters_and_sort()

func _on_close_pressed() -> void:
	queue_free()

func _on_images_pressed() -> void:
	var img = DisplayServer.clipboard_get_image()
	$Items/ScrollData/Data/Question/Image.texture = ImageTexture.create_from_image(img)


func _on_search_bar_text_changed(new_text: String) -> void:
	relationship_filter = ""
	relationship_question_id = 0
	_apply_question_filters_and_sort()

func _setup_question_search_controls() -> void:
	var elements = $Search/Elements
	if !elements.has_node("LevelFilter"):
		var level_filter = OptionButton.new()
		level_filter.name = "LevelFilter"
		level_filter.add_item("Any Level")
		level_filter.set_item_metadata(0, 0)
		for level in range(1, 8):
			level_filter.add_item("L" + str(level))
			level_filter.set_item_metadata(level_filter.item_count - 1, level)
		level_filter.item_selected.connect(_on_question_level_filter_selected)
		elements.add_child(level_filter)
	if !elements.has_node("TypeFilter"):
		var type_filter = OptionButton.new()
		type_filter.name = "TypeFilter"
		for type in ["any", "open", "choice", "veracity", "table", "connect", "label", "scheme"]:
			type_filter.add_item(type.capitalize())
			type_filter.set_item_metadata(type_filter.item_count - 1, type)
		type_filter.item_selected.connect(_on_question_type_filter_selected)
		elements.add_child(type_filter)
	if !elements.has_node("SortFilter"):
		var sort_filter = OptionButton.new()
		sort_filter.name = "SortFilter"
		for criteria in ["last_edited", "experience_level", "level", "question"]:
			sort_filter.add_item(criteria.capitalize())
			sort_filter.set_item_metadata(sort_filter.item_count - 1, criteria)
		sort_filter.item_selected.connect(_on_question_sort_selected)
		elements.add_child(sort_filter)
	if !elements.has_node("SortDirection"):
		var direction = OptionButton.new()
		direction.name = "SortDirection"
		direction.add_item("Descending")
		direction.set_item_metadata(0, false)
		direction.add_item("Ascending")
		direction.set_item_metadata(1, true)
		direction.item_selected.connect(_on_question_sort_direction_selected)
		elements.add_child(direction)

func _on_question_level_filter_selected(index: int) -> void:
	question_filter_level = int($Search/Elements/LevelFilter.get_item_metadata(index))
	_apply_question_filters_and_sort()

func _on_question_type_filter_selected(index: int) -> void:
	question_filter_type = str($Search/Elements/TypeFilter.get_item_metadata(index))
	_apply_question_filters_and_sort()

func _on_question_sort_selected(index: int) -> void:
	question_sort_criteria = str($Search/Elements/SortFilter.get_item_metadata(index))
	_apply_question_filters_and_sort()

func _on_question_sort_direction_selected(index: int) -> void:
	question_sort_ascending = bool($Search/Elements/SortDirection.get_item_metadata(index))
	_apply_question_filters_and_sort()

func on_show_parents_pressed(id: int) -> void:
	relationship_filter = "parents"
	relationship_question_id = id
	_apply_question_filters_and_sort()

func on_show_children_pressed(id: int) -> void:
	relationship_filter = "children"
	relationship_question_id = id
	_apply_question_filters_and_sort()

func _apply_question_filters_and_sort() -> void:
	var container = $QuestionsScroll/QuestionsContainer
	var cards = container.get_children()
	cards.sort_custom(func(card_a, card_b):
		var question_a = subject.get_question(int(card_a.id))
		var question_b = subject.get_question(int(card_b.id))
		if question_a == null || question_b == null:
			return false
		var comparison = _compare_questions(question_a, question_b)
		return comparison < 0 if question_sort_ascending else comparison > 0
	)
	for index in range(cards.size()):
		container.move_child(cards[index], index)
	for card in cards:
		card.visible = _question_matches_filters(subject.get_question(int(card.id)))

func _question_matches_filters(saved_question: Question) -> bool:
	if saved_question == null:
		return false
	var search = $Search/Elements/SearchBar.text.strip_edges()
	if search != "":
		var text_match = saved_question.question.size() > 0 && str(saved_question.question[0]).containsn(search)
		var tag_match = saved_question.tags.any(func(tag): return str(tag).containsn(search))
		if !text_match && !tag_match:
			return false
	if question_filter_level > 0 && saved_question.level != question_filter_level:
		return false
	if question_filter_type != "any" && !saved_question.get_types().has(question_filter_type):
		return false
	if relationship_filter == "parents":
		var source = subject.get_question(relationship_question_id)
		return source != null && source.parents.has(saved_question.id)
	if relationship_filter == "children":
		return saved_question.parents.has(relationship_question_id)
	return true

func _compare_questions(question_a: Question, question_b: Question) -> int:
	var a
	var b
	match question_sort_criteria:
		"experience_level":
			a = question_a.experience_level
			b = question_b.experience_level
		"level":
			a = question_a.level
			b = question_b.level
		"question":
			a = str(question_a.question[0]) if question_a.question.size() > 0 else ""
			b = str(question_b.question[0]) if question_b.question.size() > 0 else ""
		_:
			a = question_a.last_time_edited
			b = question_b.last_time_edited
	if a == b:
		return question_a.id - question_b.id
	if a is String:
		return a.naturalnocasecmp_to(b)
	return 1 if a > b else -1
