extends ColorRect

@export_enum("None", "Downloads") var source: String = "None"
@export_group("Groups")
var none = [""]
@export var downloads: PackedStringArray

func _ready():
	$Label.text = Array(get(source.to_lower())).pick_random()
