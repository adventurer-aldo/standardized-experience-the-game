extends HBoxContainer

signal row_count_changed
signal row_media_requested(row: Node)

@export var row_scene: PackedScene
@export var start_with_row_included:= true
@export var choice_mode:= false
@export var true_veracity:= false
var is_order_enabled:= false
var media_buttons_enabled:= false
var mediaset: Mediaset

func _ready() -> void:
	if start_with_row_included: _on_add_answer_pressed()

func _on_row_delete_pressed() -> void:
	row_count_changed.emit()

func _on_add_answer_pressed() -> void:
	var new_row = row_scene.instantiate()
	if !true_veracity && choice_mode: new_row.to_decoy()
	if is_order_enabled: new_row.show_order()
	new_row.set_media_buttons_enabled(media_buttons_enabled)
	new_row.set_mediaset(mediaset)
	new_row.add_media_pressed.connect(_on_row_add_media_pressed)
	$Rows.add_child(new_row)
	new_row.get_focus()

func show_orders() -> void:
	$Rows.get_children().map(func (row): row.show_order())

func hide_orders() -> void:
	$Rows.get_children().map(func (row): row.hide_order())

func fetch(as_choices:= choice_mode, veracity:= true_veracity) -> Array:
	if as_choices:
		return $Rows.get_children().map(func (row): 
			return {"texts": row.fetch(), "veracity": veracity, "media": row.fetch_media_refs()}
		)
	else:
		return $Rows.get_children().map(func (row): return row.fetch())

func reset(full:= false):
	$Rows.get_children().map(func (row):
		if row.get_index() != 0: row.queue_free()
		row.reset(full)
	)

func replicate(array: Array) -> void:
	var difference = array.size() - $Rows.get_child_count()
	if difference > 0:
		for i in range(difference):
			_on_add_answer_pressed()
	elif difference < 0:
		for i in range((difference) * -1):
			$Rows.get_child((i * -1) -1).queue_free()
	for i in range(array.size()):
		$Rows.get_child(i).replicate(array[i])

func set_media_buttons_enabled(enabled: bool) -> void:
	media_buttons_enabled = enabled
	for row in $Rows.get_children():
		row.set_media_buttons_enabled(enabled)

func set_mediaset(new_mediaset: Mediaset) -> void:
	mediaset = new_mediaset
	for row in $Rows.get_children():
		row.set_mediaset(new_mediaset)

func _on_row_add_media_pressed(row: Node) -> void:
	row_media_requested.emit(row)
