extends ColorRect

const LANGUAGES := {
	"en": "English",
	"pt": "Português",
	"es": "Español",
	"fr": "Français",
	"it": "Italiano",
	"ja": "日本語",
}

var first_name_edit: LineEdit
var last_name_edit: LineEdit
var language_option: OptionButton
var timezone_option: OptionButton
var birthday_edit: LineEdit

func _ready() -> void:
	if FileAccess.file_exists("user://data.tres"):
		call_deferred("_go_to_intro")
		return
	_build()
	Main.localize_tree(self)

func _build() -> void:
	var root = MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 160)
	root.add_theme_constant_override("margin_top", 80)
	root.add_theme_constant_override("margin_right", 160)
	root.add_theme_constant_override("margin_bottom", 80)
	add_child(root)

	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	root.add_child(layout)

	var title = Label.new()
	title.text = "Welcome"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	layout.add_child(title)

	first_name_edit = _add_line_edit(layout, "First Name")
	last_name_edit = _add_line_edit(layout, "Last Name")
	language_option = _add_option(layout, "Language")
	for code in LANGUAGES.keys():
		language_option.add_item(LANGUAGES[code])
		language_option.set_item_metadata(language_option.item_count - 1, code)
	timezone_option = _add_option(layout, "Timezone")
	for zone in Timezone.get_zones():
		timezone_option.add_item(Timezone.get_label(zone))
		timezone_option.set_item_metadata(timezone_option.item_count - 1, zone)
		if zone == Timezone.Zone.UTC_PLUS_02_00:
			timezone_option.select(timezone_option.item_count - 1)
	birthday_edit = _add_line_edit(layout, "Birthday")
	birthday_edit.placeholder_text = "Unix timestamp, optional"

	var start = Button.new()
	start.text = "Start"
	start.pressed.connect(_on_start_pressed)
	layout.add_child(start)

func _add_line_edit(parent: VBoxContainer, label_text: String) -> LineEdit:
	var row = _add_row(parent, label_text)
	var input = LineEdit.new()
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(input)
	return input

func _add_option(parent: VBoxContainer, label_text: String) -> OptionButton:
	var row = _add_row(parent, label_text)
	var option = OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(option)
	return option

func _add_row(parent: VBoxContainer, label_text: String) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var label = Label.new()
	label.custom_minimum_size.x = 220
	label.text = label_text
	row.add_child(label)
	return row

func _on_start_pressed() -> void:
	Main.data.first_name = first_name_edit.text.strip_edges()
	Main.data.last_name = last_name_edit.text.strip_edges()
	Main.data.language = str(language_option.get_selected_metadata())
	Main.data.timezone = int(timezone_option.get_selected_metadata())
	Main.data.birthday = birthday_edit.text.to_float() if birthday_edit.text.strip_edges() != "" else 0.0
	Main.data.save()
	Main.wipe_in()
	await Main.wipe_finished
	_go_to_intro()

func _go_to_intro() -> void:
	get_tree().change_scene_to_file("res://scenes/intro.tscn")
