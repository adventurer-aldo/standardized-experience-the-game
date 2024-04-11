extends TextureRect

func _ready() -> void:
	$LoopAnim.play("slow_loop")

func _on_loop_anim_animation_finished(_anim_name: StringName) -> void:
	$LoopAnim.play("slow_loop")
