extends Button

@export var subject_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var subject = Main.data.get_subject(subject_id)
	if subject:
		var initials = Array(subject.title.split(' ')).map(func (word: String): return word[0])
		$Abbreviation.text = ''.join(PackedStringArray(initials))
