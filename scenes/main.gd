extends Panel

@export var data_subject_scene: PackedScene
@export var freestyle_scene: PackedScene
@export var journey_scene: PackedScene
@export var settings_scene: PackedScene

func _ready() -> void:
	Main.localize_tree(self)
	$BGM.play()
	$Overlay/ScrollLoopAnim.play("scroll")
	Main.wipe_out()
	_set_focus_description($Base2/VBoxContainer/SubjectsButton)

func _on_scroll_loop_anim_animation_finished(_anim_name: StringName) -> void:
	$Overlay/ScrollLoopAnim.play("scroll")

func _on_journey_button_focus_entered() -> void:
	$CursorSFX.play()
	$Outline/Mask/Texture.texture = load("res://graphics/backgrounds/journey.png")
	$ChangeIlust.play("slide_in")
	_set_focus_description($Base2/VBoxContainer/JourneyButton)

func _on_subjects_button_focus_entered() -> void:
	$CursorSFX.play()
	$Outline/Mask/Texture.texture = load("res://graphics/backgrounds/library.png")
	$ChangeIlust.play("slide_in")
	_set_focus_description($Base2/VBoxContainer/SubjectsButton)

func _on_freestyle_button_focus_entered() -> void:
	$CursorSFX.play()
	$Outline/Mask/Texture.texture = load("res://graphics/backgrounds/freestyle.png")
	$ChangeIlust.play("slide_in")
	_set_focus_description($Base2/VBoxContainer/FreestyleButton)

func _on_rest_button_focus_entered() -> void:
	$CursorSFX.play()
	$Outline/Mask/Texture.texture = load("res://graphics/backgrounds/rest.png")
	$ChangeIlust.play("slide_in")
	_set_focus_description($Base2/VBoxContainer/RestButton)

func _on_settings_button_focus_entered() -> void:
	$CursorSFX.play()
	$Outline/Mask/Texture.texture = load("res://graphics/backgrounds/library.png")
	$ChangeIlust.play("slide_in")
	_set_focus_description($Base2/VBoxContainer/SettingsButton)

func _on_subjects_pressed() -> void:
	$SelectSFX.play()
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_packed(data_subject_scene)
	# add_child(data_subject_scene.instantiate())

func _on_exit_pressed() -> void:
	$SelectSFX.play()
	Main.wipe_in(Color.BLACK)
	# $ScreenDim.announce_text("You're about to leave, but we'll see you soon!")
	$Voice.random_play("exit")
	await $Voice.finished
	get_tree().quit()

func _on_freestyle_button_pressed() -> void:
	$SelectSFX.play()
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_packed(freestyle_scene)


func _on_journey_button_pressed() -> void:
	$SelectSFX.play()
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_packed(journey_scene)

func _on_settings_button_pressed() -> void:
	$SelectSFX.play()
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_packed(settings_scene)

func _set_focus_description(button: Node) -> void:
	if !has_node("FocusDescription") || button == null:
		return
	var description_node = button.get_node_or_null("Texts/MDesc/Desc")
	if description_node == null:
		return
	$FocusDescription.text = Main.data.translate(description_node.text)
