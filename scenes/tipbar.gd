extends ColorRect

@export_enum("None", "Downloads", "Questions") var source: String = "None"
@export_group("Groups")
var none = [""]
@export var downloads: PackedStringArray
@export var questions: PackedStringArray

func _ready():
	$Label.text = Array(get(source.to_lower())).pick_random()
