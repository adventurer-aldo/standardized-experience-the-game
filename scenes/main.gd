extends ColorRect

func _ready() -> void:
	$EmblemAnim.play("splash")
	get_tree().create_timer(2.0).timeout.connect(welcome)

func welcome() -> void:
	$VC.play()
	await $VC.finished
	$YellowLoop/ScrollAnim.play("scroll")
