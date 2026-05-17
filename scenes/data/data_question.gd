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

var might_mode:= false
var question_filter_level:= 0
var question_filter_type:= "any"
var question_sort_criteria:= "last_edited"
var question_sort_ascending:= false
var relationship_filter:= ""
var relationship_question_id:= 0
@onready var synonym_hint: Label = $Items/ScrollData/Data/Question/SynonymHint
@onready var subject_synonyms_editor: PanelContainer = $Items/ScrollData/Data/SubjectSynonyms
var question_load_generation:= 0
var pending_media_row: Node
var loading_subject_synonyms:= false

func _ready() -> void:
	question.subject_id = subject_id
	subject = Main.data.get_subject(subject_id) if subject_id > 0 else null
	$SubjectBar/Title.text = title
	$Items/ScrollData/Data/Opens.row_media_requested.connect(_on_answer_media_requested)
	$Items/ScrollData/Data/Choices.row_media_requested.connect(_on_answer_media_requested)
	_ensure_extra_parameter_buttons()
	_ensure_synonym_hint()
	_setup_subject_synonym_editor()
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

func _exit_tree() -> void:
	_save_subject_synonyms()

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
	question.is_open = true
	question.is_choice = false
	question.is_connect = false
	question.is_table = false
	question.is_label = false
	question.is_scheme = false
	_sync_type_ui()
	_update_synonym_hint()

func set_container() -> void:
	if subject == null:
		return
	question_load_generation += 1
	var generation = question_load_generation
	var container_node = $QuestionsScroll/QuestionsContainer
	for child in container_node.get_children():
		child.queue_free()
	$SubjectBar/AmountBar/Amount.text = "00"
	Main.question_list_loading_started.emit(subject_id)
	for question_filename in subject.get_question_file_names(true):
		if generation != question_load_generation:
			return
		var saved_question = ResourceLoader.load(subject.get_question_file_path(question_filename), "", ResourceLoader.CACHE_MODE_REPLACE) as Question
		if saved_question != null:
			add_question_to_container(saved_question, false)
		await get_tree().process_frame
	_apply_question_filters_and_sort()
	Main.question_list_loading_finished.emit(subject_id)

func add_question_to_container(saved_question: Question, apply_filters:= true) -> void:
	var question_to_add
	var container_node = $QuestionsScroll/QuestionsContainer
	var is_new_card:= false
	if container_node.has_node(str(saved_question.id)):
		question_to_add = container_node.get_node(str(saved_question.id))
	else:
		is_new_card = true
		question_to_add = saved_question_packed_scene.instantiate()
		question_to_add.parent_pressed.connect(on_parent_pressed)
		question_to_add.edit_pressed.connect(on_edit_pressed)
		question_to_add.delete_pressed.connect(on_grid_delete_pressed)
		if question_to_add.has_signal("show_parents_pressed"):
			question_to_add.show_parents_pressed.connect(on_show_parents_pressed)
		if question_to_add.has_signal("show_children_pressed"):
			question_to_add.show_children_pressed.connect(on_show_children_pressed)
		question_to_add.name = str(saved_question.id)
	if question_to_add.has_method("set_question_data"):
		question_to_add.set_question_data(saved_question)
	else:
		question_to_add.id = saved_question.id
		question_to_add.set_text(saved_question.question[0])
		question_to_add.set_level(saved_question.experience_level)
	if is_new_card:
		container_node.add_child(question_to_add)
	elif apply_filters:
		container_node.move_child(question_to_add, 0)
	$SubjectBar/AmountBar/Amount.text = str(container_node.get_child_count()).lpad(2, '0')
	if apply_filters:
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
	_set_type_from_buttons("open")

func _on_choice_pressed() -> void:
	_set_type_from_buttons("choice")

func _on_match_pressed() -> void:
	_set_type_from_buttons("connect")

func _on_table_pressed() -> void:
	_set_type_from_buttons("table")

func _on_label_pressed() -> void:
	_set_type_from_buttons("label")

func _on_scheme_pressed() -> void:
	_set_type_from_buttons("scheme")

func _on_ordered_pressed() -> void:
	question.is_order = $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Ordered.button_pressed
	$Items/ScrollData/Data/Opens.is_order_enabled = question.is_order
	if question.is_order:
		$Items/ScrollData/Data/Opens.show_orders()
	else:
		$Items/ScrollData/Data/Opens.hide_orders()
	_sync_parameter_visibility()

func _on_strict_pressed() -> void:
	question.is_strict = $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Strict.button_pressed
	_sync_parameter_visibility()

func _on_gap_pressed() -> void:
	question.is_gap = $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Gap.button_pressed
	_sync_parameter_visibility()

func _on_veracity_pressed() -> void:
	question.is_veracity = $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Veracity.button_pressed
	_sync_parameter_visibility()

func _on_shuffle_pressed() -> void:
	question.is_shuffle = $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Shuffle.button_pressed
	_sync_parameter_visibility()

func _on_shuffle_rows_pressed() -> void:
	question.shuffle_rows = $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/ShuffleRows.button_pressed
	_sync_parameter_visibility()

func _on_shuffle_columns_pressed() -> void:
	question.shuffle_columns = $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/ShuffleColumns.button_pressed
	_sync_parameter_visibility()

func fetch_question_texts() -> PackedStringArray:
	var strings = $Items/ScrollData/Data/Question/Texts.get_children().map(func (question_row):
		return question_row.fetch()
	)
	return PackedStringArray(strings)

func _ensure_extra_parameter_buttons() -> void:
	return

func _ensure_synonym_hint() -> void:
	return

func _update_synonym_hint() -> void:
	_ensure_synonym_hint()
	synonym_hint.visible = question.id > 0 && Main.data.question_has_synonyms(question)

func _setup_subject_synonym_editor() -> void:
	if subject_synonyms_editor == null:
		return
	if !subject_synonyms_editor.groups_changed.is_connected(_on_subject_synonyms_changed):
		subject_synonyms_editor.groups_changed.connect(_on_subject_synonyms_changed)
	_load_subject_synonyms()

func _load_subject_synonyms() -> void:
	if subject_synonyms_editor == null:
		return
	loading_subject_synonyms = true
	if subject == null:
		subject_synonyms_editor.setup("Subject Synonyms", "This subject has no synonym groups yet.")
		subject_synonyms_editor.set_groups([])
	else:
		subject_synonyms_editor.setup(subject.title + " Synonyms", "This subject has no synonym groups yet.")
		subject_synonyms_editor.set_groups(subject.synonym_groups)
	loading_subject_synonyms = false

func _save_subject_synonyms() -> bool:
	if subject_synonyms_editor == null || subject_id <= 0:
		return true
	if subject_synonyms_editor.has_method("submit_pending_group_if_any") && !subject_synonyms_editor.submit_pending_group_if_any():
		return false
	if subject_synonyms_editor.has_method("can_save") && !subject_synonyms_editor.can_save():
		return false
	var selected_subject = Main.data.get_subject(subject_id)
	if selected_subject == null:
		return true
	var synonym_groups = subject_synonyms_editor.get_synonym_groups()
	if selected_subject.synonym_groups == synonym_groups:
		return true
	selected_subject.synonym_groups = synonym_groups
	selected_subject.save()
	subject = selected_subject
	return true

func _on_subject_synonyms_changed(groups: Array) -> void:
	if loading_subject_synonyms || subject_id <= 0:
		return
	var selected_subject = Main.data.get_subject(subject_id)
	if selected_subject == null:
		return
	selected_subject.synonym_groups = groups
	selected_subject.save()
	subject = selected_subject
	_update_synonym_hint()

func _on_increase_level_pressed() -> void:
	change_level([1, 2, 3, 4, 1][question.level])

func change_level(to: int) -> void:
	question.level = to
	var tar = $Items/ScrollData/Data/Question/GloballyRelevant/IncreaseLevel/Elements/Text
	var texts = ['Beginner Level', 'Advanced Level', 'Dissertation', 'Master Level']
	tar.text = Main.data.translate(texts[to - 1])

func _set_type_from_buttons(changed_type: String) -> void:
	var type_buttons = $Items/ScrollData/Data/Types/M/VBoxContainer/Types
	question.is_open = type_buttons.get_node("Open").button_pressed
	question.is_choice = type_buttons.get_node("Choice").button_pressed
	question.is_connect = type_buttons.get_node("Match").button_pressed
	question.is_table = type_buttons.get_node("Table").button_pressed
	question.is_label = type_buttons.get_node("Label").button_pressed
	question.is_scheme = type_buttons.get_node("Label2").button_pressed
	if ["connect", "table", "label", "scheme"].has(changed_type) && _button_for_type(changed_type).button_pressed:
		question.is_open = false
		question.is_choice = false
		question.is_connect = changed_type == "connect"
		question.is_table = changed_type == "table"
		question.is_label = changed_type == "label"
		question.is_scheme = changed_type == "scheme"
	elif ["open", "choice"].has(changed_type) && _button_for_type(changed_type).button_pressed:
		question.is_connect = false
		question.is_table = false
		question.is_label = false
		question.is_scheme = false
	question.enforce_type_rules()
	_sync_type_ui()

func _button_for_type(type: String) -> Button:
	var type_buttons = $Items/ScrollData/Data/Types/M/VBoxContainer/Types
	match type:
		"open":
			return type_buttons.get_node("Open")
		"choice":
			return type_buttons.get_node("Choice")
		"connect":
			return type_buttons.get_node("Match")
		"table":
			return type_buttons.get_node("Table")
		"label":
			return type_buttons.get_node("Label")
	return type_buttons.get_node("Label2")

func _sync_type_ui() -> void:
	var type_buttons = $Items/ScrollData/Data/Types/M/VBoxContainer/Types
	type_buttons.get_node("Open").button_pressed = question.is_open
	type_buttons.get_node("Choice").button_pressed = question.is_choice
	type_buttons.get_node("Match").button_pressed = question.is_connect
	type_buttons.get_node("Table").button_pressed = question.is_table
	type_buttons.get_node("Label").button_pressed = question.is_label
	type_buttons.get_node("Label2").button_pressed = question.is_scheme
	$Items/ScrollData/Data/Opens.visible = question.is_open || question.is_choice
	$Items/ScrollData/Data/Choices.visible = question.is_choice
	$Items/ScrollData/Data/Opens.set_media_buttons_enabled(question.is_choice)
	$Items/ScrollData/Data/Choices.set_media_buttons_enabled(question.is_choice)
	$Items/ScrollData/Data/Match.visible = question.is_connect
	$Items/ScrollData/Data/Table.visible = question.is_table
	$Items/ScrollData/Data/Label.visible = question.is_label
	if has_node("Items/ScrollData/Data/Scheme"):
		$Items/ScrollData/Data/Scheme.visible = question.is_scheme
	_sync_parameter_visibility()

func _sync_parameter_visibility() -> void:
	question.enforce_type_rules()
	var parameters = $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters
	var allowed = question.get_allowed_parameters()
	var nodes = {
		"order": parameters.get_node("Ordered"),
		"strict": parameters.get_node("Strict"),
		"gap": parameters.get_node("Gap"),
		"veracity": parameters.get_node("Veracity"),
		"shuffle": parameters.get_node("Shuffle"),
		"shuffle_rows": parameters.get_node("ShuffleRows") if parameters.has_node("ShuffleRows") else null,
		"shuffle_columns": parameters.get_node("ShuffleColumns") if parameters.has_node("ShuffleColumns") else null,
	}
	for parameter in nodes.keys():
		var node = nodes[parameter]
		if node == null:
			continue
		node.visible = allowed.has(parameter)
		if !node.visible:
			node.button_pressed = false
	parameters.get_node("Ordered").button_pressed = question.is_order
	parameters.get_node("Strict").button_pressed = question.is_strict
	parameters.get_node("Gap").button_pressed = question.is_gap
	parameters.get_node("Veracity").button_pressed = question.is_veracity
	parameters.get_node("Shuffle").button_pressed = question.is_shuffle
	if parameters.has_node("ShuffleRows"):
		parameters.get_node("ShuffleRows").button_pressed = question.shuffle_rows
	if parameters.has_node("ShuffleColumns"):
		parameters.get_node("ShuffleColumns").button_pressed = question.shuffle_columns
	$Items/ScrollData/Data/Opens.is_order_enabled = question.is_order
	if question.is_order:
		$Items/ScrollData/Data/Opens.show_orders()
	else:
		$Items/ScrollData/Data/Opens.hide_orders()

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
		var mediaset = to_edit.get_mediaset()
		$Items/ScrollData/Data/Question/Image.texture = mediaset.images[0] if mediaset != null && !mediaset.images.is_empty() else null
		$Items/ScrollData/Data/Opens.set_mediaset(mediaset)
		$Items/ScrollData/Data/Choices.set_mediaset(mediaset)
	else:
		$Items/ScrollData/Data/Question/Image.texture = null
		$Items/ScrollData/Data/Opens.set_mediaset(null)
		$Items/ScrollData/Data/Choices.set_mediaset(null)
	$Items/ScrollData/Data/Opens.replicate(to_edit.answer)
	$Items/ScrollData/Data/Choices.replicate(_get_choice_decoys(to_edit.choices))
	
	$Items/ScrollData/Data/ParentsContainer/ParentsFlow.replicate(to_edit.parents)
	$Items/ScrollData/Data/TagsContainer/TagsFlow.replicate(to_edit.tags)
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Open.button_pressed = to_edit.is_open
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Choice.button_pressed = to_edit.is_choice
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Match.button_pressed = to_edit.is_connect
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Table.button_pressed = to_edit.is_table
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Label.button_pressed = to_edit.is_label
	$Items/ScrollData/Data/Types/M/VBoxContainer/Types/Label2.button_pressed = to_edit.is_scheme
	$Items/ScrollData/Data/Opens.is_order_enabled = to_edit.is_order
	if has_node("Items/ScrollData/Data/Scheme"):
		$Items/ScrollData/Data/Scheme.replicate({"nodes": to_edit.scheme_nodes, "links": to_edit.scheme_links})
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Ordered.button_pressed = to_edit.is_order
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Strict.button_pressed = to_edit.is_strict
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Gap.button_pressed = to_edit.is_gap
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Veracity.button_pressed = to_edit.is_veracity
	$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/Shuffle.button_pressed = to_edit.is_shuffle
	if $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters.has_node("ShuffleRows"):
		$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/ShuffleRows.button_pressed = to_edit.shuffle_rows
	if $Items/ScrollData/Data/Types/M/VBoxContainer/Parameters.has_node("ShuffleColumns"):
		$Items/ScrollData/Data/Types/M/VBoxContainer/Parameters/ShuffleColumns.button_pressed = to_edit.shuffle_columns
	change_level(to_edit.level)
	_sync_type_ui()
	_update_synonym_hint()

func fetch_data() -> void:
	var was_existing = question.id > 0 && subject.has_question(question.id)
	var original_created_at = question.created_at
	question.question = $Items/ScrollData/Data/Question/Texts.get_children().map(func (question_row): return question_row.fetch())
	if !was_existing || original_created_at <= 0:
		question.created_at = Time.get_unix_time_from_system()
	question.last_time_edited = Time.get_unix_time_from_system()
	question.answer = $Items/ScrollData/Data/Opens.fetch()
	question.choices = $Items/ScrollData/Data/Choices.fetch()
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
	question.enforce_type_rules()
	var images = [$Items/ScrollData/Data/Question/Image.texture]
	for image in images.filter(func (img): return img != null):
		question.get_or_create_mediaset().add_image(image)
	var mediaset = question.get_mediaset()
	$Items/ScrollData/Data/Opens.set_mediaset(mediaset)
	$Items/ScrollData/Data/Choices.set_mediaset(mediaset)

func _get_choice_decoys(choice_entries) -> Array:
	if choice_entries == null:
		return []
	return choice_entries.filter(func(choice):
		return choice is Dictionary && !bool(choice.get("veracity", false))
	)

func play_submit_edit_voice() -> void:
	if question.get_subject().has_question(question.id):
		$Voice.random_play("questions_edit", 1.0)
	else:
		if DirAccess.dir_exists_absolute("res://audio/voice/questions_" + str(question.get_subject().size())):
			$Voice.random_play("questions_" + str(question.get_subject().size()), 1.0)
		else:
			$Voice.random_play("questions_new", 1.0)

func _on_submit_pressed() -> void:
	_save_subject_synonyms()
	might_boost(45.0)
	play_submit_edit_voice()
	fetch_data()
	# Save or Edit Question. Also edit the Subject's last time saved variable.
	subject = Main.data.get_subject(subject_id)
	if subject.has_question(question.id):
		question.save()
	else:
		question.create()
	add_question_to_container(question)
	$SFX.play_file("submit")
	$Items/ScrollData/Data/Question/Texts.get_children().map(func (child): child.reset())
	$Items/ScrollData/Data/Question/Texts.get_child(0).get_focus()
	$Items/ScrollData/Data/Question/Image.texture = null
	$Items/ScrollData/Data/Opens.reset()
	$Items/ScrollData/Data/Choices.reset()
	$Items/ScrollData/Data/Opens.set_mediaset(null)
	$Items/ScrollData/Data/Choices.set_mediaset(null)
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
	_sync_type_ui()
	_update_synonym_hint()
	_apply_question_filters_and_sort()

func _on_close_pressed() -> void:
	if !_save_subject_synonyms():
		return
	queue_free()

func _on_images_pressed() -> void:
	var img = DisplayServer.clipboard_get_image()
	if img == null || img.is_empty():
		return
	$Items/ScrollData/Data/Question/Image.texture = ImageTexture.create_from_image(img)

func _on_media_file_button_pressed() -> void:
	pending_media_row = null
	$MediaFileDialog.popup_centered_ratio(0.72)

func _on_answer_media_requested(row: Node) -> void:
	pending_media_row = row
	$MediaFileDialog.popup_centered_ratio(0.72)

func _on_media_file_selected(path: String) -> void:
	var ref = _add_media_file_to_question(path)
	if ref.is_empty():
		return
	var mediaset = question.get_mediaset()
	$Items/ScrollData/Data/Opens.set_mediaset(mediaset)
	$Items/ScrollData/Data/Choices.set_mediaset(mediaset)
	if pending_media_row != null && is_instance_valid(pending_media_row):
		pending_media_row.set_mediaset(mediaset)
		pending_media_row.add_media_ref(ref)
	else:
		var media = mediaset.get_media(ref) if mediaset != null else null
		if media is Texture2D:
			$Items/ScrollData/Data/Question/Image.texture = media
	pending_media_row = null

func _add_media_file_to_question(path: String) -> Dictionary:
	var mediaset = question.get_or_create_mediaset()
	var media = ResourceLoader.load(path) if path.begins_with("res://") || path.begins_with("user://") else null
	if media is Texture2D:
		return mediaset.add_image(media)
	if media is AudioStream:
		return mediaset.add_sound(media)
	if media is VideoStream:
		return mediaset.add_video(media)
	var extension = path.get_extension().to_lower()
	if ["png", "jpg", "jpeg", "webp", "bmp", "tga", "svg"].has(extension):
		var image = Image.new()
		if image.load(path) == OK:
			return mediaset.add_image(ImageTexture.create_from_image(image))
	if extension == "ogg":
		return mediaset.add_sound(AudioStreamOggVorbis.load_from_file(path))
	if extension == "mp3":
		return mediaset.add_sound(AudioStreamMP3.load_from_file(path))
	if extension == "wav":
		return mediaset.add_sound(AudioStreamWAV.load_from_file(path))
	return {}


func _on_search_bar_text_changed(new_text: String) -> void:
	relationship_filter = ""
	relationship_question_id = 0
	_apply_question_filters_and_sort()

func _setup_question_search_controls() -> void:
	var elements = $Search/Elements
	var sort_filter: OptionButton = elements.get_node("SortFilter")
	sort_filter.clear()
	for criteria in ["last_edited", "experience_level", "level", "question"]:
		sort_filter.add_item(criteria.capitalize())
		sort_filter.set_item_metadata(sort_filter.item_count - 1, criteria)
	var direction: OptionButton = elements.get_node("SortDirection")
	direction.clear()
	direction.add_item("Descending")
	direction.set_item_metadata(0, false)
	direction.add_item("Ascending")
	direction.set_item_metadata(1, true)

func _on_question_level_filter_selected(index: int) -> void:
	_apply_question_filters_and_sort()

func _on_question_type_filter_selected(index: int) -> void:
	_apply_question_filters_and_sort()

func _on_question_sort_selected(index: int) -> void:
	question_sort_criteria = str($Search/Elements/SortFilter.get_item_metadata(index))
	_apply_question_filters_and_sort()

func _on_question_sort_direction_selected(index: int) -> void:
	question_sort_ascending = bool($Search/Elements/SortDirection.get_item_metadata(index))
	_apply_question_filters_and_sort()

func on_show_parents_pressed(id: int) -> void:
	relationship_filter = ""
	relationship_question_id = 0
	_apply_question_filters_and_sort()

func on_show_children_pressed(id: int) -> void:
	relationship_filter = ""
	relationship_question_id = 0
	_apply_question_filters_and_sort()

func _apply_question_filters_and_sort() -> void:
	var container = $QuestionsScroll/QuestionsContainer
	var cards = container.get_children()
	cards.sort_custom(func(card_a, card_b):
		var comparison = _compare_question_cards(card_a, card_b)
		return comparison < 0 if question_sort_ascending else comparison > 0
	)
	for index in range(cards.size()):
		container.move_child(cards[index], index)
	for card in cards:
		card.visible = _question_card_matches_filters(card)

func _question_card_matches_filters(card: Node) -> bool:
	var search = $Search/Elements/SearchBar.text.strip_edges()
	if search != "":
		return str(card.question_text).containsn(search)
	return true

func _compare_question_cards(card_a: Node, card_b: Node) -> int:
	var a
	var b
	match question_sort_criteria:
		"experience_level":
			a = card_a.experience_level
			b = card_b.experience_level
		"level":
			a = card_a.question_level
			b = card_b.question_level
		"question":
			a = card_a.question_text
			b = card_b.question_text
		_:
			a = card_a.last_time_edited
			b = card_b.last_time_edited
	if a == b:
		return card_a.id - card_b.id
	if a is String:
		return a.naturalnocasecmp_to(b)
	return 1 if a > b else -1

func _has_default_question_filters() -> bool:
	return $Search/Elements/SearchBar.text.strip_edges() == ""
