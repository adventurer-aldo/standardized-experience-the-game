extends HBoxContainer

signal delete_pressed(index)
signal add_media_pressed(row: Node)

@export var alt_scene: PackedScene
@export var is_decoy:= false
var media_refs: Array = []
var mediaset: Mediaset

func to_decoy() -> void:
		$Answer/Set/Text.placeholder_text = "A wrong answer to that question."

func _on_add_alt_pressed() -> void:
	var new_alt = alt_scene.instantiate()
	if is_decoy: new_alt.to_decoy()
	$Answer/Alts.add_child(new_alt)
	new_alt.get_focus()

func _on_delete_answer_pressed() -> void:
	delete_pressed.emit(get_index())
	if get_parent().get_child_count() > 1:
		queue_free()
	elif get_parent().get_child_count() == 1:
		clean()

func should_delete_hide() -> void:
	if get_parent().get_child_count() > 1:
		$Answer/Set/DeleteAnswer.show()
	else:
		$Answer/Set/DeleteAnswer.hide()

func clean():
	$Answer/Set/Text.text = ""
	media_refs = []
	_refresh_media_preview()

func fetch() -> Array:
	var main = $Answer/Set/Text.text
	return [main] + $Answer/Alts.get_children().map(func (alt): return alt.fetch())

func fetch_media_refs() -> Array:
	return media_refs.duplicate(true)

func set_media_buttons_enabled(enabled: bool) -> void:
	$Answer/Set/AddMedia.visible = enabled

func set_mediaset(new_mediaset: Mediaset) -> void:
	mediaset = new_mediaset
	_refresh_media_preview()

func add_media_ref(ref: Dictionary) -> void:
	if ref.is_empty():
		return
	media_refs.push_back(ref.duplicate(true))
	_refresh_media_preview()

func replicate(value) -> void:
	var array: Array
	media_refs = []
	if value is Dictionary:
		array = Array(value.get("texts", []))
		media_refs = Array(value.get("media", [])).duplicate(true)
	else:
		array = Array(value)
	if array.is_empty():
		array = [""]
	$Answer/Set/Text.text = array[0]
	var alts = array.duplicate()
	alts.remove_at(0)
	var difference = alts.size() - $Answer/Alts.get_child_count()
	print("The difference of alts is {diff}".format({"diff": difference}))
	if difference > 0:
		for i in range(difference):
			_on_add_alt_pressed()
	elif difference < 0:
		for i in range(difference * -1):
			$Answer/Alts.get_child((i * -1) -1).queue_free()
	for i in range(alts.size()):
		$Answer/Alts.get_child(i).set_text(alts[i])
	_refresh_media_preview()

func show_order() -> void:
	$Answer/Set/Text/Order.show()
	$Answer/Set/Text/Order/Text.text = str(get_index() + 1)

func hide_order() -> void:
	$Answer/Set/Text/Order.hide()

func get_focus() -> void:
	$Answer/Set/Text.grab_focus()

func reset(full:= false) -> void:
	$Answer/Set/Text.text = ""
	media_refs = []
	_refresh_media_preview()
	if full:
		$Answer/Alts.get_children().map(func (child): child.queue_free())
	else:
		$Answer/Alts.get_children().map(func (child): child.reset())

func _on_add_media_pressed() -> void:
	add_media_pressed.emit(self)

func _refresh_media_preview() -> void:
	var preview = $Answer/MediaPreview
	for child in preview.get_children():
		child.queue_free()
	preview.visible = !media_refs.is_empty()
	for ref in media_refs:
		if !(ref is Dictionary):
			continue
		var media = mediaset.get_media(ref) if mediaset != null else null
		if media is Texture2D:
			preview.add_child(_make_image_preview(media))
		elif media is AudioStream:
			var label = Label.new()
			label.text = "Sound"
			preview.add_child(label)
		elif media is VideoStream:
			var label = Label.new()
			label.text = "Video"
			preview.add_child(label)

func _make_image_preview(texture: Texture2D) -> TextureRect:
	var rect = TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var image_size = texture.get_size()
	var width = min(image_size.x, 180.0)
	var scale = width / max(1.0, image_size.x)
	rect.custom_minimum_size = Vector2(width, image_size.y * scale)
	return rect
