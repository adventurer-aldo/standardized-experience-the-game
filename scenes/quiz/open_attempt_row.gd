extends HBoxContainer

signal text_has_changed(difference: int)
signal text_focused
signal text_unfocused
signal add_row_requested
signal erase_if_empty_requested
var text:= ""
var order_label: Label

func fetch() -> String:
	return $TextsMargin/Text.text

func _ready() -> void:
	_ensure_order_label()

func _on_delete_button_pressed() -> void:
	queue_free()

func _input(event: InputEvent) -> void:
	if !$TextsMargin/Text.has_focus() || !(event is InputEventKey) || !event.pressed || event.echo:
		return
	if event.keycode == KEY_ENTER || event.keycode == KEY_KP_ENTER:
		accept_event()
		add_row_requested.emit()
	elif event.keycode == KEY_BACKSPACE || event.keycode == KEY_DELETE:
		if $TextsMargin/Text.text.strip_edges() == "":
			accept_event()
			erase_if_empty_requested.emit()

func set_text(to: String) -> void:
	$TextsMargin/Text.text = to

func get_focus() -> void:
	$TextsMargin/Text.grab_focus()

func _on_text_text_changed() -> void:
	var diff = $TextsMargin/Text.text.strip_edges().length() - text.strip_edges().length()
	text = $TextsMargin/Text.text
	if diff!= 0: text_has_changed.emit(diff)

func _on_text_focus_entered() -> void:
	text_focused.emit()
	$DeleteButton.show()

func _on_text_focus_exited() -> void:
	text_unfocused.emit()
	$DeleteButton.hide()

func make_text_red() -> void:
	$TextsMargin/Text.add_theme_color_override("font_color", Color.RED)

func tick() -> void:
	$TextsMargin/Text.hide()
	$Correction/Tick.show()
	$TextsMargin/RTL.append_text($TextsMargin/Text.text)

func cross(with_text: String, mark:= true) -> void:
	$TextsMargin/Text.hide()
	$DeleteButton.hide()
	$TextsMargin/RTL.push_strikethrough(Color.RED)
	$TextsMargin/RTL.append_text($TextsMargin/Text.text)
	$TextsMargin/RTL.pop()
	$TextsMargin/RTL.push_color(Color.RED)
	$TextsMargin/RTL.append_text(with_text)
	$TextsMargin/RTL.pop()
	if mark:
		$Correction/Cross.show()

func show_order(number: int) -> void:
	_ensure_order_label()
	order_label.text = str(number)
	order_label.show()

func hide_order() -> void:
	if order_label != null:
		order_label.hide()

func _ensure_order_label() -> void:
	if order_label != null:
		return
	order_label = Label.new()
	order_label.name = "Order"
	order_label.text = "1"
	order_label.custom_minimum_size = Vector2(28, 28)
	order_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	order_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	order_label.add_theme_color_override("font_color", Color(0.05, 0.06, 0.08))
	order_label.hide()
	add_child(order_label)
