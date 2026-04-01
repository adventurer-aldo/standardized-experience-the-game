extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BobAnim.play("bob")

func _on_bob_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "bob":
		await get_tree().create_timer(1.0).timeout
		$BobAnim.play("bob")
