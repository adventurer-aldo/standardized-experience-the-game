extends Button

@export var subject_id: int

signal subject_pressed(id: int)

func _ready() -> void:
	var subject = Main.data.get_subject(subject_id)
	if subject:
		var initials = Array(subject.title.split(' ')).map(func (word: String): return word[0])
		$Abbreviation.text = ''.join(PackedStringArray(initials))

func _on_pressed() -> void:
	subject_pressed.emit(subject_id)
