extends AudioStreamPlayer

signal speak_finished

@onready var _alt = $SFX_alt
@onready var voice = $Voice

func effect(trackname: String, main: bool = true):
	if main == true:
		stream = load("res://audio/sfx/{name}.ogg".format({"name": trackname}))
		play()
	else:
		_alt.stream = load("res://audio/sfx/{name}.ogg".format({"name": trackname}))
		_alt.play()

func speak(trackname: String):
	$Voice.stream = load("res://audio/voice/{name}.ogg".format({"name": trackname}))
	$Voice.play()

func speak_stop():
	$Voice.stop()

func _on_voice_finished():
	speak_finished.emit()
