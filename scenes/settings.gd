extends Control

const FOCUS_LEVELS := {
	0: "Any",
	1: "1st Test",
	2: "2nd Test",
	4: "Exam",
}

@onready var first_name_edit: LineEdit = $Root/Layout/Scroll/Form/Profile/Margin/Box/FirstNameRow/FirstName
@onready var last_name_edit: LineEdit = $Root/Layout/Scroll/Form/Profile/Margin/Box/LastNameRow/LastName
@onready var timezone_option: OptionButton = $Root/Layout/Scroll/Form/Profile/Margin/Box/TimezoneRow/Timezone
@onready var birthday_edit: LineEdit = $Root/Layout/Scroll/Form/Profile/Margin/Box/BirthdayRow/Birthday
@onready var lenient_check: CheckBox = $Root/Layout/Scroll/Form/Quiz/Margin/Box/Lenient
@onready var negative_points_check: CheckBox = $Root/Layout/Scroll/Form/Quiz/Margin/Box/NegativePoints
@onready var skip_dissertation_check: CheckBox = $Root/Layout/Scroll/Form/Quiz/Margin/Box/SkipDissertation
@onready var time_format_check: CheckBox = $Root/Layout/Scroll/Form/Quiz/Margin/Box/TimeFormat
@onready var prune_quizzes_check: CheckBox = $Root/Layout/Scroll/Form/Quiz/Margin/Box/PruneQuizzes
@onready var correction_whole_word_check: CheckBox = $Root/Layout/Scroll/Form/Quiz/Margin/Box/CorrectionWholeWord
@onready var max_quizzes_spin: SpinBox = $Root/Layout/Scroll/Form/Quiz/Margin/Box/MaxQuizzesRow/MaxQuizzes
@onready var focus_option: OptionButton = $Root/Layout/Scroll/Form/Quiz/Margin/Box/FocusRow/Focus
@onready var global_synonyms_editor: PanelContainer = $Root/Layout/Scroll/Form/Synonyms/Margin/Box/GlobalSynonyms

func _ready() -> void:
	_populate_timezone_options()
	_populate_focus_options()
	global_synonyms_editor.setup("Global Synonyms", "No global synonym groups yet.")
	_load_data()
	Main.localize_tree(self)
	Main.wipe_out()

func _populate_timezone_options() -> void:
	timezone_option.clear()
	for zone in Timezone.get_zones():
		timezone_option.add_item(Timezone.get_label(zone))
		timezone_option.set_item_metadata(timezone_option.item_count - 1, zone)

func _populate_focus_options() -> void:
	focus_option.clear()
	for focus_level in FOCUS_LEVELS.keys():
		focus_option.add_item(FOCUS_LEVELS[focus_level])
		focus_option.set_item_metadata(focus_option.item_count - 1, focus_level)

func _load_data() -> void:
	first_name_edit.text = Main.data.first_name
	last_name_edit.text = Main.data.last_name
	birthday_edit.text = str(Main.data.birthday) if Main.data.birthday > 0.0 else ""
	_select_metadata(timezone_option, Main.data.timezone)
	_select_metadata(focus_option, Main.data.focus)
	lenient_check.button_pressed = Main.data.lenient
	negative_points_check.button_pressed = Main.data.negative_points
	skip_dissertation_check.button_pressed = Main.data.skip_dissertation
	time_format_check.button_pressed = Main.data.use_24_hour_time
	prune_quizzes_check.button_pressed = Main.data.prune_saved_quizzes
	correction_whole_word_check.button_pressed = Main.data.open_correction_whole_word
	max_quizzes_spin.value = Main.data.max_saved_quizzes
	global_synonyms_editor.set_groups(Main.data.synonym_groups)

func _save_data() -> void:
	Main.data.first_name = first_name_edit.text.strip_edges()
	Main.data.last_name = last_name_edit.text.strip_edges()
	Main.data.timezone = int(timezone_option.get_selected_metadata())
	Main.data.focus = int(focus_option.get_selected_metadata())
	Main.data.birthday = birthday_edit.text.to_float() if birthday_edit.text.strip_edges() != "" else 0.0
	Main.data.lenient = lenient_check.button_pressed
	Main.data.negative_points = negative_points_check.button_pressed
	Main.data.skip_dissertation = skip_dissertation_check.button_pressed
	Main.data.use_24_hour_time = time_format_check.button_pressed
	Main.data.prune_saved_quizzes = prune_quizzes_check.button_pressed
	Main.data.open_correction_whole_word = correction_whole_word_check.button_pressed
	Main.data.max_saved_quizzes = int(max_quizzes_spin.value)
	Main.data.synonym_groups = global_synonyms_editor.get_synonym_groups()
	Main.data.save()
	Main.data.prune_old_quizzes()

func _select_metadata(option: OptionButton, metadata) -> void:
	for item_index in range(option.item_count):
		if option.get_item_metadata(item_index) == metadata:
			option.select(item_index)
			return

func _on_save_pressed() -> void:
	_save_data()

func _on_back_pressed() -> void:
	_save_data()
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
