extends ColorRect

@export var main_scene: PackedScene

func _ready() -> void:
	$EmblemAnim.play("splash")
	await get_tree().create_timer(0.7).timeout
	$BGM.play()
	get_tree().create_timer(2.0).timeout.connect(welcome)

func welcome() -> void:
	$Voice.random_play("welcome")
	await $Voice.finished
	Main.wipe_in()
	await Main.wipe_finished
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(main_scene)
