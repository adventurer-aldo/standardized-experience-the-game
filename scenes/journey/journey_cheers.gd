extends Label

@export var texts: Dictionary[int, PackedStringArray]

func update_cheer(stage: int) -> void:
	randomize()
	text = texts[stage][randi() % texts[stage].size()]
