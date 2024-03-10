extends Button

func _on_focus_entered():
	blue_mode()

func _on_focus_exited():
	white_mode()

func blue_mode():
	$ActionSplitter/Margin2/ActionName.add_theme_color_override("font_color", Color.WHITE)
	$ActionSplitter/Margin/BackgroundColor.add_theme_stylebox_override("panel", preload("res://themes/boxes/title_action_background_white.tres"))
	$ActionSplitter/Margin/Icon.modulate = Color(0.051, 0.427, 0.976)

func white_mode():
	$ActionSplitter/Margin2/ActionName.add_theme_color_override("font_color", Color.BLACK)
	$ActionSplitter/Margin/BackgroundColor.add_theme_stylebox_override("panel", preload("res://themes/boxes/title_action_background_blue.tres"))
	$ActionSplitter/Margin/Icon.modulate = Color.WHITE
