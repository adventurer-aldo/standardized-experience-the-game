extends ColorRect

@export var main_scene: PackedScene

func _ready() -> void:
	$EmblemAnim.play("splash")
	get_tree().create_timer(2.0).timeout.connect(welcome)

func welcome() -> void:
	$Voice.random_play("welcome")
	await $Voice.finished
	$YellowLoop/ScrollAnim.play("move_in")
	await $YellowLoop/ScrollAnim.animation_finished
	$BGM.play()
	await get_tree().create_timer(1).timeout
	$EmblemAnim.add_sibling(main_scene.instantiate())
	$YellowLoop/ScrollAnim.play("move_out")
