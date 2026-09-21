extends MarginContainer

signal text_has_changed(difference: int)
var text:= ""

func fetch() -> PackedStringArray:
	print($Text.text.split("\n"))
	return $Text.text.split("\n")

func set_text(to: String) -> void:
	$Text.text = to

func get_focus() -> void:
	$Text.grab_focus()

func _on_text_text_changed() -> void:
	var diff = $Text.text.strip_edges().length() - text.strip_edges().length()
	text = $Text.text
	if diff!= 0: text_has_changed.emit(diff)

func make_text_red() -> void:
	$Text.add_theme_color_override("font_color", Color.RED)

func tick(right_text: String) -> void:
	if !$RTL.get_parsed_text().is_empty():
		$RTL.newline()
	$RTL.append_text(right_text)

func cross(wrong_text: String, with_text: String) -> void:
	if !$RTL.get_parsed_text().is_empty():
		$RTL.newline()
	if with_text.is_empty():
		$RTL.push_color(Color.RED)
	else:
		$RTL.push_strikethrough(Color.RED)
	$RTL.append_text(wrong_text)
	$RTL.pop()
	$RTL.push_color(Color.RED)
	$RTL.append_text(with_text)
	$RTL.pop()
