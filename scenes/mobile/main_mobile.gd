extends ColorRect

@export var freestyle_scene: PackedScene
@export var subjects_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.wipe_out()


func _on_freestyle_button_pressed() -> void:
	Main.wipe_in()
	await Main.wipe_finished
	get_tree().change_scene_to_packed(freestyle_scene)
