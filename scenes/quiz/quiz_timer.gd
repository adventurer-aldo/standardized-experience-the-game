extends Panel

signal rush_time_started

var was_rush_signaled := false

func _ready() -> void:
	BGM.rush_time_started.connect(_on_blinking_animation_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var minutes = int($Timer.time_left / 60)
	var seconds = int(int($Timer.time_left) % 60)
	$Label.text = (str(minutes) + "m "  if minutes > 0 else "") + str(seconds) + 's'
	if was_rush_signaled == false:
		if minutes == 2 && seconds == 30:
			was_rush_signaled = true
			$TimeAnims.play("show_up")
			rush_time_started.emit()

func _on_rush_time_started() -> void:
	$TimeAnims.play("show_up")

func _on_blinking_animation_finished(_anim_name) -> void:
	$Blinking.play("blink")
