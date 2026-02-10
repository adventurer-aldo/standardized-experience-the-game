extends Panel

@export var data_subject_scene: PackedScene

func _ready() -> void:
	$BGM.play()
	$Overlay/ScrollLoopAnim.play("scroll")
	Main.wipe_out()

func _on_subjects_pressed() -> void:
	add_child(data_subject_scene.instantiate())

func _on_exit_pressed() -> void:
	Main.wipe_in(Color.BLACK)
	# $ScreenDim.announce_text("You're about to leave, but we'll see you soon!")
	$Voice.random_play("exit")
	await $Voice.finished
	get_tree().quit()


func _on_scroll_loop_anim_animation_finished(_anim_name: StringName) -> void:
	$Overlay/ScrollLoopAnim.play("scroll")


func _on_journey_button_focus_entered() -> void:
	$Outline/Mask/Texture.texture = load("res://graphics/backgrounds/journey.png")
	$ChangeIlust.play("slide_in")

func _on_subjects_button_focus_entered() -> void:
	$Outline/Mask/Texture.texture = load("res://graphics/backgrounds/library.png")
	$ChangeIlust.play("slide_in")

func _on_freestyle_button_focus_entered() -> void:
	$Outline/Mask/Texture.texture = load("res://graphics/backgrounds/freestyle.png")
	$ChangeIlust.play("slide_in")

func _on_rest_button_focus_entered() -> void:
	$Outline/Mask/Texture.texture = load("res://graphics/backgrounds/rest.png")
	$ChangeIlust.play("slide_in")
