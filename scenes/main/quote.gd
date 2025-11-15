extends Label

@export var quotes: PackedStringArray

func _ready() -> void:
	randomize()
	if quotes.size() > 0:
		text = "\"" + quotes[randi() % quotes.size()] + "\""
