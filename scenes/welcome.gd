extends ColorRect

@onready var first_name_edit: LineEdit = $Root/Layout/FirstNameRow/FirstName
@onready var last_name_edit: LineEdit = $Root/Layout/LastNameRow/LastName
@onready var timezone_option: OptionButton = $Root/Layout/TimezoneRow/Timezone
@onready var birthday_edit: LineEdit = $Root/Layout/BirthdayRow/Birthday

func _ready() -> void:
	if FileAccess.file_exists("user://data.tres"):
		call_deferred("_go_to_intro")
		return
	_populate_timezone_options()
	Main.localize_tree(self)

func _populate_timezone_options() -> void:
	timezone_option.clear()
	for zone in Timezone.get_zones():
		timezone_option.add_item(Timezone.get_label(zone))
		timezone_option.set_item_metadata(timezone_option.item_count - 1, zone)
		if zone == Main.data.timezone:
			timezone_option.select(timezone_option.item_count - 1)

func _on_start_pressed() -> void:
	Main.data.first_name = first_name_edit.text.strip_edges()
	Main.data.last_name = last_name_edit.text.strip_edges()
	Main.data.timezone = int(timezone_option.get_selected_metadata())
	Main.data.birthday = birthday_edit.text.to_float() if birthday_edit.text.strip_edges() != "" else 0.0
	Main.data.save()
	Main.wipe_in()
	await Main.wipe_finished
	_go_to_intro()

func _go_to_intro() -> void:
	get_tree().change_scene_to_file("res://scenes/intro.tscn")
