extends VBoxContainer

signal parent_pressed(id: int)
signal edit_pressed(id: int)
signal delete_pressed(id: int)
signal show_parents_pressed(id: int)
signal show_children_pressed(id: int)

var id:= 0

func _ready() -> void:
	set_id(id)
	_ensure_relationship_buttons()

func get_text() -> String:
	return $MainText.text

func set_text(to: String):
	$MainText.text = to

func set_id(to: int):
	id = to
	$Buttons/ID.text = str(to)

func set_level(to: int) -> void:
	$Buttons/Level.text = "Lv. " + str(to)

func set_types(types: Array) -> void:
	set_meta("types", types)

func _on_parent_pressed() -> void:
	parent_pressed.emit(id)

func _on_delete_pressed() -> void:
	delete_pressed.emit(id)
	queue_free()

func _on_edit_pressed() -> void:
	edit_pressed.emit(id)

func _ensure_relationship_buttons() -> void:
	if $Buttons.has_node("Parents"):
		return
	var parents_button = Button.new()
	parents_button.name = "Parents"
	parents_button.text = "Parents"
	parents_button.pressed.connect(func(): show_parents_pressed.emit(id))
	$Buttons.add_child(parents_button)
	var children_button = Button.new()
	children_button.name = "Children"
	children_button.text = "Children"
	children_button.pressed.connect(func(): show_children_pressed.emit(id))
	$Buttons.add_child(children_button)
