extends Control

const LANGUAGES := {
	"en": "English",
	"pt": "Português",
	"es": "Español",
	"fr": "Français",
	"it": "Italiano",
	"ja": "日本語",
}

const FOCUS_LEVELS := {
	0: "Any",
	1: "1st Test",
	2: "2nd Test",
	4: "Exam",
}

var first_name_edit: LineEdit
var last_name_edit: LineEdit
var language_option: OptionButton
var timezone_option: OptionButton
var birthday_edit: LineEdit
var lenient_check: CheckBox
var negative_points_check: CheckBox
var skip_dissertation_check: CheckBox
var time_format_check: CheckBox
var prune_quizzes_check: CheckBox
var max_quizzes_spin: SpinBox
var focus_option: OptionButton

func _ready() -> void:
	_build()
	_load_data()
	Main.localize_tree(self)
	Main.wipe_out()

func _build() -> void:
	var bg = Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root = MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 72)
	root.add_theme_constant_override("margin_top", 48)
	root.add_theme_constant_override("margin_right", 72)
	root.add_theme_constant_override("margin_bottom", 48)
	add_child(root)

	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	root.add_child(layout)

	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	layout.add_child(header)

	var back = Button.new()
	back.text = "Back"
	back.pressed.connect(_on_back_pressed)
	header.add_child(back)

	var title = Label.new()
	title.text = "Settings"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	header.add_child(title)

	var save = Button.new()
	save.text = "Save"
	save.pressed.connect(_on_save_pressed)
	header.add_child(save)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)

	var form = VBoxContainer.new()
	form.add_theme_constant_override("separation", 10)
	scroll.add_child(form)

	first_name_edit = _add_line_edit(form, "First Name")
	last_name_edit = _add_line_edit(form, "Last Name")
	language_option = _add_option(form, "Language")
	for code in LANGUAGES.keys():
		language_option.add_item(LANGUAGES[code])
		language_option.set_item_metadata(language_option.item_count - 1, code)
	timezone_option = _add_option(form, "Timezone")
	for zone in Timezone.get_zones():
		timezone_option.add_item(Timezone.get_label(zone))
		timezone_option.set_item_metadata(timezone_option.item_count - 1, zone)
	birthday_edit = _add_line_edit(form, "Birthday")
	birthday_edit.placeholder_text = "Unix timestamp, optional"
	focus_option = _add_option(form, "Freestyle Focus")
	for focus_level in FOCUS_LEVELS.keys():
		focus_option.add_item(FOCUS_LEVELS[focus_level])
		focus_option.set_item_metadata(focus_option.item_count - 1, focus_level)
	lenient_check = _add_check(form, "Lenient Grading")
	negative_points_check = _add_check(form, "Negative Points")
	skip_dissertation_check = _add_check(form, "Skip Dissertation When Missing")
	time_format_check = _add_check(form, "Use 24-Hour Time")
	prune_quizzes_check = _add_check(form, "Limit Saved Quizzes")
	max_quizzes_spin = _add_spin(form, "Maximum Saved Quizzes", 1, 10000, 1)

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

func _add_check(parent: VBoxContainer, label_text: String) -> CheckBox:
	var check = CheckBox.new()
	check.text = label_text
	parent.add_child(check)
	return check

func _add_spin(parent: VBoxContainer, label_text: String, min_value: float, max_value: float, step: float) -> SpinBox:
	var row = _add_row(parent, label_text)
	var spin = SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = step
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spin)
	return spin

func _add_row(parent: VBoxContainer, label_text: String) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var label = Label.new()
	label.custom_minimum_size.x = 220
	label.text = label_text
	row.add_child(label)
	return row

func _load_data() -> void:
	first_name_edit.text = Main.data.first_name
	last_name_edit.text = Main.data.last_name
	birthday_edit.text = str(Main.data.birthday) if Main.data.birthday > 0.0 else ""
	_select_metadata(language_option, Main.data.language)
	_select_metadata(timezone_option, Main.data.timezone)
	_select_metadata(focus_option, Main.data.focus)
	lenient_check.button_pressed = Main.data.lenient
	negative_points_check.button_pressed = Main.data.negative_points
	skip_dissertation_check.button_pressed = Main.data.skip_dissertation
	time_format_check.button_pressed = Main.data.use_24_hour_time
	prune_quizzes_check.button_pressed = Main.data.prune_saved_quizzes
	max_quizzes_spin.value = Main.data.max_saved_quizzes

func _save_data() -> void:
	Main.data.first_name = first_name_edit.text.strip_edges()
	Main.data.last_name = last_name_edit.text.strip_edges()
	Main.data.language = str(language_option.get_selected_metadata())
	Main.data.timezone = int(timezone_option.get_selected_metadata())
	Main.data.focus = int(focus_option.get_selected_metadata())
	Main.data.birthday = birthday_edit.text.to_float() if birthday_edit.text.strip_edges() != "" else 0.0
	Main.data.lenient = lenient_check.button_pressed
	Main.data.negative_points = negative_points_check.button_pressed
	Main.data.skip_dissertation = skip_dissertation_check.button_pressed
	Main.data.use_24_hour_time = time_format_check.button_pressed
	Main.data.prune_saved_quizzes = prune_quizzes_check.button_pressed
	Main.data.max_saved_quizzes = int(max_quizzes_spin.value)
	Main.data.save()
	Main.data.prune_old_quizzes()

func _select_metadata(option: OptionButton, metadata) -> void:
	for item_index in range(option.item_count):
		if option.get_item_metadata(item_index) == metadata:
			option.select(item_index)
			return

func _on_save_pressed() -> void:
	_save_data()
	Main.localize_tree(self)

func _on_back_pressed() -> void:
	_save_data()
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
