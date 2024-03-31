extends Panel

signal rush_time_started

var was_rush_signaled := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var minutes = int($Timer.time_left / 60)
	var seconds = int(int($Timer.time_left) % 60)
	print(str(minutes) + "-" + str(seconds))
	$Label.text = (str(minutes) + "m "  if minutes > 0 else "") + str(seconds) + 's'
	if was_rush_signaled == false:
		if minutes == 2 && seconds == 30:
			was_rush_signaled = true
			$TimeAnims.play("show_up")
			emit_signal("rush_time_started")


func _on_rush_time_started() -> void:
	$TimeAnims.play("show_up")
