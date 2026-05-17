class_name QuizAttemptBase
extends VBoxContainer

signal add_to_might(value: int)

@export var edit_shortcut: PackedScene

var question: Question
var question_id:= 0
var media_container: VBoxContainer
var image_rect: TextureRect
var number_label: Label
var description_label: Label
var body: VBoxContainer
var result_label: Label
var edit_button: Button

func _ready() -> void:
	_ensure_layout()
	if !resized.is_connected(_resize_question_image):
		resized.connect(_resize_question_image)
	_resize_question_image.call_deferred()

func prepare(with_question: Question) -> void:
	question = with_question
	question_id = question.id
	_ensure_layout()
	_set_image()
	_set_description(question.get_display_question())
	_clear_body()
	_build_attempt_controls()
	result_label.hide()
	edit_button.hide()

func fetch() -> Array:
	return []

func solve() -> bool:
	var result = question.check_attempt(fetch())
	_show_checked_result(result)
	edit_button.show()
	return bool(result.get("correct", false))

func edit() -> void:
	if edit_shortcut == null || question == null:
		return
	var edit_scene = edit_shortcut.instantiate()
	edit_scene.subject_id = question.subject_id
	edit_scene.silence = true
	add_child(edit_scene)
	edit_scene.on_edit_pressed(question.id)

func _build_attempt_controls() -> void:
	pass

func _show_checked_result(result: Dictionary) -> void:
	result_label.text = "Correct" if bool(result.get("correct", false)) else "Wrong"
	result_label.add_theme_color_override("font_color", Color(0.05, 0.42, 0.12) if bool(result.get("correct", false)) else Color(0.72, 0.05, 0.07))
	result_label.show()

func _set_description(text: String) -> void:
	if question != null && (question.is_ambush || question.is_rush):
		number_label.text = "X. "
	else:
		number_label.text = str(question.attempt_index + 1) + ". " if question != null else ""
	description_label.text = text

func _set_image() -> void:
	for child in media_container.get_children():
		if child != image_rect:
			child.queue_free()
	image_rect.texture = null
	image_rect.visible = false
	if question != null && question.has_media():
		var mediaset = question.get_mediaset()
		if mediaset != null:
			if !mediaset.images.is_empty():
				image_rect.texture = mediaset.images[0]
				_configure_texture_rect(image_rect, mediaset.images[0])
				image_rect.visible = true
				_resize_question_image.call_deferred()
			for sound in mediaset.sounds:
				media_container.add_child(_make_sound_button(sound))
			for video in mediaset.videos:
				media_container.add_child(_make_video_player(video))
	media_container.visible = image_rect.visible || media_container.get_child_count() > 1

func _configure_texture_rect(rect: TextureRect, texture: Texture2D, maximum_width:= 720.0) -> void:
	if texture == null:
		return
	var texture_size = texture.get_size()
	if texture_size.x <= 0.0:
		return
	var available_width = _available_texture_width(rect, maximum_width)
	var width = min(texture_size.x, available_width)
	var image_scale = width / texture_size.x
	rect.custom_minimum_size = Vector2(width, texture_size.y * image_scale)
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func _available_texture_width(rect: TextureRect, maximum_width: float) -> float:
	var available_width = maximum_width
	var parent_node = rect.get_parent()
	while parent_node != null:
		if parent_node is Control && parent_node.size.x > 1.0:
			available_width = min(available_width, parent_node.size.x)
			break
		parent_node = parent_node.get_parent()
	if available_width <= 1.0:
		available_width = min(maximum_width, max(1.0, get_viewport_rect().size.x))
	return available_width

func _resize_question_image() -> void:
	if image_rect != null && image_rect.texture != null:
		_configure_texture_rect(image_rect, image_rect.texture)

func _make_media_strip(media_refs: Array) -> VBoxContainer:
	var strip = VBoxContainer.new()
	strip.name = "ChoiceMedia"
	strip.add_theme_constant_override("separation", 6)
	strip.visible = false
	var mediaset = question.get_mediaset() if question != null else null
	if mediaset == null:
		return strip
	for ref in media_refs:
		if !(ref is Dictionary):
			continue
		var media = mediaset.get_media(ref)
		var control = _make_media_control(media)
		if control != null:
			strip.add_child(control)
	strip.visible = strip.get_child_count() > 0
	return strip

func _make_media_control(media) -> Control:
	if media is Texture2D:
		var rect = TextureRect.new()
		rect.texture = media
		_configure_texture_rect(rect, media, 480.0)
		return rect
	if media is AudioStream:
		return _make_sound_button(media)
	if media is VideoStream:
		return _make_video_player(media)
	return null

func _make_sound_button(stream: AudioStream) -> Button:
	var button = Button.new()
	button.text = "Play Sound"
	button.custom_minimum_size = Vector2(160, 34)
	var player = AudioStreamPlayer.new()
	player.stream = stream
	button.add_child(player)
	button.pressed.connect(player.play)
	return button

func _make_video_player(stream: VideoStream) -> VideoStreamPlayer:
	var player = VideoStreamPlayer.new()
	player.stream = stream
	player.custom_minimum_size = Vector2(480, 270)
	player.expand = true
	return player

func _clear_body() -> void:
	for child in body.get_children():
		child.queue_free()

func _ensure_layout() -> void:
	if body != null && is_instance_valid(body):
		return
	if has_node("Shell/Margin/Content/Body"):
		media_container = $Shell/Margin/Content/QuestionMedia
		image_rect = $Shell/Margin/Content/QuestionMedia/Image
		number_label = $Shell/Margin/Content/ID/Number
		description_label = $Shell/Margin/Content/ID/Description
		body = $Shell/Margin/Content/Body
		result_label = $Shell/Margin/Content/Result
		edit_button = $Shell/Margin/Content/Edit
		return
	push_error("Quiz attempt scene is missing its editor-visible base layout.")

func _make_option_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(160, 36)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
