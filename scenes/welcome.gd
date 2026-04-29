extends ColorRect

@export var first_name:= ""
@export var last_name:= ""
@export var timezone: Timezone.Zone = Timezone.Zone.UTC
@export var birthday:= 0.0
@export var language:= "en"


func _ready() -> void:
	if Main.data == null:
		return
	Main.data.first_name = first_name
	Main.data.last_name = last_name
	Main.data.timezone = timezone
	Main.data.birthday = birthday
	Main.data.language = language
	Main.data.save()
	Main.localize_tree(self)
